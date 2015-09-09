require 'spec_helper'

describe Ingester do

  let(:ingester_options) {
    {work_queue: 'upload', error_queue: 'error', client_class: 'BunnyMock'}
  }

  let(:ingester) {
    Ingester.new(ingester_options)
  }

  let(:exchange) {
    ingester.instance_variable_get(:@exchange)
  }

  describe '#prcocess_rdf' do

    it 'converts a Turle RDF file a JSON-LD string and publishes it' do
      example = './spec/files/turtle_example.rdf'
      json_ld = File.open('./spec/files/json-ld_expanded_example.json').read
      expected = "{'action': 'add item', 'metadata':#{json_ld}}"
      queue = BunnyMock::Queue.new(ingester_options[:work_queue])
      queue.bind(exchange)
      ingester.process_rdf(example)
      actual = queue.messages.first
      expect(actual).to eq(expected)
    end

  end


end