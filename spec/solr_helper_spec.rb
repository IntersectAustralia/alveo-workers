require 'spec_helper'

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

      it 'initialises the @default_item_fields' do
        rdf_relation_to_facet_map = solr_config['solr']['rdf_relation_to_facet_map']
        expected = {'AUSNC_audience_facet' => 'unspecified',
                    'AUSNC_communication_setting_facet' => 'unspecified',
                    'AUSNC_mode_facet' => 'unspecified',
                    'AUSNC_publication_status_facet' => 'unspecified',
                    'AUSNC_written_mode_facet' => 'unspecified',
                    'collection_name_facet' => 'unspecified',
                    'OLAC_language_facet' => 'unspecified',
                    'AUSNC_speech_style_facet' => 'unspecified',
                    'AUSNC_interactivity_facet' => 'unspecified',
                    'AUSNC_communication_context_facet' => 'unspecified',
                    'AUSNC_communication_medium_facet' => 'unspecified',
                    'OLAC_discourse_type_facet' => 'unspecified'}
        module_class.set_rdf_relation_to_facet_map(rdf_relation_to_facet_map)
        actual = module_class.instance_variable_get(:@default_item_fields)
        expect(actual).to eq(expected)
      end

    end

    describe '#set_document_field_to_rdf_relationmap' do

      it 'initialises the @default_document' do
        # rdf_relation_to_document_field_map = solr_config['solr']['rdf_relation_to_document_field_map']
        document_field_to_rdf_relation_map = {'DC_type_facet' => 'http://purl.org/dc/terms/type',
                                              'DC_extent_sim' => 'http://purl.org/dc/terms/extent',
                                              'DC_extent_tesim' => 'http://purl.org/dc/terms/extent'}
        module_class.set_document_field_to_rdf_relation_map(document_field_to_rdf_relation_map)
        expected = {'DC_type_facet' => [], 'DC_extent_sim' => [], 'DC_extent_tesim' => []}
        actual = module_class.instance_variable_get(:@default_document_fields)
        expect(actual).to eq(expected)
      end

    end

    describe '#generate_item_fields' do

      it 'generates a hash with _ssim and _tesim values to index' do
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
        test_extract_value([{'@value' => 'Skills, trades and hobbies'}], 'Skills, trades and hobbies')
      end

      it 'does not modify non Hashes' do
        test_extract_value('Skills, trades and hobbies', 'Skills, trades and hobbies')
      end

      it 'normailises whitespace in the extracted value' do
        test_extract_value([{'@value' => "   Skills, trades\t\tand hobbies\n"}], 'Skills, trades and hobbies')
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
      actual = module_class.graph_type({'@type' => ['http://ns.ausnc.org.au/schemas/ausnc_md_model/AusNCObject']})
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

    describe '#map_document_fields' do

      it 'maps and merges document metadata' do
        document_field_to_rdf_relation_map = solr_config['solr']['document_field_to_rdf_relation_map']
        module_class.set_document_field_to_rdf_relation_map(document_field_to_rdf_relation_map)
        example = [{"http://purl.org/dc/terms/extent" => [{"@value" => 1234}],
                    "http://purl.org/dc/terms/type" => [{"@value" => "Original"}]},
                   {"http://purl.org/dc/terms/extent" => [{"@value" => 5678}],
                    "http://purl.org/dc/terms/type" => [{"@value" => "Raw"}]}]
        expected = {'DC_type_facet' => ['Original', 'Raw'],
                    'DC_extent_sim' => [1234, 5678],
                    'DC_extent_tesim' => [1234, 5678]}
        actual = module_class.map_document_fields(example)
        expect(actual).to eq(expected)
      end

    end

    describe '#normalise_whitespace' do

      it 'replaces multiple whitespaces with a single space' do
        test_normalise_whitespace("the \ncat \t\t sat", 'the cat sat')
      end

      it 'trims surrounding whitespace' do
        test_normalise_whitespace('  the cat sat   ', 'the cat sat')
      end

      it 'does not modify clean strings' do
        test_normalise_whitespace('the cat sat', 'the cat sat')
      end

      it 'does not modify non strings values' do
        test_normalise_whitespace(1234, 1234)
      end

      def test_normalise_whitespace(example, expected)
        actual = module_class.normalise_whitespace(example)
        expect(actual).to eq(expected)
      end

    end

    describe '#generate_access_rights' do

      it 'generates a hash with group and person access rights values to index' do
        example_person = 'data_owner@intersect.org.au'
        example_group = 'collection'
        expected = {
            discover_access_group_ssim: 'collection-discover',
            read_access_group_ssim: 'collection-read',
            edit_access_group_ssim: 'collection-edit',
            discover_access_person_ssim: 'data_owner@intersect.org.au',
            read_access_person_ssim: 'data_owner@intersect.org.au',
            edit_access_person_ssim: 'data_owner@intersect.org.au'
        }
        actual = module_class.generate_access_rights(example_person, example_group)
        expect(actual).to eq(expected)
      end

    end

  end

end
