require 'bunny'
require 'json'

class Worker

  attr_reader :processed

  def initialize(options)
    @options = options
    bunny_client_class = Module.const_get(@options[:client_class])
    # TODO: clean the options
    @bunny_client = bunny_client_class.new(@options)
    # TODO Maybe move the following to start method
    #      There should also be stop methods to cleanup connections
    # @bunny_client.start
    # @channel = @bunny_client.create_channel
    # @exchange = @channel.direct(options[:exchange])
    # @work_queue = add_queue(options[:work_queue])
    # @error_queue = add_queue(options[:error_queue])
    # @processed = 0
  end

  def add_queue(name)
    queue = @channel.queue(name)
    queue.bind(@exchange, routing_key: name)
    queue
  end

  def get_exchange
    @exchange
  end

  def start
    @bunny_client.start
    @channel = @bunny_client.create_channel
    @exchange = @channel.direct(@options[:exchange])
    @work_queue = add_queue(@options[:work_queue])
    @error_queue = add_queue(@options[:error_queue])
    @processed = 0
    # NOTE: This could be a problem if it starts processing messages before output queues
    # are initialised in the subclasses
    subscribe
  end

  def stop
    @channel.close
    @bunny_client.close
  end

  def subscribe
    # TODO: rename work_queue to consumer_queue
    @work_queue.subscribe do |delivery_info, metadata, payload|
      on_message(payload)
      @processed += 1
    end
  end

  # TODO
  # - add explicit acknowledgements
  # - add 'prefect' (batch) setting
  def on_message(payload)
    begin
      message = JSON.parse(payload)
      process_message(message)
    rescue StandardError => e
      send_error_message(e, payload)
    end
  end

  def process_message(message)
    raise 'Method must be implemented by subclasses'
  end

  def send_error_message(exception, payload)
    error_message = {error: exception.class,
                     message: exception.to_s,
                     backtrace: exception.backtrace}
    error_message = JSON.pretty_generate(error_message)
    error_message = "[#{error_message},\n{\"input\": #{payload}}]"
    @exchange.publish(error_message, routing_key: @error_queue.name)
  end

end