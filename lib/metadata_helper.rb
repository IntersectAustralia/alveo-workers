require 'open-uri'
require 'rdf/turtle'
require 'json/ld'

module MetadataHelper

  module JSON::LD

    @@CONTEXT = ["https://app.alveo.edu.au/schema/json-ld",
                  {
                    "ausnc:audience" =>{ "@type"=>"@id"},
                    "ausnc:communication_setting"=>{ "@type"=>"@id" },
                    "ausnc:mode"=>{  "@type"=>"@id" },
                    "ausnc:publication_status"=>{  "@type"=>"@id" },
                    "ausnc:written_mode"=>{  "@type"=>"@id" },
                    "ausnc:itemwordcount"=>{ "@type"=>"xsd:integer"},
                    "dcterms:extent"=>{ "@type"=>"xsd:integer"},
                    "dcterms:source"=>{  "@type"=>"@id" },
                    "hcsvlab" => "http://hcsvlab.org/vocabulary/",
                    "hcsvlab:display_document" => { "@type"=>"@id" },
                    "hcsvlab:indexable_document" => {  "@type"=>"@id" },
                    "ausnc:document" => {"@type" => "@id"},
                    "dc:isPartOf"=>{  "@type"=>"@id" }
                 }]

    @@FRAME = {"@context" => @@CONTEXT,
               "@type" => "ausnc:AusNCObject",
               "ausnc:document" => {"@type" => "foaf:Document"}}

  end

  def turtle_file_to_json(rdf_file)
    graph = RDF::Graph.load(rdf_file, :format => :ttl)
    json_ld = JSON.parse(graph.dump(:jsonld))
    JSON::LD::API.frame(json_ld, frame).to_json
  end
  

  def expand_json_ld(metadata)
    if metadata.instance_of? String
      metadata = load_json_from_file_url(metadata)
    end
    JSON::LD::API.expand(metadata)
  end

  def load_json_from_file_url(url)
    file_path = get_file_path_from_url(url)
    JSON.load(File.open(file_path))
  end

  def get_file_path_from_url(url)
    parsed_uri = URI.parse(url)
    if parsed_uri.scheme != 'file'
      raise 'Metadata must be in a file URI'
    end
    parsed_uri.path
  end

end