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

    @batch = []
    @batch_size = 500
    @threshold = 5
    @batch_mode = true
    @mutex = Mutex.new
  end

  def close
    super
    @solr_client.commit
  end

  def process_message(headers, message)
    if headers['action'] == 'create'
      if @batch_mode
        batch_create(message['document'])        
      else
        add_documents(message['document'])
      end
    end
  end

  def add_documents(documents)
    response = @solr_client.add(documents)
    status = response['responseHeader']['status']
    if status != 0
      raise "Solr returned an unexpected status: #{status}"
    end
    @solr_client.commit
    p 'solr commit'
  end

  def batch_create(document)
    @mutex.synchronize {
      @batch << document
      if (@batch.size >= @batch_size)
        add_documents(@batch)
        @batch.clear
      end
      }
  end

end