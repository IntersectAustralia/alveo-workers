require 'rdf'
require 'rdf/turtle'

require_relative 'worker'
require_relative 'sesame_client'

class SesameWorker < Worker

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
    sesame_client_class = Module.const_get(options[:client_class])
    @sesame_client = sesame_client_class.new(options)
    @batch_options = options[:batch].freeze
    if @batch_options[:enabled]
      @batch = RDF::Repository.new
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

  def close
    super
    @sesame_client.close
  end

  def connect
    super
  end

  def process_message(headers, message)
    if headers['action'] == 'create'
      if @batch_options[:enabled]
        batch_create(message)
      else
        insert_statements(message)
      end
    end
  end

  def commit_batch
    @batch_mutex.synchronize {
      n3_string = RDF::NTriples::Writer.dump(@batch, nil, :encoding => Encoding::ASCII)
      @sesame_client.batch_insert_statements(@collection, n3_string)
      @batch.clear!
    }
  end

  def insert_statements(message)
    @sesame_client.insert_statements(@collection, message['payload'])
  end

  def batch_create(message)
    # TODO: This is flawed - if multiple collections are processed
    # at the same time, it can result in statements being inserted
    # into the wrong collection. It may be better to maintain a hash
    # of batches keyed on collections, e.g. {'collection' => []}
    @collection = message['collection']
    @batch << JSON::LD::API.toRdf(message['payload'])
    if (@batch.size >= @batch_options[:size])
      commit_batch
    end
  end

end