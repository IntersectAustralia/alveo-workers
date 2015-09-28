require 'rdf/turtle'
require 'json/ld'

def load_document_local(url, options={}, &block)
  loader = Proc.new{|url, options={}, &block|
  # alveo_schema = {'@context' => {"commonProperties" => { "@id" => "http://purl.org/dada/schema/0.2#commonProperties" },
  #                  "dada" => { "@id" => "http://purl.org/dada/schema/0.2#" },
  #                  "type" => { "@id" => "http://purl.org/dada/schema/0.2#type" },
  #                  "start" => { "@id" => "http://purl.org/dada/schema/0.2#start" },
  #                  "end" => { "@id" => "http://purl.org/dada/schema/0.2#end" },
  #                  "label" => { "@id" => "http://purl.org/dada/schema/0.2#label" },
  #                  "alveo" => { "@id" => "http://alveo.edu.au/schema/" },
  #                  "ace" => { "@id" => "http://ns.ausnc.org.au/schemas/ace/" },
  #                  "ausnc" => { "@id" => "http://ns.ausnc.org.au/schemas/ausnc_md_model/" },
  #                  "austalk" => { "@id" => "http://ns.austalk.edu.au/" },
  #                  "austlit" => { "@id" => "http://ns.ausnc.org.au/schemas/austlit/" },
  #                  "bibo" => { "@id" => "http://purl.org/ontology/bibo/" },
  #                  "cooee" => { "@id" => "http://ns.ausnc.org.au/schemas/cooee/" },
  #                  "dc" => { "@id" => "http://purl.org/dc/terms/" },
  #                  "foaf" => { "@id" => "http://xmlns.com/foaf/0.1/" },
  #                  "gcsause" => { "@id" => "http://ns.ausnc.org.au/schemas/gcsause/" },
  #                  "ice" => { "@id" => "http://ns.ausnc.org.au/schemas/ice/" },
  #                  "olac" => { "@id" => "http://www.language-archives.org/OLAC/1.1/" },
  #                  "purl" => { "@id" => "http://purl.org/" },
  #                  "rdf" => { "@id" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#" },
  #                  "schema" => { "@id" => "http://schema.org/" },
  #                  "xsd" => { "@id" => "http://www.w3.org/2001/XMLSchema#" }}
  #  }
  # if RDF::URI(url, canonicalize: true) == RDF::URI('https://app.alveo.edu.au/schema/json-ld')
  if false
    remote_document = JSON::LD::API::RemoteDocument.new(url, alveo_schema)
    return block_given? ? yield(remote_document) : remote_document
  else
    JSON::LD::API.documentLoader(url, options, &block)
  end
 }
 loader
end



def main

raw_context = {
"commonProperties" =>{"@id" =>"http://purl.org/dada/schema/0.2#commonProperties"},
"dada" =>{"@id" =>"http://purl.org/dada/schema/0.2#"},
"type" =>{"@id" =>"http://purl.org/dada/schema/0.2#type"},
"start" =>{"@id" =>"http://purl.org/dada/schema/0.2#start"},
"end" =>{"@id" =>"http://purl.org/dada/schema/0.2#end"},
"label" =>{"@id" =>"http://purl.org/dada/schema/0.2#label"},
"alveo" =>{"@id" =>"http://alveo.edu.au/schema/"},
"ace" =>{"@id" =>"http://ns.ausnc.org.au/schemas/ace/"},
"ausnc" =>{"@id" =>"http://ns.ausnc.org.au/schemas/ausnc_md_model/"},
"austalk" =>{"@id" =>"http://ns.austalk.edu.au/"},
"austlit" =>{"@id" =>"http://ns.ausnc.org.au/schemas/austlit/"},
"bibo" =>{"@id" =>"http://purl.org/ontology/bibo/"},
"cooee" =>{"@id" =>"http://ns.ausnc.org.au/schemas/cooee/"},
"dc" =>{"@id" =>"http://purl.org/dc/terms/"},
"foaf" =>{"@id" =>"http://xmlns.com/foaf/0.1/"},
"gcsause" =>{"@id" =>"http://ns.ausnc.org.au/schemas/gcsause/"},
"ice" =>{"@id" =>"http://ns.ausnc.org.au/schemas/ice/"},
"olac" =>{"@id" =>"http://www.language-archives.org/OLAC/1.1/"},
"purl" =>{"@id" =>"http://purl.org/"},
"rdf" =>{"@id" =>"http://www.w3.org/1999/02/22-rdf-syntax-ns#"},
"schema" =>{"@id" =>"http://schema.org/"},
"xsd" =>{"@id" =>"http://www.w3.org/2001/XMLSchema#"},
"ausnc:audience" =>{ "@type"=>"@id"},
"ausnc:communication_setting"=>{ "@type"=>"@id" },
"ausnc:mode"=>{  "@type"=>"@id" },
"ausnc:publication_status"=>{  "@type"=>"@id" },
"ausnc:written_mode"=>{  "@type"=>"@id" },
"ausnc:itemwordcount"=>{ "@type"=>"xsd:integer"},
"dcterms:extent"=>{ "@type"=>"xsd:integer"},
"dcterms:source"=>{  "@type"=>"@id" },
"hcsvlab" => "http://hcsvlab.org/vocabulary/",
"hcsvlab:display_document" => {  "@type"=>"@id" },
"hcsvlab:indexable_document" => {  "@type"=>"@id" },
"ausnc:document" => {"@type" => "@id"},
"ausnc:document" => {"@type" => "foaf:Document"},
"dc:isPartOf"=>{  "@type"=>"@id" },
             }

  context = ["https://app.alveo.edu.au/schema/json-ld",
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
                "dc:isPartOf"=>{  "@type"=>"@id" },
             }]
  frame = {"@context" => context,
           "@type" => "ausnc:AusNCObject",
           "ausnc:document" => {"@type" => "foaf:Document"}}
  rdf_file = "#{File.dirname(__FILE__)}/../spec/files/turtle_example.rdf"
  graph = RDF::Graph.load(rdf_file, :format => :ttl)
  jsonld = JSON.parse(graph.dump(:jsonld, context: context))
  # jsonld = JSON.parse(graph.dump(:jsonld, context: raw_context))
  # json_file = "#{File.dirname(__FILE__)}/../spec/files/json-ld_example_revised.json"
  # graph2 = RDF::Graph.load(json_file, :format => :json_ld)
  # jsonld = JSON.parse(File.open(json_file).read)
  # compact_with_loader(jsonld, context)
  require 'pry'
  binding.pry
end

def compact_with_loader(input, context)
  # alveo_schema = {'@context' => {"commonProperties" => { "@id" => "http://purl.org/dada/schema/0.2#commonProperties" },
  #                  "dada" => { "@id" => "http://purl.org/dada/schema/0.2#" },
  #                  "type" => { "@id" => "http://purl.org/dada/schema/0.2#type" },
  #                  "start" => { "@id" => "http://purl.org/dada/schema/0.2#start" },
  #                  "end" => { "@id" => "http://purl.org/dada/schema/0.2#end" },
  #                  "label" => { "@id" => "http://purl.org/dada/schema/0.2#label" },
  #                  "alveo" => { "@id" => "http://alveo.edu.au/schema/" },
  #                  "ace" => { "@id" => "http://ns.ausnc.org.au/schemas/ace/" },
  #                  "ausnc" => { "@id" => "http://ns.ausnc.org.au/schemas/ausnc_md_model/" },
  #                  "austalk" => { "@id" => "http://ns.austalk.edu.au/" },
  #                  "austlit" => { "@id" => "http://ns.ausnc.org.au/schemas/austlit/" },
  #                  "bibo" => { "@id" => "http://purl.org/ontology/bibo/" },
  #                  "cooee" => { "@id" => "http://ns.ausnc.org.au/schemas/cooee/" },
  #                  "dc" => { "@id" => "http://purl.org/dc/terms/" },
  #                  "foaf" => { "@id" => "http://xmlns.com/foaf/0.1/" },
  #                  "gcsause" => { "@id" => "http://ns.ausnc.org.au/schemas/gcsause/" },
  #                  "ice" => { "@id" => "http://ns.ausnc.org.au/schemas/ice/" },
  #                  "olac" => { "@id" => "http://www.language-archives.org/OLAC/1.1/" },
  #                  "purl" => { "@id" => "http://purl.org/" },
  #                  "rdf" => { "@id" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#" },
  #                  "schema" => { "@id" => "http://schema.org/" },
  #                  "xsd" => { "@id" => "http://www.w3.org/2001/XMLSchema#" }}
  #  }
  alveo_schema = '{"@context":{"commonProperties":{"@id":"http://purl.org/dada/schema/0.2#commonProperties"},"dada":{"@id":"http://purl.org/dada/schema/0.2#"},"type":{"@id":"http://purl.org/dada/schema/0.2#type"},"start":{"@id":"http://purl.org/dada/schema/0.2#start"},"end":{"@id":"http://purl.org/dada/schema/0.2#end"},"label":{"@id":"http://purl.org/dada/schema/0.2#label"},"alveo":{"@id":"http://alveo.edu.au/schema/"},"ace":{"@id":"http://ns.ausnc.org.au/schemas/ace/"},"ausnc":{"@id":"http://ns.ausnc.org.au/schemas/ausnc_md_model/"},"austalk":{"@id":"http://ns.austalk.edu.au/"},"austlit":{"@id":"http://ns.ausnc.org.au/schemas/austlit/"},"bibo":{"@id":"http://purl.org/ontology/bibo/"},"cooee":{"@id":"http://ns.ausnc.org.au/schemas/cooee/"},"dc":{"@id":"http://purl.org/dc/terms/"},"foaf":{"@id":"http://xmlns.com/foaf/0.1/"},"gcsause":{"@id":"http://ns.ausnc.org.au/schemas/gcsause/"},"ice":{"@id":"http://ns.ausnc.org.au/schemas/ice/"},"olac":{"@id":"http://www.language-archives.org/OLAC/1.1/"},"purl":{"@id":"http://purl.org/"},"rdf":{"@id":"http://www.w3.org/1999/02/22-rdf-syntax-ns#"},"schema":{"@id":"http://schema.org/"},"xsd":{"@id":"http://www.w3.org/2001/XMLSchema#"}}}'
  loader = Proc.new{|url, options={}, &block|
    if RDF::URI(url, canonicalize: true) == RDF::URI('https://app.alveo.edu.au/schema/json-ld')
      # remote_document = JSON::LD::API::RemoteDocument.new(url, alveo_schema)
      remote_document = JSON::LD::API::RemoteDocument.new(url, File.read("#{File.dirname(__FILE__)}/../spec/files/alveo.json"))
      # if block_given?
      #   yield(remote_document)
      # else
      #    remote_document
      # end
      block_given? ? yield(remote_document) : remote_document
    else
      JSON::LD::API.documentLoader(url, options, &block)
    end
  }
  compacted = JSON::LD::API.compact(input, context, documentLoader: loader)
  compacted
end

def load_doc(url, options={}, &block)
  alveo_schema = '{"@context":{"commonProperties":{"@id":"http://purl.org/dada/schema/0.2#commonProperties"},"dada":{"@id":"http://purl.org/dada/schema/0.2#"},"type":{"@id":"http://purl.org/dada/schema/0.2#type"},"start":{"@id":"http://purl.org/dada/schema/0.2#start"},"end":{"@id":"http://purl.org/dada/schema/0.2#end"},"label":{"@id":"http://purl.org/dada/schema/0.2#label"},"alveo":{"@id":"http://alveo.edu.au/schema/"},"ace":{"@id":"http://ns.ausnc.org.au/schemas/ace/"},"ausnc":{"@id":"http://ns.ausnc.org.au/schemas/ausnc_md_model/"},"austalk":{"@id":"http://ns.austalk.edu.au/"},"austlit":{"@id":"http://ns.ausnc.org.au/schemas/austlit/"},"bibo":{"@id":"http://purl.org/ontology/bibo/"},"cooee":{"@id":"http://ns.ausnc.org.au/schemas/cooee/"},"dc":{"@id":"http://purl.org/dc/terms/"},"foaf":{"@id":"http://xmlns.com/foaf/0.1/"},"gcsause":{"@id":"http://ns.ausnc.org.au/schemas/gcsause/"},"ice":{"@id":"http://ns.ausnc.org.au/schemas/ice/"},"olac":{"@id":"http://www.language-archives.org/OLAC/1.1/"},"purl":{"@id":"http://purl.org/"},"rdf":{"@id":"http://www.w3.org/1999/02/22-rdf-syntax-ns#"},"schema":{"@id":"http://schema.org/"},"xsd":{"@id":"http://www.w3.org/2001/XMLSchema#"}}}'
  remote_document = nil
  if RDF::URI(url, canonicalize: true) == RDF::URI('https://app.alveo.edu.au/schema/json-ld')
    remote_document = JSON::LD::API::RemoteDocument.new(url, File.read("#{File.dirname(__FILE__)}/../spec/files/alveo.json"))
    if block_given?
      yield(remote_document)
    else
      return remote_document
    end
  else
    JSON::LD::API.documentLoader(url, options, &block)
  end
end

def frame_doc(input, frame)
  JSON::LD::API.frame(input, frame)
end


if __FILE__ == $PROGRAM_NAME
  main
end