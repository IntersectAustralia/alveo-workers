$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'sesame_client'
require 'active_record'
require 'models/item'
require 'models/document'
require 'models/collection'
require 'models/user'
require 'postgres_helper'
require 'trove_ingester'
require 'sesame_worker'
require 'sesame_helper'
require 'rsolr'

def main(config)

  # options = {adapter: 'postgresql', database: 'hcsvlab', user: 'hcsvlab', host: 'alveo-qa-pg.intersect.org.au'}
  # ActiveRecord::Base.establish_connection(options)

  ingester = TroveIngester.new(config[:ingester])
  # ingester.connect
  # trove_chunk = "/data/production_collections/trove-test/data-1.dat"
  # ingester.process_chunk(trove_chunk)
  
  trove_example = './spec/files/trove_chunk_example.dat'
  trove_json_string = File.read(trove_example, encoding: 'iso-8859-1')
  trove_json = JSON.parse(trove_json_string)
  jld_string = ingester.map_to_json_ld(trove_json)
  sesame_helper = Class.new().include(SesameHelper).new
  jld = JSON.parse(jld_string)
  graph = sesame_helper.create_rdf_graph(jld['items'].first)
  n3_string = RDF::NTriples::Writer.dump(graph, nil, :encoding => Encoding::ASCII)


  require 'pry'
  binding.pry
end

def get_uniq_count(trove_chunk, limit)
  count = 0
  ids = []
  File.open(trove_chunk, 'r:iso-8859-1').each { |trove_record|
    trove_fields = JSON.parse(trove_record.encode('utf-8'))
    if trove_fields['id'].nil?
      puts trove_fields.to_json
    else
      ids << trove_fields['id']
    end
    count += 1
    break if count >= limit
  }
  ids.uniq.length
end

if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config)
end