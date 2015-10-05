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

    @batch = RDF::Repository.new
    @batch_size = 5000
    @threshold = 5
    @batch_mode = true
    @mutex = Mutex.new
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
      if @batch_mode
        batch_create(message)
      else
        insert_statements(message)
      end
    end
  end

  def insert_statements(message)
    @sesame_client.insert_statements(message['collection'], message['payload'])
  end

  def batch_create(message)
    # TODO: is this in turle or json ld?
    @batch << JSON::LD::API.toRdf(message['payload'])
    # time = Time.now
    if (@batch.size >= @batch_size)
      # @mutex.synchronize {
        # require 'pry'
        # binding.pry
        @sesame_client.insert_statements(message['collection'], @batch.dump(:ttl))
        @batch.clear!
      # }
    end
  end

end