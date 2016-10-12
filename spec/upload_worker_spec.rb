require 'spec_helper'

describe UploadWorker do

  before(:all) do
    @options = {
      rabbitmq: {
        client_class: 'BunnyMock',
        work_queue: 'upload'
      },
      solr_queue: 'solr_queue',
      sesame_queue: 'sesane_queue',
      postgres_queue: 'postgres_queue'
    }
    @upload_worker = UploadWorker.new(@options)
    @upload_worker.connect
    @exchange = @upload_worker.instance_variable_get(:@exchange)
  end

  describe '#create_item' do

    it 'Adds messages to Solr, Sesame, and Postgres queues' do
      example = {'mock' => 'item', 'generated' => {}, 'alveo:metadata' => {'meta' => 'data'}}
      allow(@upload_worker).to receive(:generate_fields).and_return({})
      expected = example.to_json
      headers = {action: 'create'}
      expect(@exchange).to receive(:publish).with(expected, {routing_key: 'postgres_queue', headers: headers, persistent: true})
      expect(@exchange).to receive(:publish).with(expected, {routing_key: 'solr_queue', headers: headers, persistent: true})
      expect(@exchange).to receive(:publish).with(expected, {routing_key: 'sesane_queue', headers: headers, persistent: true})
      @upload_worker.create_item(example)
    end

  end

  describe '#process_message' do

    it 'creates an item on create action header' do
      expected = 'item'
      example_headers = {'action' => 'create'}
      example_message = {'items' => [expected]}
      expect(@upload_worker).to receive(:create_item).with(expected)
      @upload_worker.process_message(example_headers, example_message)
    end

  end

end
