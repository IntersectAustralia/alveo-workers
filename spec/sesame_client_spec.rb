require 'spec_helper'

describe SesameClient do

  before(:each) do
    config = { base_url: 'http://sesame.org/sesame',
      paths: {system: 'SYSTEM'} }
    @connection = double(Net::HTTP::Persistent)
    @sesame_client = SesameClient.new(config)
    @sesame_client.instance_variable_set(:@connection, @connection)
  end

  describe '#create_repository' do

    it 'creates a new repository if the name is unique' do
      allow(@sesame_client).to receive(:repositories).and_return(['SYSTEM', 'existing'])
      set_mock_response(Net::HTTPNoContent, 204, '')
      example = 'new'
      expected = example
      actual = @sesame_client.create_repository(example)
      expect(actual).to eq(expected)
    end

    it 'raises an Error if the repository already exists' do
      expect{@sesame_client.create_repository('existing')}.to raise_error(StandardError)
    end
    
    it 'raises and error if the reponse was not 204' do
      set_mock_response(Net::HTTPNoContent, 204, '')
      expect{@sesame_client.create_repository('new')}.to raise_error(StandardError)
    end

  end

  describe '#sparql_query' do

    it 'parses the JSON response body'  do
      set_mock_response(Net::HTTPOK, 200, '{"key": "value"}')
      expected = {'key' => 'value'}
      actual = @sesame_client.sparql_query(:system)
      expect(actual).to eq(expected)
    end

  end

  describe '#insert_statements' do

    it 'inserts statements into an existing repository' do
      # TODO: This doesn't really test anything, it just touches the code
      expected = set_mock_response(Net::HTTPNoContent, 204, '')
      actual = @sesame_client.insert_statements('existing', 'Turtle')
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


  def set_mock_response(reponse_class, code, body)
    mock_response = double(reponse_class)
    allow(mock_response).to receive(:code).and_return(code)
    allow(mock_response).to receive(:body).and_return(body)
    allow(@connection).to receive(:request).and_return(mock_response)
    mock_response
  end

end