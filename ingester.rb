require 'bunny'
require 'rdf/turtle'
require 'json/ld'

class Ingester


  def initialize(options)
    bunny_client_class = Module.const_get(options[:client_class])
    bunny_client = bunny_client_class.new(options)
    bunny_client.start
    channel = bunny_client.create_channel
    @exchange = channel.default_exchange
    @work_queue = options[:work_queue]
    @error_logger = Logger.new(options[:error_log])
  end


  def ingest_rdf(dir)
    Dir.foreach(dir) { |file|
      if File.extname(file) == '.rdf'
        begin
          if File.basename(file, '.rdf').end_with? 'metadata'
            process_metadata_rdf(file)
          else
            # TODO: process annotaion rdf
          end
        rescue  Exception => e
          @error_logger.error "#{e.class}: #{e.to_s}"
        end
      end
    }
  end

  def process_metadata_rdf(rdf_file)
    graph = RDF::Graph.load(rdf_file, :format => :ttl)
    json_ld = graph.dump(:jsonld)
    message = "{'action': 'add item', 'metadata':#{json_ld}}"
    @exchange.publish(message, routing_key: @work_queue)
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