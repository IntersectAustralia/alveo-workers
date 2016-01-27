$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'trove_ingester'
require 'metadata_helper'
require 'sesame_helper'
require 'benchmark'

include Benchmark

def main
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  trove_chunk = "/Users/ilya/workspace/corpora/trove/data-3.dat"
  ingester = TroveIngester.new(config[:ingester])
  metadata_helper = Class.new.include(MetadataHelper).new
  limits = [1, 10, 50, 100, 500, 1000, 5000, 10000, 100000]
  limit = 1000
  File.open(trove_chunk, 'r:iso-8859-1') { |trove_chunk|
    limits.each { |limit|
      Benchmark.benchmark(CAPTION, 10, FORMAT, '>item') { |bm|
        time = bm.report(limit) {
          process_chunk(trove_chunk, limit, ingester, metadata_helper)
        }
        [time/limit]
      }
    }
  }
end



def process_chunk(trove_chunk, limit, ingester, metadata_helper)
  count = 0
  graph = RDF::Repository.new
  trove_chunk.each { |trove_record|
    begin
      trove_fields = JSON.parse(trove_record.encode('utf-8'))
      trove_message = ingester.map_to_json_ld(trove_fields)
      trove_item = JSON.parse(trove_message)['items'].first
      trove_item['generated'] = metadata_helper.generate_fields(trove_item)
      graph << json_ld_to_rdf(trove_item)
      count += 1
      if count >= limit
        RDF::NTriples::Writer.dump(graph, nil, :encoding => Encoding::ASCII)      
        break
      end
    rescue Exception => e
      p e
    end
  }
end

def json_ld_to_rdf(json_ld)
  sesame_helper = Class.new().include(SesameHelper).new
  graph = sesame_helper.create_rdf_graph(json_ld)
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  main
end

