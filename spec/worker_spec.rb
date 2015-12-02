require 'spec_helper'

describe Worker do

  before(:all) do
    @options = {work_queue: 'work', error_queue: 'error', client_class: 'BunnyMock'}
    @worker = Worker.new(@options)
    @worker.connect
    @exchange = @worker.instance_variable_get(:@exchange)
  end

  describe '#on_message' do

    it 'should receive messages' do
      message = 'Message 1'
      expect(@worker).to receive(:on_message).with(anything(), message)
      @exchange.publish(message, routing_key: 'work')
      @worker.start
    end

    it 'should parse json messages' do
      message = '{"message": "some message"}'
      expected = {'message' => 'some message'}
      expect(@worker).to receive(:process_message).with(anything(), expected)
      @exchange.publish(message, routing_key: 'work')
      @worker.start
    end

    it 'sends errors to the error queue' do
      message = 'not a JSON string'
      expected = "[{\n  \"error\": \"JSON::ParserError\",\n  \"message\": \"757: unexpected token at 'not a JSON string'\""
      @exchange.publish(message, routing_key: 'work')
      error_queue = @exchange.get_queue(@options[:error_queue])
      @worker.start
      expect(error_queue.messages.first).to start_with(expected)
    end

  end

end
