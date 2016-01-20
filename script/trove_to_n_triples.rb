$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'trove_ingester'
require 'metadata_helper'

def main(config)
  trove_chunk = "/Users/ilya/workspace/corpora/trove/data-1.dat"
  process_chunk(trove_chunk, config)
end



def process_chunk(trove_chunk, config)
  ingester = TroveIngester.new(config[:ingester])
  metadata_helper = Class.new.include(MetadataHelper).new
  outfile = File.open('n3_chunk.dat', 'a')
  File.open(trove_chunk, 'r:iso-8859-1').each { |trove_record|
    begin
      trove_fields = JSON.parse(trove_record.encode('utf-8'))
      trove_message = ingester.map_to_json_ld(trove_fields)
      trove_item = JSON.parse(trove_message)['items'].first
      trove_item['generated'] = metadata_helper.generate_fields(trove_item)
      n3_string = json_ld_to_n3(trove_item)
      outfile.write(n3_string)
    rescue Exception => e
    end
  }
  outfile.close
end

def json_ld_to_n3(json_ld)
  sesame_helper = Class.new().include(SesameHelper).new
  graph = sesame_helper.create_rdf_graph(json_ld)
  RDF::NTriples::Writer.dump(graph, nil, :encoding => Encoding::ASCII)
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config)
end

