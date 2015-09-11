require 'spec_helper'

describe SolrWorker do

  let(:solr_worker) {
    options = {error_queue: 'error',
               client_class: 'RSolrMock',
               rabbitmq:
                   {client_class: 'BunnyMock',
                    work_queue: 'solr'}}

    SolrWorker.new(options)
  }

  let(:mock_solr_client) {
    solr_worker.instance_variable_get(:@solr_client)
  }

  let(:mock_exchange) {
    solr_worker.instance_variable_get(:@exchange)
  }

  describe '#process_message' do

    it 'invokes #index_item when the action is "index"' do
      message = '{"action": "add", "document": {"field": "value"}}'
      expected_params = {'field' => 'value'}
      expect(solr_worker).to receive(:add_document).with(expected_params)
      # TODO make routing_key reference options hash
      mock_exchange.publish(message, routing_key: 'solr')
      solr_worker.subscribe
    end

  end

  describe '#add_document' do

    # NOTE: Any point to this test?
    it 'does not raise an error if the solr response is 0' do
      mock_solr_response = {'responseHeader' => {'status' => 0}}
      mock_solr_client.set_responses([mock_solr_response])
      expect{solr_worker.add_document({})}.to_not raise_error
    end

    it 'raises an error a response for an unsuccessful add' do
      mock_solr_response = {'responseHeader' => {'status' => 1}}
      mock_solr_client.set_responses([mock_solr_response])
      expect{solr_worker.add_document({})}.to raise_error(RuntimeError)
    end

  end


end