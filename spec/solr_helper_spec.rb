require 'rspec'
require 'json'
require 'yaml'
require_relative '../solr_helper'

describe SolrHelper do

  let(:module_class) { Class.new.include(SolrHelper).new }
  let(:solr_config) { YAML.load_file('./spec/files/solr_config.yml') }

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


    describe '#set_rdf_relation_to_facet_map' do

      it 'initialises the @default_document' do
        rdf_relation_to_facet_map = solr_config['solr']['rdf_relation_to_facet_map']
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
        module_class.set_rdf_relation_to_facet_map(rdf_relation_to_facet_map)
        actual = module_class.instance_variable_get(:@default_item_fields)
        expect(actual).to eq(expected)
      end

    end

    describe '#generate_item_fields' do

      it 'generates a hash with _ssim and _tesim keys' do
        rdf_ns_to_solr_prefix_map = solr_config['solr']['rdf_ns_to_solr_prefix_map']
        module_class.set_rdf_ns_to_solr_prefix_map(rdf_ns_to_solr_prefix_map)
        expected = { 'DC_contributor_ssim' => 'Kanye West', 'DC_contributor_tesim' => 'Kanye West' }
        actual = module_class.generate_item_fields('http://purl.org/dc/terms/contributor', 'Kanye West')
        expect(actual).to eq(expected)
      end

    end

    describe '#map_rdf_predicate_to_solr_field' do

      it 'maps RDF prefix to a solr prefix' do
        rdf_ns_to_solr_prefix_map = solr_config['solr']['rdf_ns_to_solr_prefix_map']
        module_class.set_rdf_ns_to_solr_prefix_map(rdf_ns_to_solr_prefix_map)
        expected = 'DC_contributor'
        actual = module_class.map_rdf_predicate_to_solr_field('http://purl.org/dc/terms/contributor')
        expect(actual).to eq(expected)
      end

    end

    describe '#extract_value' do

      it 'extracts the first deeply nested hash value' do
        test_extract_value([{"@value" => "Skills, trades and hobbies"}], 'Skills, trades and hobbies')
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

  describe '#graph_type' do

    it 'returns the qualified type term when given a graph hash' do
      expected = 'AusNCObject'
      actual = module_class.graph_type({"@type" => ["http://ns.ausnc.org.au/schemas/ausnc_md_model/AusNCObject"]})
      expect(actual).to eq(expected)
    end
    
  end

  describe '#get_qualified_term' do

    it 'parses a fully qualified term into its namespace and term' do
      expected_ns = 'http://ns.ausnc.org.au/schemas/ausnc_md_model/'
      expected_term = 'speech_style'
      (acutal_ns, actual_term) = module_class.get_qualified_term('http://ns.ausnc.org.au/schemas/ausnc_md_model/speech_style')
      expect(acutal_ns).to eq(expected_ns)
      expect(actual_term).to eq(expected_term)
    end

  end

end