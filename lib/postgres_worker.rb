require 'active_record'
require 'activerecord-import'

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
    @batch_mutex = Mutex.new
  end

  def start_batch_monitor(timeout)
    @batch_monitor = Thread.new {
      loop {
        sleep timeout
        @batch_mutex.synchronize {
          Item.import(@batch)
          @batch.clear
        }
      }
    }
  end

  def start
    super
    if @batch_mode
      start_batch_monitor(15)
    end
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
    # TODO: Add collection relation
    item = Item.new(payload['item'])
    item.documents.build(payload['documents'])
    @batch << item
    if (@batch.size >= @batch_size)
      @batch_mutex.synchronize {
        Item.import(@batch)
        @batch.clear
      }
    end
  end

  def create_item(payload)
    item = Item.new(payload['item'])
    item.documents.build(payload['documents'])
    item.save!
  end

end