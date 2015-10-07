require 'rsolr'
require_relative 'worker'

class SolrWorker < Worker

  # TODO:
  #   - MonkeyPatch persistent HTTP connections
  #   - Implement commit strategy
  #   - Implement batching

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
    solr_client_class = Module.const_get(options[:client_class])
    @solr_client = solr_client_class.connect(url: options[:url])

    @batch_options = options[:batch].freeze
    if @batch_options[:enabled]
      @batch = []
      @batch_mutex = Mutex.new
    end
  end

  # TODO: this could possible be refactored to super class
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
  end

  def process_message(headers, message)
    if headers['action'] == 'create'
      if @batch_options[:enabled]
        batch_create(message['document'])        
      else
        add_documents(message['document'])
      end
    end
  end


  def commit_batch
    @batch_mutex.synchronize {
      add_documents(@batch)
      @batch.clear
    }
  end

  def add_documents(documents)
    response = @solr_client.add(documents)
    status = response['responseHeader']['status']
    if status != 0
      raise "Solr returned an unexpected status: #{status}"
    end
    @solr_client.commit
  end

  def batch_create(document)
    @batch << document
    if (@batch.size >= @batch_options[:size])
      commit_batch
    end
  end

end