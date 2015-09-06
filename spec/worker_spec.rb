require 'spec_helper'

describe Worker do

  let(:worker) {
    Worker.new({work_queue: 'work', error_queue: 'error'}, BunnyMock)
  }

  describe '#on_message' do

    it 'should receive messages' do
      message = 'Message 1'
      exchange = worker.get_exchange
      expect(worker).to receive(:on_message).with(message)
      exchange.publish(message, routing_key: 'work')
      worker.subscribe
    end

    it 'should parse json messages' do
      message = '{"action": "do something"}'
      expected = {'action' => 'do something'}
      exchange = worker.get_exchange
      expect(worker).to receive(:process_message).with(expected)
      exchange.publish(message, routing_key: 'work')
      worker.subscribe
    end

    it 'sends errors to the error queue' do
      message = 'not a JSON string'
      expected = ['{"error":"JSON::ParserError","message":"757: unexpected token at \'not a JSON string\'"}']
      exchange = worker.get_exchange
      error_queue = BunnyMock::Queue.new 'error'
      error_queue.bind(exchange)
      exchange.publish(message, routing_key: 'work')
      worker.subscribe
      expect(error_queue.messages).to eq(expected)
    end

  end

end
