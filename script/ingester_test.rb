$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'bunny'
require 'rdf/turtle'
require 'json/ld'
require 'thread'

class Ingester

  def initialize(options)
    @input_queue = Queue.new
    @solr_message_queue = Queue.new
    @sesame_message_queue = Queue.new
    @sesame_queue = Queue.new
    @solr_queue = Queue.new
    bunny_client_class = Module.const_get(options[:client_class])
    @bunny_client = bunny_client_class.new(options)
    @exchange_name = options[:exchange]
    @upload_queue_name = options[:upload_queue]
    @sesame_queue_name = options[:sesame_queue]
    @error_logger = Logger.new(options[:error_log])
    @threads = []
  end

  def connect
    @bunny_client.start
  end

  def close
    @bunny_client.close
  end

  def process(dir)
    collection = File.basename(dir)
    create_input_jobs(dir)
    process_input(collection)
    process_solr_message
    process_sesame_message
    process_solr
    process_sesame
    @input_worker.join
    @solr_message_queue << :END
    @sesame_message_queue << :END
    @solr_message_worker.join
    @solr_queue << :END
    @sesame_message_worker.join
    @sesame_queue << :END
    @solr_worker.join
    @sesame_worker.join
  end

  def process_sesame
    @sesame_worker = Thread.new do
      channel = @bunny_client.create_channel
      exchange = channel.direct(@exchange_name)
      sesame_queue = channel.queue(@sesame_queue_name)
      sesame_queue.bind(exchange)
      until (message = @sesame_queue.pop) == :END
        exchange.publish(message, routing_key: sesame_queue.name)
      end
    end
    @threads << @sesame_worker
    # sesame_worker.join
    puts 'process_sesame'
  end

  def process_solr
    @solr_worker = Thread.new do
      channel = @bunny_client.create_channel
      exchange = channel.direct(@exchange_name)
      upload_queue = channel.queue(@upload_queue_name)
      upload_queue.bind(exchange)
      until (message = @solr_queue.pop) == :END
        exchange.publish(message, routing_key: upload_queue.name)
      end
    end
    @threads << @solr_worker
    # solr_worker.join
    puts 'process_solr'
  end

  def process_solr_message
    @solr_message_worker = Thread.new do
      until (ttl_string = @solr_message_queue.pop) == :END
        graph = RDF::Graph.new
        RDF::Reader.for(:ttl).new(ttl_string[:payload]) { |reader|
          reader.each_statement { |statement|
            graph << statement
          }
        }
        json_ld = graph.dump(:jsonld)
        #TODO: Move actions to message headers
        message = "{\"action\": \"add item\", \"metadata\":#{json_ld}}"
        @solr_queue << message
      end
    end
    # solr_message_worker.join
    @threads << @solr_message_worker
    # @solr_queue << :END
    puts 'process_solr_message'
  end

  def process_sesame_message
    @sesame_message_worker = Thread.new do
      until (turtle = @sesame_message_queue.pop) == :END
        # turtle = File.open(rdf_file[:payload]).read
        message = "{\"action\": \"add\",\"collection\": \"#{turtle[:collection]}\", \"payload\": #{turtle[:payload].to_json} }"
        @sesame_queue << message
      end
    end
    # sesame_message_worker.join
    # @sesame_queue << :END
    @threads << @sesame_message_worker
    puts 'process_sesame_message'
  end

  def process_input(collection)
    @input_worker = Thread.new do
      until (file_path = @input_queue.pop) == :END
        input_job = {collection: collection, payload: File.read(file_path)}
        if is_metadata? file_path
          input_job[:type] = 'metadata'
          @solr_message_queue << input_job
        else
          input_job[:type] = 'annotations'
        end
        @sesame_message_queue << input_job
      end
    end
    # input_worker.join
    # @solr_message_queue << :END
    # @sesame_message_queue << :END
    @threads << @input_worker
    puts 'process_input'
  end

  def create_input_jobs(dir)
    Dir[File.join(dir, '**', '*')].each { |path|
      if (File.file? path) && (File.extname(path) == '.rdf')
        @input_queue << path
      end
    }
    @input_queue << :END

    puts 'create_input_jobs'
  end

  def is_metadata?(file_path)
    File.basename(file_path, '.rdf').end_with?('metadata')
  end

end



def main(directory)
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  ingester = Ingester.new(config[:ingester])
  ingester.connect
  ingester.process(directory)
  ingester.close
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  main(ARGV[0])
end
