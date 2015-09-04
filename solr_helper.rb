module SolrHelper

  def create_solr_document()

  end

  def map_facet_fields(json_ld_hash)
    @rdf_context_map = json_ld_hash['@context']
    item_graph = nil
    document_graphs = []
    json_ld_hash['@graph'].each { |graph_hash|
      if is_item? graph_hash
        item_graph = graph_hash
      elsif is_document? graph_hash
        document_graphs << graph_hash
      end
    }
    map_item_fields item_graph
    map_document_fields document_graphs
    result
  end

  def resolve_context(rdf_predicate)
    result = rdf_predicate
    if !~ /^@/
      predicate_components = rdf_predicate.split(':')
      rdf_prefix = predicate_components.first.to_sym
      @rdf_context_map[rdf_prefix] + predicate_components.last
    end
    result
  end

  def map_item_fields(item_graph)
    result = get_default_item_fields
    graph_hash.each { |key, value|
      if @facet_field_map.has_key? key
        result[facet_field_map[key]] = value
      else
        result.merge(generate_item_fields(key, value))
      end
    }
    result
  end

  def map_document_fields(document_graphs)
    result = get_default_document_fields
    document_graphs.each { |document|
      @rdf_relation_to_document_field_map.each { |rdf_relation|
        
      }
    }
    result
  end

  def generate_item_fields(rdf_predicate, value)
    solr_field = map_rdf_predicate_to_solr_field(rdf_predicate)
    solr_value = extract_value(value)
    { "#{solr_field}_ssim": value, "#{solr_field}_tesim": value }
  end

  # TODO rework this
  def map_rdf_predicate_to_solr_field(rdf_predicate)
    predicate_components = rdf_predicate.split(':')
    rdf_prefix = predicate_components.first.to_sym
    solr_prefix = @rdf_ns_to_solr_prefix_map[@rdf_context_map[rdf_prefix]]
    solr_prefix + predicate_components.last
  end


  def extract_value(value)
    if value.is_a? Hash
      result = value[:@id]
      if result !~ /^\w+?\:\/{2}/ # URI test
        result = result.split(':').last
      end
    else
      result = value
    end
    result
  end

  ##
  # Sets  the rdf_relation_to_facet_map, which should be a Hash of key-value
  # pairs which map from the JSON-LD relation key to the Solr document
  # facet value. e.g.
  #
  # 'dcterms:isPartOf': collection_name_facet
  #

  def set_rdf_relation_to_facet_map(rdf_relation_to_facet_map)
    @rdf_relation_to_facet_map = rdf_relation_to_facet_map
    @default_item_fields = {}
    rdf_relation_to_facet_map.each_value { |value|
      @default_item_fields[value] = 'unspecified'
    }
  end

  def set_rdf_relation_to_document_field_map(rdf_relation_to_document_field_map)
    @rdf_relation_to_document_field_map = rdf_relation_to_document_field_map
    @default_document_fields = {}
    rdf_relation_to_document_field_map.each_value { |value|
      @default_document_fields[value] = []
    }
  end

  def set_rdf_ns_to_solr_prefix_map(rdf_ns_to_solr_prefix_map)
    @rdf_ns_to_solr_prefix_map = rdf_ns_to_solr_prefix_map
  end

  ##
  # call-seq:
  #   date_group('6 September 1986') => '1980 - 1989'
  #   date_group('6 September 1986', 20) => '1980 - 1999'
  #
  # Takes the year from a `dc:created` string and returns the range
  # that it falls within, as specified by optional resolution parameter

  def date_group(dc_created_string, resolution=10)
    result = 'Unknown'
    begin
      year = extract_year(dc_created_string)
      increment = year / resolution
      range_start = increment * resolution
      range_end = range_start + resolution - 1
      result = "#{range_start} - #{range_end}"
    rescue ArgumentError
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

  def extract_year(dc_created_string)
    dc_created_string.chomp!('?')
    date_array = dc_created_string.split(/[\-\/\&\s]/)
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
    result = 'Unknown'
    if graph_hash['@type'] == 'ausnc:AusNCObject'
      result = 'Item'
    elsif graph_hash['@type'] == 'foaf:Document'
      result = 'Document'
    end
    result
  end

  def get_default_item_fields
    @default_item_fields.clone
  end

  def get_default_document_fields
    @default_document_fields.clone
  end

  def is_document?(graph_hash)
    graph_type(graph_hash) == 'Document'
  end

  def is_item?(graph_hash)
    graph_type(graph_hash) == 'Item'
  end

end