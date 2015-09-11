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
  end

  def process_message(message)
    if message['action'] = 'add item'
      add_item(message['metadata'])
    end
  end

  def add_item(metadata)
    expanded_json_ld = expand_json_ld(metadata)
    solr_document = create_solr_document(expanded_json_ld)
    message = "'action': 'add', 'document': #{solr_document}"
    @exchange.publish(message, routing_key: @work_queue)
  end

end