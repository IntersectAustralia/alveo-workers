require 'spec_helper'

describe SolrWorker do

  let(:solr_worker) {
    options = {solr:
                   {error_queue: 'error',
                    client_class: 'RSolrMock'},
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

    it 'returns a response of 0 for a successful add' do
      expected = {'responseHeader' => {'status' => 0, 'QTime' => 60}}
      mock_solr_client.set_responses([expected])
      expect(solr_worker).to receive(:add_document).and_return(expected)
      message = '{"action": "add", "document": {"field": "value"}}'
      mock_exchange.publish(message, routing_key: 'solr')
      solr_worker.subscribe
    end

  end


end