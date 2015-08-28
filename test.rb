require 'bunny'
require 'pry'

options = {host: '172.16.92.170', user: 'solr', pass: 'solr', vhost: '/alveo'}

connection = Bunny.new(options)

connection.start

channel = connection.create_channel

queue = channel.queue('solr')

exchange = channel.default_exchange

queue.subscribe do |delivery_info, metadata, payload|
  puts "delivery_info #{delivery_info}"
  puts "metadata #{metadata}"
  puts "payload #{payload}"
end

def send_msg(msg)
  exchange.publish(msg, :routing_key => queue.name)
end


binding.pry
