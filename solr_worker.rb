class SolrWorker


  def initialize(options, connection_class)
    super(options, connection_class)
  end

  def process_message(message)
    if message[:action] = 'index'
      index_item(message[:content])
    end
  end

  def index_item(content)

  end

end