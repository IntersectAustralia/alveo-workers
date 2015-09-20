require 'spec_helper'

describe PersistentClient do

  before(:all) do
   @persistent_client = PersistentClient.new('test')
  end

  let(:path) {
    'http://localhost:8080'
  }

  describe '#build_request' do

    it 'builts a request object from arguements' do
      example_headers = {'Accept' => 'text/plain'}
      example_body = 'cat=meow'
      actual = @persistent_client.build_request(path, :post, example_headers, example_body)
      expect(actual).to be_a(Net::HTTP::Post)
      expect(actual.body).to eq(example_body)
      actual_headers = actual.instance_variable_get(:@header)
      expect(actual_headers['accept']).to include(example_headers['Accept'])
    end

  end



end