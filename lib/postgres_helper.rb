require_relative 'solr_helper'

module PostgresHelper

  # TODO hacky, refactor methods to common module
  include SolrHelper

  @@MIME_TYPE = Hash.new('application/octet-stream').merge({
      '.txt' => 'text/plain',
      '.xml' => 'text/xml',
      '.jpg' => 'image/jpeg',
      '.tif' => 'image/tif',
      '.mp3' => 'audio/mpeg',
      '.wav' => 'audio/wav',
      '.avi' => 'video/x-msvideo',
      '.mov' => 'video/quicktime',
      '.mp4' => 'video/mp4',
      '.doc' => 'application/msword',
      '.pdf' => 'application/pdf'
  }).freeze

  # TODO: It supposedly possible to supply a cusotm documentLoader to
  #       JSON::LD::API calls, which can supply cached remote contexts
  #       to avoid HTTP requests every time
  @@CONTEXT = {
      "ace" =>{"@id" =>"http://ns.ausnc.org.au/schemas/ace/"},
      "alveo" =>{"@id" =>"http://alveo.edu.au/schema/"},
      "ausnc" =>{"@id" =>"http://ns.ausnc.org.au/schemas/ausnc_md_model/"},
      "austalk" =>{"@id" =>"http://ns.austalk.edu.au/"},
      "austlit" =>{"@id" =>"http://ns.ausnc.org.au/schemas/austlit/"},
      "bibo" =>{"@id" =>"http://purl.org/ontology/bibo/"},
      "commonProperties" =>{"@id" =>"http://purl.org/dada/schema/0.2#commonProperties"},
      "cooee" =>{"@id" =>"http://ns.ausnc.org.au/schemas/cooee/"},
      "dada" =>{"@id" =>"http://purl.org/dada/schema/0.2#"},
      "dc" =>{"@id" =>"http://purl.org/dc/terms/"},
      "end" =>{"@id" =>"http://purl.org/dada/schema/0.2#end"},
      "foaf" =>{"@id" =>"http://xmlns.com/foaf/0.1/"},
      "gcsause" =>{"@id" =>"http://ns.ausnc.org.au/schemas/gcsause/"},
      "hcsvlab" => {"@id" => "http://hcsvlab.org/vocabulary/"},
      "ice" =>{"@id" =>"http://ns.ausnc.org.au/schemas/ice/"},
      "label" =>{"@id" =>"http://purl.org/dada/schema/0.2#label"},
      "olac" =>{"@id" =>"http://www.language-archives.org/OLAC/1.1/"},
      "purl" =>{"@id" =>"http://purl.org/"},
      "rdf" =>{"@id" =>"http://www.w3.org/1999/02/22-rdf-syntax-ns#"},
      "schema" =>{"@id" =>"http://schema.org/"},
      "start" =>{"@id" =>"http://purl.org/dada/schema/0.2#start"},
      "type" =>{"@id" =>"http://purl.org/dada/schema/0.2#type"},
      "xsd" =>{"@id" =>"http://www.w3.org/2001/XMLSchema#"},
      "ausnc:audience" =>{ "@type"=>"@id"},
      "ausnc:communication_setting"=>{ "@type"=>"@id" },
      "ausnc:document" => {"@type" => "@id"},
      "ausnc:itemwordcount"=>{ "@type"=>"xsd:integer"},
      "ausnc:mode"=>{  "@type"=>"@id" },
      "ausnc:publication_status"=>{  "@type"=>"@id" },
      "ausnc:written_mode"=>{  "@type"=>"@id" },
      "dc:isPartOf"=>{  "@type"=>"@id" },
      "dcterms:extent"=>{ "@type"=>"xsd:integer"},
      "dcterms:source"=>{  "@type"=>"@id" },
      # TOOD: Map the following from hcsvlab to alveo
      "hcsvlab:display_document" => {  "@type"=>"@id" },
      "hcsvlab:indexable_document" => {  "@type"=>"@id" }
      }.freeze


  # TODO: Metadata helper?
  @@primary_text = 'http://hcsvlab.org/vocabulary/display_document'
  @@source = 'http://purl.org/dc/terms/source'
  @@identifier = 'http://purl.org/dc/terms/identifier'
  @@type = 'http://purl.org/dc/terms/type'

  @@URI_BASE = 'https://app.alveo.edu.au/catalog/'

  def create_pg_statement(expanded_json_ld)
    (item_graph, document_graphs) = separate_graphs(expanded_json_ld)
    
    # item[:annotation_path] = nil
    item = extract_item_info(item_graph, document_graphs)
    documents = extract_documents_info(document_graphs)
    {item: item, documents: documents}
  end

  def extract_item_info(item_graph, document_graphs)
    item = {}
    item[:uri] = generate_uri(item_graph)
    item[:handle] = generate_handle(item_graph)
    item[:primary_text_path] = get_primary_text_path(item_graph, document_graphs)
    item[:json_metadata] = build_json_metadata(item_graph, document_graphs)
    item
  end

  def extract_documents_info(document_graphs)
    documents = []
    document_graphs.each_value { |document_graph|
      documents << extract_document_info(document_graph)
    }
    documents
  end

  def extract_document_info(document_graph)
    doc_fields = {}
    doc_fields[:file_name] = extract_value(document_graph[@@identifier])
    doc_fields[:file_path] = URI.parse(extract_value(document_graph[@@source])).path
    doc_fields[:doc_type] = extract_value(document_graph[@@type])
    doc_fields[:mime_type] = get_mime_type(doc_fields[:file_name])
    doc_fields
  end

  def get_mime_type(file_path)
    @@MIME_TYPE[File.extname(file_path)]
  end

  def get_primary_text_path(item_graph, document_graphs)
    primary_text_path = nil
    document_uri = extract_value(item_graph[@@primary_text])
    document_graph = document_graphs[document_uri]
    extract_value(document_graph[@@source])
  end

  # TODO: A number of generate methods use the same fields,
  #       it might be worth creating an intermediate mapping first,
  #       then mapping to the final fields
  def generate_uri(item_graph)
    collection = get_collection(item_graph)
    identifier = get_identifier(item_graph)
    if collection.nil? || identifier.nil?
      raise 'Insufficient metadata to generate item uri'
    end
    "#{@@URI_BASE}#{collection}/#{identifier}"
  end

  def build_json_metadata(item_graph, document_graphs)
    json_metadata = {
      catalog_url: '', #ITEM uri
      metadata: create_item_metadata(item_graph),
      primary_text_url: get_primary_text_path(item_graph, document_graphs),
      annotations_url: '',
      documents: document_graphs, #compact doc graphs too
      documentsLocations: map_document_locations(document_graphs)
    }
    json_metadata.to_json
  end

  def create_item_metadata(item_graph)
    # TODO: Replace hcsvlab 'ns' to 'alveo'
    #       this might perhaps best be on by the ingester/upload workers
    # generate all the require ausnc display fields
    item_metadata = JSON::LD::API.compact(item_graph, @@CONTEXT)
    item_metadata.delete('@context')
    item_metadata
  end

  def map_document_locations(document_graphs)
    documentsLocations = {}
    document_graphs.each_value { |document_graph|
      # TODO: duplication of effort here and extract_document_info
      file_name = extract_value(document_graph[@@identifier])
      file_path = extract_value(document_graph[@@source])
      documentsLocations[file_name] = file_path
    }
    documentsLocations
  end

end