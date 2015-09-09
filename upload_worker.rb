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
    solr_document = create_solr_document(metadata)
    message = "'action': 'add', 'document': #{solr_document}"
    @exchange.publish(message, routing_key: @work_queue)
  end

end