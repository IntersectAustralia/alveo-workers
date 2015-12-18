require 'active_record'
require 'activerecord-import'

require_relative 'worker'
require_relative 'models/item'
require_relative 'models/document'
# require_relative 'models/collection'
require_relative 'new_postgres_helper'

class PostgresWorker < Worker

  include NewPostgresHelper

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
    @activerecord_options = options[:activerecord]
    @batch_options = options[:batch].freeze
    if @batch_options[:enabled]
      @batch = []

      @batch_mutex = Mutex.new
    end
  end

  def start_batch_monitor
    @batch_monitor = Thread.new {
      loop {
        sleep @batch_options[:timeout]
        commit_batch
      }
    }
  end

  def start
    super
    if @batch_options[:enabled]
      start_batch_monitor
    end
  end

  def stop
    super
    if @batch_options[:enabled]
      @batch_monitor.kill
      commit_batch
    end
  end

  def connect
    super
    # TODO: change this to a connection pool perhaps
    ActiveRecord::Base.establish_connection(@activerecord_options)
  end

  def close
    super
    ActiveRecord::Base.connection.close
  end

  def commit_batch
    @batch_mutex.synchronize {
      Item.import(@batch)
      @batch.clear
    }
  end

  def process_message(headers, message)
    if headers['action'] == 'create'
      pg_statement = create_pg_statement(message)
      if @batch_options[:enabled]
        batch_create(pg_statement)
      else
        create_item(pg_statement)
      end
    end
  end

  def batch_create(pg_statement)
    # TODO: change it array import method and turn off validations to
    # maximise import speed, see:
    #
    # https://github.com/zdennis/activerecord-import/wiki/Examples
    # require 'pry'
    # binding.pry
    # TODO: Not currently hanndling associations on mass import
    # will have to mass import items first, then assign the returned
    # ids to the documents
    #
    item = Item.new(pg_statement[:item])
    item.documents.build(pg_statement[:documents])
    item.save
    # @batch << item
    # if (@batch.size >= @batch_options[:size])
    #   commit_batch
    # end
  end

  def create_item(pg_statement)
    item = Item.new(pg_statement[:item])
    item.documents.build(pg_statement[:documents])
    item.save!
  end

end