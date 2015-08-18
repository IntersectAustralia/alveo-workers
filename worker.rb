require 'bunny'

class Worker

    def initialize(inqueue_name, outqueue_name)
        connection = Bunny.new
        connection.start
        channel = connection.create_channel
        @inqueue  = channel.queue(inqueue_name, :auto_delete => true)
        @exchange  = channel.default_exchange
        @outqueue_name = outqueue_name
    end    

    def connect


    end
    
    def subscribe
        @inqueue.subscribe do |delivery_info, metadata, payload|
          puts "Received #{payload}"
        end
    end

    def publish(message)
        @exchange.publish(message, routing_key: @outqueue_name)
    end

end


