require 'bunny'
require 'rdf/turtle'
require 'json/ld'

class Ingester


  def initialize(options)
    bunny_client_class = Module.const_get(options[:client_class])
    @bunny_client = bunny_client_class.new(options)
    @bunny_client.start
    channel = @bunny_client.create_channel
    @exchange = channel.direct(options[:exchange])
    @upload_queue = channel.queue(options[:upload_queue])
    @upload_queue.bind(@exchange, routing_key: @upload_queue.name)
    @sesame_queue = channel.queue(options[:sesame_queue])
    @sesame_queue.bind(@exchange, routing_key: @sesame_queue.name)
    @error_logger = Logger.new(options[:error_log])
  end


  def get_rdf_file_paths(dir)
    Dir[File.join(dir, '**', '*')].keep_if { |path|
      (File.file? path) && (File.extname(path) == '.rdf')
    }
  end

  def ingest_rdf(dir)
    collection = File.basename(dir)
    get_rdf_file_paths(dir).each { |file_path|
      begin
        if is_metadata? file_path
          process_metadata_rdf(file_path)
        end
        add_to_sesame(collection, file_path)
      rescue  Exception => e
        @error_logger.error "#{e.class}: #{e.to_s}"
      end
    }
    @bunny_client.close
  end

  def process_metadata_rdf(rdf_file)
    graph = RDF::Graph.load(rdf_file, :format => :ttl)
    json_ld = graph.dump(:jsonld)
    #TODO: Move actions to message headers
    message = "{\"action\": \"add item\", \"metadata\":#{json_ld}}"
    # TODO: parameterise the routing key
    @exchange.publish(message, routing_key: @upload_queue.name)
  end

  def add_to_sesame(collection, rdf_file)
    # require 'pry'
    # binding.pry
    turtle = File.open(rdf_file).read
    message = "{\"action\": \"add\",\"collection\": \"#{collection}\", \"payload\": #{turtle.to_json} }"
    @exchange.publish(message, routing_key: @sesame_queue.name)
  end

  # def json_escape(string)
  #   string.gsub(/(['"\\\/\b\f\n\r\t])/, '\\\\\1')
  # end

  def is_metadata?(file_path)
    File.basename(file_path, '.rdf').end_with?('metadata')
  end

end
