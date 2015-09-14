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
    @work_queue = channel.queue(options[:work_queue])
    @work_queue.bind(@exchange, routing_key: @work_queue.name)
    @error_logger = Logger.new(options[:error_log])
  end


  def get_rdf_file_paths(dir)
    Dir[File.join(dir, '**', '*')].keep_if { |path|
      (File.file? path) && (File.extname(path) == '.rdf')
    }
  end

  def ingest_rdf(dir)
    get_rdf_file_paths(dir).each { |file_path|
      begin
        if File.basename(file_path, '.rdf').end_with? 'metadata'
          process_metadata_rdf(file_path)
        else
          # TODO: process annotaion rdf
        end
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
    @exchange.publish(message, routing_key: 'upload')
  end

end

def main(directory)
  require 'yaml'
  config = YAML.load_file('spec/files/config.yml')
  ingester = Ingester.new(config[:ingester])
  ingester.ingest_rdf(directory)
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  main(ARGV[0])
end