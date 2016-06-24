require 'spec_helper'

describe TroveIngester do

  before(:all) do
    @ingester_options = {upload_queue: 'upload', error_queue: 'error', client_class: 'BunnyMock', monitor: []}
    @trove_ingester = TroveIngester.new(@ingester_options)
    @trove_ingester.connect
    @exchange = @trove_ingester.instance_variable_get(:@exchange)
  end


  describe '#process_chunk' do

    it 'publishes to the upload queue' do
      example = './spec/files/trove_chunk_example.dat'
      expected = ''
      properties = {routing_key: 'upload', headers: {action: 'create'}}
      expect(@exchange).to receive(:publish)
      @trove_ingester.process_chunk(example)
    end

  end

  describe '#map_to_json_ld' do

    it 'maps a Trove record to JSON-LS' do
      trove_record = File.read('./spec/examples/trove_example.json')
      trove_fields = JSON.parse(trove_record.encode('utf-8'))
      actual = @trove_ingester.map_to_json_ld(trove_fields, trove_record)
      expected = File.read('./spec/examples/alveo_trove_example.json')
      expect(actual).to eq(expected)
    end


  end
  
end