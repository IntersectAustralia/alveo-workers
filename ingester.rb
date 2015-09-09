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
        # TODO: distinguish between item metadata
        #       and annotation rdf
        begin
          process_rdf(file)
        rescue  Exception => e
          @error_logger.error "#{e.class}: #{e.to_s}"
        end
      end
    }
  end

  def process_rdf(rdf_file)
    graph = RDF::Graph.load(rdf_file, :format => :ttl)
    json_ld = graph.dump(:jsonld)
    message = "{'action': 'add item', 'metadata':#{json_ld}}"
    @exchange.publish(message, routing_key: @work_queue)
  end

end