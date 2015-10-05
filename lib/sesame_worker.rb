require_relative 'worker'
require_relative 'sesame_client'

class SesameWorker < Worker

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
    sesame_client_class = Module.const_get(options[:client_class])
    @sesame_client = sesame_client_class.new(options)

    @batch = []
    @batch_size = 500
    @last_batch = Time.now
    @threshold = 3
  end

  def close
    super
    @sesame_client.close
  end

  def process_message(headers, message)
    if headers[:action] == 'create'
      insert_statements(message)
    end
  end

  def insert_statements(message)
    # @batch << message
    # time = Time.now
    # if (@batch.size == @batch_size) or ((@last_batch - time) > @threshold)

    # end
    @sesame_client.insert_statements(message['collection'], message['payload'])
  end

end