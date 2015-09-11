require_relative 'worker'
require_relative 'metadata_helper'
require_relative 'solr_helper'

class UploadWorker < Worker

  include MetadataHelper
  include SolrHelper

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
    set_solr_config(options[:solr])
    # TODO: refactor this to helper method in parent class
    @producer_queue = add_queue(options[:production_queue])
  end

  def process_message(message)
    if message['action'] = 'add item'
      add_item(message['metadata'])
    end
  end

  def add_item(metadata)
    expanded_json_ld = expand_json_ld(metadata)
    solr_document = create_solr_document(expanded_json_ld)
    # TODO: Move action type to message header
    # message = "\"action\": \"add\", \"document\": #{solr_document}"
    # TODO: extract to message builder utility class
    message = "{\"action\": \"add\", \"document\": #{solr_document.to_json}}"
    @exchange.publish(message, routing_key: 'solr')
  end

end