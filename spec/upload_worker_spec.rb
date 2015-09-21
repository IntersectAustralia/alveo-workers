require 'spec_helper'

describe UploadWorker do

  before(:all) do
    @options = {rabbitmq: {client_class: 'BunnyMock', work_queue: 'upload'},
               solr_queue: 'solr_queue', solr: {}}
    @upload_worker = UploadWorker.new(@options)
    @upload_worker.connect
    @exchange = @upload_worker.instance_variable_get(:@exchange)
  end

  describe '#add_item' do

    it 'creates a job for the Solr Worker' do
      allow(@upload_worker).to receive(:expand_json_ld)
      example = {key: 'vaule'}
      allow(@upload_worker).to receive(:create_solr_document).and_return(example)
      expected = '{"action": "add", "document": {"key":"vaule"}}'
      solr_queue = @exchange.get_queue(@options[:solr_queue])
      @upload_worker.add_item('')
      expect(solr_queue.messages.first).to eq(expected)
    end

  end


end