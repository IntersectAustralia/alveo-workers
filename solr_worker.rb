require 'bunny'
require 'json'

class SolrWorker

  def initialize(options, connection_class=Bunny)
    connection = connection_class.new(options)
    connection.start
    channel = connection.create_channel
    @exchange = channel.default_exchange
    @queue = channel.queue(options[:queue])
    @queue.bind(@exchange)
  end

  def get_exchange
    @exchange
  end

  def subscribe
    @queue.subscribe do |delivery_info, metadata, payload|
      on_message(payload)
    end
  end

  def on_message(payload)
    message = JSON.parse(payload)
    if message[:action] = 'index'
      index_item()
    end
  end

  def index_item()

  end


end