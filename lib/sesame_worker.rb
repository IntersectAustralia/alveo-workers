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
    @batch_size = 10000
    @batch_mode = true
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
    @batch << JSON::LD::API.toRdf(message['payload'])
    if (@batch.size >= @batch_size)
      n3_string = RDF::NTriples::Writer.dump(graph, nil, :encoding => Encoding::ASCII)
      @sesame_client.batch_insert_statements(message['collection'], n3_string)
      @batch.clear!
    end
  end

end