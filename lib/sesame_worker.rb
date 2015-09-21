require_relative 'worker'
require_relative 'sesame_client'

class SesameWorker < Worker

  def initialize(options)
    rabbitmq_options = options[:rabbitmq]
    super(rabbitmq_options)
    sesame_client_class = Module.const_get(options[:client_class])
    @sesame_client = sesame_client_class.new(options)
  end

  def stop
    super
    @sesame_client.close
  end

  def process_message(message)
    if message['action'] = 'add'
      insert_statements(message)
    end
  end

  def insert_statements(message)
    @sesame_client.insert_statements(message['collection'], message['payload'])
  end

end