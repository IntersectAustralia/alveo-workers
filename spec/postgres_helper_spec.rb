require 'spec_helper'

describe PostgresHelper do

  let(:example_item_graph) {
    {'http://purl.org/dc/terms/isPartOf' => [{'@id' => 'http://ns.ausnc.org.au/corpora/ace'}],
    '@id' => 'http://ns.ausnc.org.au/corpora/ace/items/E29a',
    'http://hcsvlab.org/vocabulary/display_document' => [{'@id' => 'http://ns.ausnc.org.au/corpora/ace/source/E29a#Text'}]}
  }

  let(:example_document_graphs) {
    {'http://ns.ausnc.org.au/corpora/ace/source/E29a#Text' => {'@id' => 'http://ns.ausnc.org.au/corpora/ace/source/E29a#Text',
                'http://purl.org/dc/terms/type' => [{'@value' => 'Original'}],
                'http://purl.org/dc/terms/source' => [{'@id' => 'file:///path/to/primary_text.txt'}],
                'http://purl.org/dc/terms/identifier' => [{'@value' => 'primary_text.txt'}]},
     'doc2' => {'@id' => 'http://ns.ausnc.org.au/corpora/ace/source/E29a#Raw',
                'http://purl.org/dc/terms/type' => [{'@value' => 'Raw'}],
                'http://purl.org/dc/terms/source' => [{'@id' => 'file:///path/to/raw.txt'}],
                'http://purl.org/dc/terms/identifier' => [{'@value' => 'raw.txt'}]}}
  }
  
  before(:each) do
    mock_class = Class.new
    mock_class.include(PostgresHelper)
    mock_class.include(SpecHelper::ExposePrivate)
    @postgres_helper = mock_class.new
  end

  describe '#generate_uri' do
  
    it 'generates a URI using item metadata' do
      expected = 'https://app.alveo.edu.au/catalog/ace/E29a'
      actual = @postgres_helper.generate_uri(example_item_graph)
      expect(actual).to eq(expected)
    end
  
    it 'raises an exception if there is insufficient metadata' do
      expect{
         @postgres_helper.generate_uri(example_item_graph.delete_key('@id'))
      }.to raise_error(StandardError)
    end

  end

  describe '#get_mime_type' do

    it 'maps the extension to a mime type' do
      example = 'file.jpg'
      expected = 'image/jpeg'
      actual = @postgres_helper.get_mime_type(example)
      expect(actual).to eq(expected)
    end

    it 'assumes octet-stream for unknown files' do
      example = 'file'
      expected = 'application/octet-stream'
      actual = @postgres_helper.get_mime_type(example)
      expect(actual).to eq(expected)
    end

  end

  describe '#get_primary_text_path' do

    it 'locates the primary text path from a document' do
      expected = 'file:///path/to/primary_text.txt'
      actual = @postgres_helper.get_primary_text_path(example_item_graph, example_document_graphs)
      expect(actual).to eq(expected)
    end

  end

  describe '#extract_document_info' do

    it 'builds a document info hash' do
      expected = {file_name: 'primary_text.txt',
                  file_path: '/path/to/primary_text.txt',
                  doc_type: 'Original',
                  mime_type: 'text/plain'}
      actual = @postgres_helper.extract_document_info(example_document_graphs.values.first)
      expect(actual).to eq(expected)
    end

  end

  describe '#extract_item_info'  do

    it 'builds an item info hash' do
      allow(@postgres_helper).to receive(:get_primary_text_path).and_return(nil)
      allow(@postgres_helper).to receive(:build_json_metadata).and_return('')
      expected = {uri: 'https://app.alveo.edu.au/catalog/ace/E29a',
                  handle: 'ace:E29a',
                  primary_text_path: nil,
                  json_metadata: ''}
      actual = @postgres_helper.extract_item_info(example_item_graph, example_document_graphs)
      expect(actual).to eq(expected)
    end

  end

  describe '#map_document_locations' do

    it 'maps document names to their file paths' do
      expected = {'primary_text.txt' => 'file:///path/to/primary_text.txt',
                  'raw.txt' => 'file:///path/to/raw.txt'}
      actual = @postgres_helper.map_document_locations(example_document_graphs)
      expect(actual).to eq(expected)
    end

  end

end
