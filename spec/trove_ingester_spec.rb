require 'spec_helper'

describe TroveIngester do

  before(:all) do
    @ingester_options = {upload_queue: 'upload', error_queue: 'error', client_class: 'BunnyMock'}
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
  
end