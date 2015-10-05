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
  end

  def close
    super
    @solr_client.commit
  end

  def process_message(headers, message)
    if headers[:action] == 'create'
      add_document(message['document'])
    end
  end

  def add_document(document)
    response = @solr_client.add(document)
    status = response['responseHeader']['status']
    if status != 0
      raise "Solr returned an unexpected status: #{status}"
    end
  end

end