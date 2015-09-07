require_relative 'metadata_helper'

class UploadWorker < Worker

  include MetadataHelper

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
  end

  def process_message(message)
    if message['action'] = 'add item'
      add_item(message['metadata'])
    end
  end

  def add_item(metadata)

  end



end