require 'json/ld'

module SolrHelper

  def create_solr_document(expanded_json_ld)
    (item_graph, document_graphs) = separate_graphs(expanded_json_ld)
    mapped_fields = map_fields(item_graph, document_graphs)
    generated_fields = generate_fields(item_graph, document_graphs)
    mapped_fields.merge!(generated_fields)
  end

  def separate_graphs(json_ld_hash)
    item_graph = nil
    document_graphs = {}
    json_ld_hash.each { |graph_hash|
      if is_item? graph_hash
        item_graph = graph_hash
      elsif is_document? graph_hash
        document_graphs[graph_hash['@id']] = graph_hash
      end
    }
    [item_graph, document_graphs]
  end

  def generate_fields(item_graph, document_graphs)
    generated_fields = generate_access_rights(item_graph)
    generated_fields[:date_group_facet] = generate_date_group(item_graph)
    generated_fields[:handle] = generate_handle(item_graph)
    generated_fields[:full_text] = generate_full_text(item_graph, document_graphs)
    generated_fields
  end

  def map_fields(item_graph, document_graphs)
    item_fields = map_item_fields(item_graph)
    document_fields = map_document_fields(document_graphs)
    item_fields.merge!(document_fields)
  end

  def map_item_fields(item_graph)
    result = get_default_item_fields
    item_graph.each { |rdf_field, rdf_value|
      value = map_item_value(rdf_field, rdf_value)
      if @rdf_relation_to_facet_map.has_key? rdf_field
        result[@rdf_relation_to_facet_map[rdf_field]] = value
      else
        result.merge!(generate_item_fields(rdf_field, value))
      end
    }
    result
  end

  def map_item_value(rdf_field, rdf_value)
    if is_document_field?(rdf_field)
      value = map_item_documents(rdf_value)
    elsif
      value = extract_unqualified_value(rdf_value)
    end
    value
  end

  def map_item_documents(rdf_value)
    value = []
    rdf_value.each { |doc_value|
      value << extract_unqualified_value(doc_value)
    }
    value
  end

  def map_document_fields(document_graphs)
    result = get_default_document_fields
    document_graphs.each_value { |document|
      @document_field_to_rdf_relation_map.each { |key, value|
        result[key] << extract_value(document[value])
      }
    }
    result
  end

  def generate_item_fields(rdf_predicate, value)
    if !value.is_a? Array
      value = [value]
    end

    # TODO: Handle the case if the rdf_predicate is not in the map
    solr_field = map_rdf_predicate_to_solr_field(rdf_predicate)
    # NOTE: Is there any reason that singular values are stored in arrays?
    #       investigated whether there was a reason behind this originally
    { "#{solr_field}_sim" => value, "#{solr_field}_tesim" => value }
  end

  def generate_full_text(item_graph, document_graphs)
    document_uri = extract_value(item_graph[@mapped_fields[:indexable_document]])
    document_graph = document_graphs[document_uri]
    file_uri = extract_value(document_graph[@mapped_fields[:source]])
    file_path = URI.parse(file_uri).path
    full_text = File.open(file_path).read
    normalise_whitespace(full_text)
  end

  def generate_access_rights(item_graph)
    data_owner = get_data_owner(item_graph)
    collection = get_collection(item_graph)
    if data_owner.nil? or collection.nil?
      raise 'Insufficient metadata to generate access rights'
    end
    build_access_rights_map(data_owner, collection)
  end

  def build_access_rights_map(person, group)
    {
        discover_access_person_ssim: person,
        read_access_person_ssim: person,
        edit_access_person_ssim: person,
        discover_access_group_ssim: "#{group}-discover",
        read_access_group_ssim: "#{group}-read",
        edit_access_group_ssim: "#{group}-edit",
    }
  end

  def map_rdf_predicate_to_solr_field(uri)
    uri = expand_collapsed_uri(uri)
    (namespace, term) = get_qualified_term(uri)
    solr_prefix = @rdf_ns_to_solr_prefix_map[namespace]
    solr_prefix + term
  end

  def expand_collapsed_uri(uri)
    if @rdf_collapsed_term_map.has_key? uri
      uri = @rdf_collapsed_term_map[uri]
    end
    uri
  end

  def generate_handle(item_graph)
    collection = get_collection(item_graph)
    identifier = get_identifier(item_graph)
    if collection.nil? || identifier.nil?
      raise 'Insufficient metadata to generate item handle'
    end
    "#{collection}:#{identifier}"
  end

  def extract_value(value)
    result = value
    while result.is_a?(Hash) or result.is_a?(Array) do
      if result.is_a?(Hash)
        result = result.values.first
      else
        result = result.first
      end
    end
    normalise_whitespace(result)
  end

  # TODO
  # refactor these config methods
  def set_solr_config(config)
    set_mapped_fields(config['mapped_fields'])
    set_rdf_relation_to_facet_map(config['rdf_relation_to_facet_map'])
    set_rdf_ns_to_solr_prefix_map(config['rdf_ns_to_solr_prefix_map'])
    set_document_field_to_rdf_relation_map(config['document_field_to_rdf_relation_map'])
    set_rdf_collapsed_term_map(config[:rdf_collapsed_term_map])
  end

  # TODO: Following methods are mainly used to ease testing
  #       look at getting rid of them
  def set_rdf_collapsed_term_map(rdf_collapsed_term_map)
    @rdf_collapsed_term_map = rdf_collapsed_term_map
  end

  # TODO
  # refactor these config methods
  def set_mapped_fields(mapped_fields)
    @mapped_fields = mapped_fields
  end

  # TODO
  # refactor these config methods
  def set_rdf_relation_to_facet_map(rdf_relation_to_facet_map)
    @rdf_relation_to_facet_map = rdf_relation_to_facet_map
  end

  # TODO
  # refactor these config methods
  def set_document_field_to_rdf_relation_map(document_field_to_rdf_relation_map)
    @document_field_to_rdf_relation_map = document_field_to_rdf_relation_map
  end

  # TODO
  # refactor these config methods
  def set_rdf_ns_to_solr_prefix_map(rdf_ns_to_solr_prefix_map)
    @rdf_ns_to_solr_prefix_map = rdf_ns_to_solr_prefix_map
  end

  def generate_date_group(item_graph)
    created_field = extract_value(item_graph[@mapped_fields['created_field']])
    date_group(created_field)
  end

  ##
  # call-seq:
  #   date_group('6 September 1986') => '1980 - 1989'
  #   date_group('6 September 1986', 20) => '1980 - 1999'
  #
  # Takes the year from a `dc:created` string and returns the range
  # that it falls within, as specified by optional resolution parameter

  def date_group(created_field, resolution=10)
    result = 'Unknown'
    begin
      year = extract_year(created_field)
      increment = year / resolution
      range_start = increment * resolution
      range_end = range_start + resolution - 1
      result = "#{range_start} - #{range_end}"
    rescue StandardError => e
      if defined? self.send_error_message
        send_error_message(e, created_field)
      end
    end
    result
  end

  ##
  # call-seq:
  #   extract_year('6 September 1986') => 1986
  #   extract_year('Phase I fall') => 'Unknown'
  #
  # Extracts the year from a dc:created string. Handles the following examples
  #
  # * "1913?"
  # * "30/10/93"
  # * "96/05/17"
  # * "7-11/11/94"
  # * "17&19/8/93"
  # * "2012-03-07"
  # * "August 2000"
  # * "6 September 1986"
  # * "4 Spring 1986"
  # * "Phase I fall"

  def extract_year(created_field)
    created_field.chomp!('?')
    date_array = created_field.split(/[\-\/\&\s]/)
    begin
      candidate = Integer date_array.first
      if candidate > 31
        year = candidate
      else
        year = Integer date_array.last
      end
    rescue ArgumentError
      year = Integer date_array.last
    end
    year = year + 1900 if year < 100
    year
  end

  def graph_type(graph_hash)
    extract_unqualified_value(graph_hash['@type'])
  end

  def get_qualified_term(uri)
    term = get_unqualified_term(uri)
    namespace = uri[0..-(term.length+1)]
    [namespace, term]
  end

  def get_unqualified_term(uri)
    result = uri
    if uri.is_a? String
      # TODO: Maybe raise an error here if the URI is invalid?
      result = uri.split('/').last
    end
    result
  end

  def normalise_whitespace(value_string)
    result = value_string
    if result.is_a? String
      result = result.gsub(/\s+/, ' ').strip
    end
    result
  end

  def get_identifier(item_graph)
    extract_unqualified_value(item_graph[@mapped_fields['identifier_field']])
  end

  def get_collection(item_graph)
    extract_unqualified_value(item_graph[@mapped_fields['collection_field']])
  end

  def extract_unqualified_value(graph)
    value = extract_value(graph)
    get_unqualified_term(value)
  end

  def get_data_owner(item_graph)
    data_owner = @mapped_fields['default_data_owner']
    data_owner_field = @mapped_fields['data_owner_field']
    if item_graph[data_owner_field]
      data_owner = extract_value(item_graph[data_owner_field])
    end
    data_owner
  end

  def get_default_item_fields
    default_item_fields = {}
    @rdf_relation_to_facet_map.each_value { |value|
      default_item_fields[value] = 'unspecified'
    }
    default_item_fields
  end

  def get_default_document_fields
    default_document_fields = {}
    @document_field_to_rdf_relation_map.each_key { |key|
      default_document_fields[key] = []
    }
    default_document_fields
  end

  def is_document?(graph_hash)
    graph_type(graph_hash) == 'Document'
  end

  def is_item?(graph_hash)
    graph_type(graph_hash) == 'AusNCObject'
  end

  def is_document_field?(field)
    field == 'http://ns.ausnc.org.au/schemas/ausnc_md_model/document'
  end

  # def send_error_message(e, input)
  #   if @error_messanger
  #     @error_messanger.send_error_message(e, input)
  #   end
  # end

end
