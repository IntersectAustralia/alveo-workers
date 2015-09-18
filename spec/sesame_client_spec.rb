require 'spec_helper'

describe SesameClient do

  # let(:config) {
  #   { base_url: 'http://sesame.org/sesame',
  #     paths: {system: 'SYSTEM'} }
  # }

  before(:all) do
    config = { base_url: 'http://sesame.org/sesame',
      paths: {system: 'SYSTEM'} }
    @connection = double(Net::HTTP::Persistent)
    @sesame_client = SesameClient.new(config)
    @sesame_client.instance_variable_set(:@connection, @connection)
  end

  describe '#create_repository' do

    it 'raises an Error if the repository already exists' do
      expect{@sesame_client.create_repository('existing')}.to raise_error(StandardError)
    end

    it 'creates a new repository if the name is unique' do
      allow(@sesame_client).to receive(:repositories).and_return(['SYSTEM', 'existing'])
      set_connection_response(Net::HTTPNoContent.new('', 204, ''))
      example = 'new'
      expected = example
      actual = @sesame_client.create_repository(example)
      expect(actual).to eq(expected)
    end

  end

  describe '#respositories' do

    it 'returns a list of repositories in Sesame' do
      response = {'results' => {'bindings' => [{'id' => {'value' => 'SYSTEM'}},
                                               {'id' => {'value' => 'existing'}}]}}
      allow(@sesame_client).to receive(:sparql_query).and_return(response)
      expected = ['SYSTEM', 'existing']
      actual = @sesame_client.repositories
      expect(actual).to eq(expected)
    end

  end

  def set_connection_response(response)
    allow(@connection).to receive(:request).and_return(response)
  end

end