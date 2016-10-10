require 'bunny'
require 'json'

class AusTalkIngester

  attr_accessor :ingesting
  attr_reader :record_count

  def initialize(options)
    @ingesting = true
    @options = options
    bunny_client_class = Module.const_get(options[:client_class])
    @bunny_client = bunny_client_class.new(options)
    @exchange_name = options[:exchange]
    @error_logger = Logger.new(options[:error_log])
    @upload_queue_name = options[:upload_queue]
  end

  def connect
    @bunny_client.start
    @channel = @bunny_client.create_channel
    @exchange = @channel.direct(@exchange_name, durable: true)
    @upload_queue = add_queue(@upload_queue_name)
    monitor_queues
  end

  def monitor_queues
    @monitor_queues = []
    @options[:monitor].each { |queue|
      @monitor_queues << add_queue(queue)
    }
  end

  def monitor_queues_message_count
    message_count = 0
    @monitor_queues.each { |queue|
      message_count += queue.message_count
    }
    message_count
  end

  def close
    @channel.close
    @bunny_client.close
  end

  def add_queue(name)
    queue = @channel.queue(name, durable: true)
    queue.bind(@exchange, routing_key: name)
    queue
  end

  def set_work(work)
    @work = work
  end

  def process()
    @work.each { |austalk_chunk|
      process_chunk(austalk_chunk)
    }
  end

  def add_document_sizes(austalk_fields)
    austalk_fields['items'].each { |item|
      item['ausnc:document'].each { |document|
        document['alveo:size'] = File.size? document['dc:source']
      }
    }
    austalk_fields
  end

  def process_chunk(austalk_chunk, resume_point=0)
    @record_count = 0
    File.open(austalk_chunk).each { |austalk_record|
      begin
        if @record_count < resume_point
          @record_count += 1
          next
        end
        austalk_fields = JSON.parse(austalk_record.encode('utf-8'))
        austalk_fields = add_document_sizes(austalk_fields)
        properties = {routing_key: @upload_queue.name, headers: {action: 'create'}}
        message = austalk_fields.to_s
        @exchange.publish(message, properties)
        @record_count += 1
        break if !@ingesting
      rescue Exception => e
        # TODO: Error queue instead of log file
        @error_logger.error "#{e.class}: #{e.to_s}\ninput: #{austalk_record}"
      end
    }
  end

end
