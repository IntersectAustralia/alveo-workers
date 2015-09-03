require 'rspec'
require 'json'
require 'yaml'
require_relative '../solr_helper'

describe SolrHelper do

  let(:module_class) { Class.new.include(SolrHelper).new }

  describe '#date_group' do

    it 'returns a default range of 10' do
      test_date_group('1994', '1990 - 1999')
    end

    it 'returns an arbitrary range' do
      test_date_group('1994', '1988 - 1994', 7)
    end

    it 'returns "Unknown" for bad input' do
      test_date_group('wutang clan', 'Unknown')
    end

    def test_date_group(example, expected, resolution=10)
      actual = module_class.date_group(example, resolution)
      expect(actual).to eq(expected)
    end

  end

  describe '#extract_year' do

    it 'parses "YYYY?"' do
      test_extract_year('1913?', 1913)
    end

    it 'parses "DD/MM/YY"' do
      test_extract_year('30/10/93', 1993)
    end

    it 'parses "YY/MM/DD"' do
      test_extract_year('96/05/17', 1996)
    end

    it 'parses "DD-DD/MM/YY"' do
      test_extract_year('7-11/11/94', 1994)
    end

    it 'parses "DD&DD/MM/YY"' do
      test_extract_year('17&19/8/93', 1993)
    end

    it 'parses "YYYY-MM-DD"' do
      test_extract_year('2012-03-07', 2012)
    end

    it 'parses "Month YYYY"' do
      test_extract_year('August 2000', 2000)
    end

    it 'parses "DD Month YYYY"' do
      test_extract_year('6 September 1986', 1986)
    end

    it 'parses "DD Season YYYY"' do
      test_extract_year('4 Spring 1986', 1986)
    end

    it 'throws an exception when parsing "Phase N season"' do
      example = 'Phase I fall'
      expect{
        module_class.extract_year(example)
      }.to raise_error(ArgumentError)
    end

    def test_extract_year(example, expected)
      actual = module_class.extract_year(example)
      expect(actual).to eq(expected)
    end

  end

  describe '#map_facet_fields' do


    describe '#set_facet_field_map' do

      it 'initialises the @default_document' do
        config = YAML.load_file('./spec/files/solr_facets.yml')
        facet_field_map = config['solr']['mapped_facets']
        expected = {"AUSNC_audience_facet"=>"unspecified",
                    "AUSNC_communication_setting_facet"=>"unspecified",
                    "AUSNC_mode_facet"=>"unspecified",
                    "AUSNC_publication_status_facet"=>"unspecified",
                    "AUSNC_written_mode_facet"=>"unspecified",
                    "collection_name_facet"=>"unspecified",
                    "OLAC_language_facet"=>"unspecified",
                    "AUSNC_speech_style_facet"=>"unspecified",
                    "AUSNC_interactivity_facet"=>"unspecified",
                    "AUSNC_communication_context_facet"=>"unspecified",
                    "AUSNC_communication_medium_facet"=>"unspecified",
                    "OLAC_discourse_type_facet"=>"unspecified"}
        module_class.set_facet_field_map(facet_field_map)
        actual = module_class.instance_variable_get(:@default_document)
        expect(actual).to eq(expected)
      end

    end

    describe '#extract_value' do

      it 'does not strip URIs' do
        test_extract_value({'@id': 'file:///path/to/file.txt'}, 'file:///path/to/file.txt')
        test_extract_value({'@id': 'http://www.test.org'}, 'http://www.test.org')
        test_extract_value({'@id': 'ssh://root:pass@lol.hax.org'}, 'ssh://root:pass@lol.hax.org')
      end

      it 'strips RDF vocabulary' do
        test_extract_value({'@id': 'ausnc:published'}, 'published')
        test_extract_value({'@id': 'ausnc:print'}, 'print')
        test_extract_value({'@id': 'corpus:ace'}, 'ace')
      end

      it 'does not modify non Hashes' do
        test_extract_value('Skills, trades and hobbies', 'Skills, trades and hobbies')
      end

    end

    def test_extract_value(example, expected)
      actual = module_class.extract_value(example)
      expect(actual).to eq(expected)
    end

  end

end