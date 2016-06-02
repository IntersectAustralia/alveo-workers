$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")


require 'ingester'

def main
  files = Ingester.get_rdf_file_paths(directory)
end


def process_metadata_rdf(rdf_file)
  graph = RDF::Graph.load(rdf_file, :format => :ttl)
  json_ld = graph.dump(:jsonld)
  properties = {routing_key: @upload_queue.name, headers: {action: 'create'}}
  message = "{\"metadata\":#{json_ld}}"
  @exchange.publish(message, properties)
end


if __FILE__ == $PROGRAM_NAME
  main(ARGV[0])
end