require 'active_record'

require_relative 'worker'
require_relative 'models/item'
require_relative 'models/document'

class PostgresWorker < Worker

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
    @activerecord_options = options[:activerecord]

    @batch = []
    @batch_size = 500
    @batch_mode = true
  end

  def connect
    super
    ActiveRecord::Base.establish_connection(@activerecord_options)
  end

  def close
    super
    ActiveRecord::Base.connection.close
  end

  def process_message(headers, message)
    if headers['action'] == 'create'
      if @batch_mode
        batch_create(message['payload'])
      else
        create_item(message['payload'])
      end
    end
  end

  def batch_create(payload)
    item = Item.new(payload['item'])
    item.documents.build(payload['documents'])
    # TODO: use activerecord-import gem
    @batch << item
    if (@batch.size >= @batch_size)
      Item.import(@batch)
      @batch.clear
    end
  end

  def create_item(payload)
    item = Item.new(payload['item'])
    item.documents.build(payload['documents'])
    item.save!
  end

end