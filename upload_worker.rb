require_relative 'metadata_helper'

class UploadWorker < Worker

  include MetadataHelper

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
    set_solr_config(options[:solr])
  end

  def process_message(message)
    if message['action'] = 'add item'
      add_item(message['metadata'])
    end
  end

  def add_item(metadata)
    expanded_metadata = expand_json_ld(metadata)

  end

  def set_solr_config(solr_config)
    set_rdf_relation_to_facet_map
    set_rdf_ns_to_solr_prefix_map
    set_document_field_to_rdf_relation_map
    set_default_data_owner
  end


end