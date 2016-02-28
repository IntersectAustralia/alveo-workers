$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'bunny'

def main(options)
  @options = options
  @bunny_client = Bunny.new(options)
  connect
  @queues = []
  options[:monitor].each { |queue|
    @queues << add_queue(queue)
  }
end

def add_queue(name)
  queue = @channel.queue(name)
  queue.bind(@exchange, routing_key: name)
  queue
end

def get_message_count
  message_count = 0
  @queues.each { |queue|
    message_count += queue.message_count
    p queue
  }
  message_count
end

def close
  @channel.close
  @bunny_client.close
end

def connect
  @bunny_client.start
  @channel = @bunny_client.create_channel
  @exchange = @channel.direct(@options[:exchange])
end


if __FILE__ == $PROGRAM_NAME
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config[:ingester])
end