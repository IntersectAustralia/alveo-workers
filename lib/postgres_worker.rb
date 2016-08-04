require 'active_record'
require 'activerecord-import'

require_relative 'worker'
require_relative 'models/item'
require_relative 'models/document'
require_relative 'postgres_helper'

class PostgresWorker < Worker

  include PostgresHelper

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
    @activerecord_options = options[:activerecord]
    @batch_options = options[:batch].freeze
    if @batch_options[:enabled]
      @batch = []
      @item_headers = [:uri, :handle, :collection_id, :primary_text_path, :json_metadata, :indexed_at]
      @item_batch = []
      @documents_headers = [:file_name, :file_path, :doc_type, :mime_type, :item_id]
      @documents_batch = []
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
      item_imports = Item.import @item_headers, @item_batch, validate: false
      item_ids = item_imports.ids
      documents = []
      item_ids.each_with_index { |id, i|
        @documents_batch[i].each { |document|
          document << id
          documents << document
        }
      }
      Document.import @documents_headers, documents, validate: false
      @item_batch.clear
      @documents_batch.clear
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
    @batch_mutex.synchronize {
      @item_batch << pg_statement[:item].values
    }
    # @documents_batch << [pg_statement[:documents].first.values]
    document_values = []
    pg_statement[:documents].each { |document|
      document_values << document.values
    }
    @documents_batch << document_values
    if (@item_batch.size >= @batch_options[:size])
      commit_batch
    end

  end

  def create_item(pg_statement)
    item = Item.new(pg_statement[:item])
    item.documents.build(pg_statement[:documents])
    item.save!
  end

end