require 'spec_helper'

describe Worker do

  let(:options) {
    {work_queue: 'work', error_queue: 'error', client_class: 'BunnyMock'}
  }

  let(:worker) {
    Worker.new(options)
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
      expected = "[{\n  \"error\": \"JSON::ParserError\",\n  \"message\": \"757: unexpected token at 'not a JSON string'\""
      exchange = worker.get_exchange
      exchange.publish(message, routing_key: 'work')
      error_queue = exchange.get_queue(options[:error_queue])
      worker.subscribe
      expect(error_queue.messages.first).to start_with(expected)
    end

  end

end
