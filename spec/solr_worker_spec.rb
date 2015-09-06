require 'spec_helper'

describe SolrWorker do

  let(:solr_worker) {
    SolrWorker.new({}, BunnyMock)
  }

  describe 'Basic messaging' do

    it 'should receive messages' do
      message = 'Message 1'
      exchange = solr_worker.get_exchange
      expect(solr_worker).to receive(:on_message).with(message)
      exchange.publish(message)
      solr_worker.subscribe
    end

    it 'should parse json messages' do
      message = 'Message 1'
      exchange = solr_worker.get_exchange
      expect(solr_worker).to receive(:on_message).with(message)
      exchange.publish(message)
      solr_worker.subscribe
    end

  end

  
end