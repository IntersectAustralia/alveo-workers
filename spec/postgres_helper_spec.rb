require 'spec_helper'

describe PostgresHelper do
  
  before(:each) do
    mock_class = Class.new
    mock_class.include(PostgresHelper)
    mock_class.include(SpecHelper::ExposePrivate)
    @postgres_helper = mock_class.new
  end

  describe '#create_pg_statement' do

    it 'creates a hash of items and documents for instertion into postgres' do
      pending('Implement me')
      fail
    end

  end

  describe '#extract_documents_info' do

    it 'it builds an array of document info hashes' do
      pending('Implement me')
      fail
    end

  end

  describe '#extract_document_info' do

    it 'builds a document info hash' do
      example = {'dc:identifier' => 'primary_text.txt',
                 'dc:source' => '/path/to/primary_text.txt',
                 'dc:type' => 'Original'}
      expected = {file_name: 'primary_text.txt',
                  file_path: '/path/to/primary_text.txt',
                  doc_type: 'Original',
                  mime_type: 'text/plain'}
      actual = @postgres_helper.extract_document_info(example)
      expect(actual).to eq(expected)
    end

  end

  describe '#extract_item_info'  do

    it 'builds an item info hash' do
      example = {'alveo:metadata' => {'@id' => 'https://app.alveo.edu.au/catalog/collection/identifier',
                                      'alveo:display_document' => '/primary/text/path'},
                 'generated' => {'handle' => 'collection:identifier',
                                 'collection_id' => 3}}
      time = Time.new(1997)
      expect(Time).to receive(:now).and_return(time)
      expected = {uri: 'https://app.alveo.edu.au/catalog/collection/identifier',
                  handle: 'collection:identifier',
                  collection_id: 3,
                  primary_text_path: '/primary/text/path',
                  json_metadata: example,
                  indexed_at: time}
      actual = @postgres_helper.extract_item_info(example)
      expect(actual).to eq(expected)
    end

  end

end
