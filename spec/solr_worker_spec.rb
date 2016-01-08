require 'spec_helper'

describe SolrWorker do


  before(:all) do
    options = {error_queue: 'error',
               client_class: 'RSolrMock',
               rabbitmq:
                   {client_class: 'BunnyMock',
                    work_queue: 'solr'},
                batch: {enabled: false}}

    @solr_worker = SolrWorker.new(options)
    @solr_worker.connect
    @solr_client = @solr_worker.instance_variable_get(:@solr_client)
    @exchange = @solr_worker.instance_variable_get(:@exchange)
  end

  # describe '#process_message' do

  #   it 'invokes #index_item when the action is "index"' do
  #     message = '{"document": {"field": "value"}}'
  #     expected_params = {'field' => 'value'}
  #     expect(@solr_worker).to receive(:add_documents).with(expected_params)
  #     # TODO make routing_key reference options hash
  #     @exchange.publish(message, routing_key: 'solr')
  #     @solr_worker.start
  #   end

  # end

  describe '#add_document' do

    # NOTE: Any point to this test?
    it 'does not raise an error if the solr response is 0' do
      response = {'responseHeader' => {'status' => 0}}
      @solr_client.set_responses([response])
      expect{@solr_worker.add_documents({})}.to_not raise_error
    end

    it 'raises an error a response for an unsuccessful add' do
      response = {'responseHeader' => {'status' => 1}}
      @solr_client.set_responses([response])
      expect{@solr_worker.add_documents({})}.to raise_error(RuntimeError)
    end

  end


end