class SolrWorker < Worker

  # TODO: MonkeyPatch persistent HTTP connections

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    solr_options = options[:solr]
    rabbitmq_options[:work_queue]
    super(rabbitmq_options)
    solr_client_class = Module.const_get(solr_options[:client_class])
    @solr_client = solr_client_class.new(solr_options[:url])
  end

  def process_message(message)
    if message['action'] = 'add'
      add_document(message['document'])
    end
  end

  def add_document(document)
    # require 'pry'
    # binding.pry
    @solr_client.add document
  end

end