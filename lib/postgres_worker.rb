require 'active_record'

require_relative 'worker'
require_relative 'models/item'
require_relative 'models/document'

class PostgresWorker < Worker

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
    @activerecord_options = options[:activerecord]
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
      create_item(message['payload'])
    end
  end

  def create_item(payload)
    item = Item.new(payload['item'])
    item.documents.build(payload['documents'])
    item.save!
  end

end