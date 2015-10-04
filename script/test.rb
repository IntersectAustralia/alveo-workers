$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'sesame_client'
require 'active_record'
require 'models/item'
require 'models/document'
require 'postgres_helper'
require 'trove_ingester'

def main(config)
  # sesame_client = SesameClient.new(config[:sesame_worker])
  # turtle = File.open("#{File.dirname(__FILE__)}/../spec/files/turtle_example.rdf").read
  # options = {adapter: 'postgresql', database: 'hcsvlab', user: 'hcsvlab', host: 'localhost'}
  # ActiveRecord::Base.establish_connection(options)
  # json_ld_expanded = JSON.parse(File.read("#{File.dirname(__FILE__)}/../spec/files/json-ld_expanded_example.json"))

  # context = {
  #     "ace" =>{"@id" =>"http://ns.ausnc.org.au/schemas/ace/"},
  #     "alveo" =>{"@id" =>"http://alveo.edu.au/schema/"},
  #     "ausnc" =>{"@id" =>"http://ns.ausnc.org.au/schemas/ausnc_md_model/"},
  #     "austalk" =>{"@id" =>"http://ns.austalk.edu.au/"},
  #     "austlit" =>{"@id" =>"http://ns.ausnc.org.au/schemas/austlit/"},
  #     "bibo" =>{"@id" =>"http://purl.org/ontology/bibo/"},
  #     "commonProperties" =>{"@id" =>"http://purl.org/dada/schema/0.2#commonProperties"},
  #     "cooee" =>{"@id" =>"http://ns.ausnc.org.au/schemas/cooee/"},
  #     "dada" =>{"@id" =>"http://purl.org/dada/schema/0.2#"},
  #     "dc" =>{"@id" =>"http://purl.org/dc/terms/"},
  #     "end" =>{"@id" =>"http://purl.org/dada/schema/0.2#end"},
  #     "foaf" =>{"@id" =>"http://xmlns.com/foaf/0.1/"},
  #     "gcsause" =>{"@id" =>"http://ns.ausnc.org.au/schemas/gcsause/"},
  #     "ice" =>{"@id" =>"http://ns.ausnc.org.au/schemas/ice/"},
  #     "label" =>{"@id" =>"http://purl.org/dada/schema/0.2#label"},
  #     "olac" =>{"@id" =>"http://www.language-archives.org/OLAC/1.1/"},
  #     "purl" =>{"@id" =>"http://purl.org/"},
  #     "rdf" =>{"@id" =>"http://www.w3.org/1999/02/22-rdf-syntax-ns#"},
  #     "schema" =>{"@id" =>"http://schema.org/"},
  #     "start" =>{"@id" =>"http://purl.org/dada/schema/0.2#start"},
  #     "type" =>{"@id" =>"http://purl.org/dada/schema/0.2#type"},
  #     "xsd" =>{"@id" =>"http://www.w3.org/2001/XMLSchema#"},
  #     # "hcsvlab" => "http://hcsvlab.org/vocabulary/",
  #     "hcsvlab" => {"@id" => "http://hcsvlab.org/vocabulary/"},
  #     "ausnc:audience" =>{ "@type"=>"@id"},
  #     "ausnc:communication_setting"=>{ "@type"=>"@id" },
  #     "ausnc:document" => {"@type" => "@id"},
  #     # "ausnc:itemwordcount"=>{ "@type"=>"xsd:integer"},
  #     # "ausnc:itemwordcount"=>{ "@type"=>"@id"},
  #     "ausnc:mode"=>{  "@type"=>"@id" },
  #     "ausnc:publication_status"=>{  "@type"=>"@id" },
  #     "ausnc:written_mode"=>{  "@type"=>"@id" },
  #     "dc:isPartOf"=>{  "@type"=>"@id" },
  #     "dcterms:extent"=>{ "@type"=>"xsd:integer"},
  #     "dcterms:source"=>{  "@type"=>"@id" },
  #     "hcsvlab:display_document" => {  "@type"=>"@id" },
  #     "hcsvlab:indexable_document" => {  "@type"=>"@id" }
  #     }.freeze

  # item = json_ld_expanded[0]
  # compacted = JSON::LD::API.compact(item, context)

  ingester = TroveIngester.new(config[:ingester])
  trove_chunk = "#{File.dirname(__FILE__)}/../spec/files/data-1.dat"
  ingester.connect
  trove_example = JSON.parse(File.read("#{File.dirname(__FILE__)}/../spec/files/trove_example.json"))

  require 'pry'
  binding.pry
end

if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config)
end