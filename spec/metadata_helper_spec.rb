require 'spec_helper'

describe MetadataHelper do

  let(:metadata_helper) { Class.new.include(MetadataHelper).new }


  describe '#expand_json_ld' do

    it 'expands shortened JSON-LD from a file URL' do
      url = URI.join('file://',File.expand_path('./spec/files/json-ld_short_example.json'))
      example = url.to_s
      expected = [{'@id' => 'http://ns.ausnc.org.au/corpora/ace/items/E29a',
                   '@type' => ['http://ns.ausnc.org.au/schemas/ausnc_md_model/AusNCObject']}]
      actual = metadata_helper.expand_json_ld(example)
      expect(actual).to eq(expected)
    end

  end

  describe '#load_json_from_file_uri' do

    it 'loads JSON-LD given a file URL' do
      url = URI.join('file://',File.expand_path('./spec/files/json-ld_expanded_short_example.json'))
      example = url.to_s
      expected = {'@id' => 'http://ns.ausnc.org.au/corpora/ace/items/E29a',
      '@type' => ['http://ns.ausnc.org.au/schemas/ausnc_md_model/AusNCObject']}
      actual = metadata_helper.load_json_from_file_url(example)
      expect(actual).to eq(expected)
    end

    it 'raises an error if the file does not exist' do
      expect{
        metadata_helper.load_json_from_file_url('file:///noexistant.file')
      }.to raise_error(StandardError)
    end

    it 'raises an error if the input is not valid JSON' do
      expect{
        url = URI.join('file://', File.expand_path('./files/json-ld_invalid_example.json'))
        example = url.to_s
        metadata_helper.load_json_from_file_url(example)
      }.to raise_error(StandardError)
    end

  end

  describe '#get_file_path_from_uri' do

    it 'returns the path from a URL' do
      example = 'file:///cat/mouse'
      expected  = '/cat/mouse'
      actual = metadata_helper.get_file_path_from_url(example)
      expect(actual).to eq(expected)
    end

    it 'raises and error if the scheme is not "file"' do
      example = 'http://example.org/cat/mouse'
      expect{
        metadata_helper.get_file_path_from_url(example)
      }.to raise_error(StandardError).with_message('Metadata must be in a file URI')

    end

  end

end