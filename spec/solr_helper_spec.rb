require 'spec_helper'

describe SolrHelper do

  # TODO: Use a common config across all tests
  #       to simplify setup
  let(:solr_helper) { Class.new.include(SolrHelper).new }
  let(:config) { YAML.load_file('./spec/files/config.yml') }

  let(:rdf_ns_to_solr_prefix_map) {
    {'http://purl.org/dc/terms/' => 'DC_'}
  }

  let(:document_field_to_rdf_relation_map) {
    {'DC_type_facet' => 'http://purl.org/dc/terms/type',
     'DC_extent_sim' => 'http://purl.org/dc/terms/extent',
     'DC_extent_tesim' => 'http://purl.org/dc/terms/extent'}
  }

  let(:rdf_relation_to_facet_map) {
    {'http://purl.org/dc/terms/isPartOf' => 'collection_name_facet'}
  }

  describe '#get_default_item_fields' do

    it 'initialises the default_item_fields' do
      expected = {'collection_name_facet' => 'unspecified'}
      solr_helper.set_rdf_relation_to_facet_map(rdf_relation_to_facet_map)
      actual = solr_helper.get_default_item_fields
      expect(actual).to eq(expected)
    end

  end

  describe '#map_item_fields' do

    it 'maps mapped item fields' do
      # rdf_relation_to_facet_map = {'http://purl.org/dc/terms/isPartOf' => 'collection_name_facet'}
      solr_helper.set_rdf_relation_to_facet_map(rdf_relation_to_facet_map)
      example = {'http://purl.org/dc/terms/isPartOf' => [{'@id' => 'http://ns.ausnc.org.au/corpora/ace'}]}
      expected = {'collection_name_facet' => 'ace'}
      actual = solr_helper.map_item_fields(example)
      expect(actual).to eq(expected)
    end

    it 'maps generated item fields' do
      solr_helper.set_rdf_relation_to_facet_map({})
      # rdf_ns_to_solr_prefix_map = {'http://ns.ausnc.org.au/schemas/ace/' => 'ACE_'}
      solr_helper.set_rdf_ns_to_solr_prefix_map(rdf_ns_to_solr_prefix_map)
      # example = {'http://ns.ausnc.org.au/schemas/ace/genre' => [{'@value' => 'Skills, trades and hobbies'}]}

      # expected = {'ACE_genre_sim' => ['Skills, trades and hobbies'], 'ACE_genre_tesim' => ['Skills, trades and hobbies']}
      example = {'http://purl.org/dc/terms/created' => [{'@value' => '10 October 1986'}]}
      expected = {'DC_created_sim' => ['10 October 1986'], 'DC_created_tesim' => ['10 October 1986']}
      actual = solr_helper.map_item_fields(example)
      expect(actual).to eq(expected)
    end

  end

  describe '#map_fields' do

    it 'maps document and item fields' do
      # document_field_to_rdf_relation_map = {'DC_type_facet' => 'http://purl.org/dc/terms/type',
      #                                       'DC_extent_sim' => 'http://purl.org/dc/terms/extent',
      #                                       'DC_extent_tesim' => 'http://purl.org/dc/terms/extent'}
      solr_helper.set_document_field_to_rdf_relation_map(document_field_to_rdf_relation_map)
      #rdf_relation_to_facet_map = {'http://purl.org/dc/terms/isPartOf' => 'collection_name_facet'}
      solr_helper.set_rdf_relation_to_facet_map(rdf_relation_to_facet_map)
      # rdf_ns_to_solr_prefix_map = {'http://ns.ausnc.org.au/schemas/ace/' => 'ACE_'}
      solr_helper.set_rdf_ns_to_solr_prefix_map(rdf_ns_to_solr_prefix_map)
      example_item_graph = {'http://purl.org/dc/terms/isPartOf' => [{'@id' => 'http://ns.ausnc.org.au/corpora/ace'}],
                            # 'http://ns.ausnc.org.au/schemas/ace/genre' => [{'@value' => 'Skills, trades and hobbies'}]}
                            'http://purl.org/dc/terms/created' => [{'@value' => '10 October 1986'}]}
      example_document_graphs = {'doc1' => {'http://purl.org/dc/terms/extent' => [{'@value' => '1234'}],
                                            'http://purl.org/dc/terms/type' => [{'@value' => 'Original'}]},
                                 'doc2' => {'http://purl.org/dc/terms/extent' => [{'@value' => '5678'}],
                                            'http://purl.org/dc/terms/type' => [{'@value' => 'Raw'}]}}
      expected = {'collection_name_facet' => 'ace',
                  # 'ACE_genre_sim' => ['Skills, trades and hobbies'], 'ACE_genre_tesim' => ['Skills, trades and hobbies'],
                  'DC_created_sim' => ['10 October 1986'], 'DC_created_tesim' => ['10 October 1986'],
                  'DC_type_facet' => ['Original', 'Raw'],
                  'DC_extent_sim' => ['1234', '5678'],
                  'DC_extent_tesim' => ['1234', '5678']}
      actual = solr_helper.map_fields(example_item_graph, example_document_graphs)
      expect(actual).to eq(expected)
    end

  end

  describe '#get_default_document_fields' do

    it 'initialises the default_document' do
      # document_field_to_rdf_relation_map = {'DC_type_facet' => 'http://purl.org/dc/terms/type',
      #                                       'DC_extent_sim' => 'http://purl.org/dc/terms/extent',
      #                                       'DC_extent_tesim' => 'http://purl.org/dc/terms/extent'}
      solr_helper.set_document_field_to_rdf_relation_map(document_field_to_rdf_relation_map)
      expected = {'DC_type_facet' => [], 'DC_extent_sim' => [], 'DC_extent_tesim' => []}
      actual = solr_helper.get_default_document_fields
      expect(actual).to eq(expected)
    end

  end

  describe '#generate_item_fields' do

    it 'generates a hash with _ssim and _tesim values to index' do
      # rdf_ns_to_solr_prefix_map = config[:solr]['rdf_ns_to_solr_prefix_map']
      solr_helper.set_rdf_ns_to_solr_prefix_map(rdf_ns_to_solr_prefix_map)
      expected = {'DC_contributor_sim' => ['Kanye West'], 'DC_contributor_tesim' => ['Kanye West']}
      actual = solr_helper.generate_item_fields('http://purl.org/dc/terms/contributor', 'Kanye West')
      expect(actual).to eq(expected)
    end

  end

  describe '#map_rdf_predicate_to_solr_field' do

    it 'maps RDF prefix to a solr prefix' do
      # rdf_ns_to_solr_prefix_map = config[:solr]['rdf_ns_to_solr_prefix_map']
      solr_helper.set_rdf_ns_to_solr_prefix_map(rdf_ns_to_solr_prefix_map)
      expected = 'DC_contributor'
      actual = solr_helper.map_rdf_predicate_to_solr_field('http://purl.org/dc/terms/contributor')
      expect(actual).to eq(expected)
    end

    # TODO: get a better exception message
    it 'maps raises an Exception if there is no mapping defined' do
      solr_helper.set_rdf_ns_to_solr_prefix_map({})
      expect { solr_helper.map_rdf_predicate_to_solr_field('http://purl.org/dc/terms/contributor') }.to raise_error(StandardError)
    end

  end

  describe '#extract_value' do

    it 'extracts the first deeply nested hash value' do
      test_extract_value([{'@value' => 'Skills, trades and hobbies'}], 'Skills, trades and hobbies')
    end

    it 'does not modify non Hashes' do
      test_extract_value('Skills, trades and hobbies', 'Skills, trades and hobbies')
      test_extract_value(1234, 1234)
    end

    it 'extracts the first value of arrays' do
      test_extract_value(['Skills, trades and hobbies'], 'Skills, trades and hobbies')
    end

    it 'normailises whitespace in the extracted value' do
      test_extract_value([{'@value' => "   Skills, trades\t\tand hobbies\n"}], 'Skills, trades and hobbies')
    end

  # end

    def test_extract_value(example, expected)
      actual = solr_helper.extract_value(example)
      expect(actual).to eq(expected)
    end

  end

  describe '#graph_type' do

    it 'returns the qualified type term when given a graph hash' do
      expected = 'AusNCObject'
      actual = solr_helper.graph_type({'@type' => ['http://ns.ausnc.org.au/schemas/ausnc_md_model/AusNCObject']})
      expect(actual).to eq(expected)
    end

  end

  describe '#get_qualified_term' do

    it 'parses a fully qualified term into its namespace and term' do
      expected_ns = 'http://ns.ausnc.org.au/schemas/ausnc_md_model/'
      expected_term = 'speech_style'
      (acutal_ns, actual_term) = solr_helper.get_qualified_term('http://ns.ausnc.org.au/schemas/ausnc_md_model/speech_style')
      expect(acutal_ns).to eq(expected_ns)
      expect(actual_term).to eq(expected_term)
    end

  end

  describe '#map_document_fields' do

    it 'maps and merges document metadata' do
      # document_field_to_rdf_relation_map = config[:solr]['document_field_to_rdf_relation_map']
      solr_helper.set_document_field_to_rdf_relation_map(document_field_to_rdf_relation_map)
      example = {'doc1' => {'http://purl.org/dc/terms/extent' => [{'@value' => 1234}],
                            'http://purl.org/dc/terms/type' => [{'@value' => 'Original'}]},
                 'doc2' => {'http://purl.org/dc/terms/extent' => [{'@value' => 5678}],
                            'http://purl.org/dc/terms/type' => [{'@value' => 'Raw'}]}}
      expected = {'DC_type_facet' => ['Original', 'Raw'],
                  'DC_extent_sim' => [1234, 5678],
                  'DC_extent_tesim' => [1234, 5678]}
      actual = solr_helper.map_document_fields(example)
      expect(actual).to eq(expected)
    end

    it 'does not merge the results of successive calls' do
      # document_field_to_rdf_relation_map = config[:solr]['document_field_to_rdf_relation_map']
      solr_helper.set_document_field_to_rdf_relation_map(document_field_to_rdf_relation_map)
      example1 = {'doc1' => {'http://purl.org/dc/terms/extent' => [{'@value' => 1234}],
                             'http://purl.org/dc/terms/type' => [{'@value' => 'Original'}]},
                  'doc2' => {'http://purl.org/dc/terms/extent' => [{'@value' => 5678}],
                             'http://purl.org/dc/terms/type' => [{'@value' => 'Raw'}]}}
      example2 = {'doc1' => {'http://purl.org/dc/terms/extent' => [{'@value' => 1234}],
                             'http://purl.org/dc/terms/type' => [{'@value' => 'Original'}]},
                  'doc2' => {'http://purl.org/dc/terms/extent' => [{'@value' => 5678}],
                             'http://purl.org/dc/terms/type' => [{'@value' => 'Raw'}]}}
      expected = {'DC_type_facet' => ['Original', 'Raw'],
                  'DC_extent_sim' => [1234, 5678],
                  'DC_extent_tesim' => [1234, 5678]}
      solr_helper.map_document_fields(example1)
      actual = solr_helper.map_document_fields(example2)
      expect(actual).to eq(expected)
    end


  end

  

  describe '#build_access_rights_map' do

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
      actual = solr_helper.build_access_rights_map(example_person, example_group)
      expect(actual).to eq(expected)
    end

  end

  describe '#generate_access_rights' do

    it 'assigns ownership to the default data owner if none is provided' do
      config = {'default_data_owner' => 'data_owner@intersect.org.au',
                'data_owner_field' => 'http://id.loc.gov/vocabulary/relators/rpy',
                'collection_field' => 'http://purl.org/dc/terms/isPartOf'}
      solr_helper.set_mapped_fields(config)
      example = {'http://purl.org/dc/terms/isPartOf' => [{'@id' => 'http://ns.ausnc.org.au/corpora/collection'}]}
      expected = {
          discover_access_group_ssim: 'collection-discover',
          read_access_group_ssim: 'collection-read',
          edit_access_group_ssim: 'collection-edit',
          discover_access_person_ssim: 'data_owner@intersect.org.au',
          read_access_person_ssim: 'data_owner@intersect.org.au',
          edit_access_person_ssim: 'data_owner@intersect.org.au'
      }
      actual = solr_helper.generate_access_rights(example)
      expect(actual).to eq(expected)
    end

    it 'throws an error if it can not assign a data owner' do
      config = {'data_owner_field' => 'http://id.loc.gov/vocabulary/relators/rpy',
                'collection_field' => 'http://purl.org/dc/terms/isPartOf'}
      solr_helper.set_mapped_fields(config)
      example = {'http://purl.org/dc/terms/isPartOf' => [{'@id' => 'http://ns.ausnc.org.au/corpora/collection'}]}
      expect { solr_helper.generate_access_rights(example) }.to raise_error(StandardError)
    end

  end

  describe '#generate_handle' do

    it 'generates a handle for an item from the collection and identifier' do
      config = {'identifier_field' => '@id',
                'collection_field' => 'http://purl.org/dc/terms/isPartOf'}
      solr_helper.set_mapped_fields(config)
      example = {'@id' => 'http://ns.ausnc.org.au/corpora/ace/items/item',
                 'http://purl.org/dc/terms/isPartOf' => [{'@id' => 'http://ns.ausnc.org.au/corpora/collection'}]}
      expected = 'collection:item'
      actual = solr_helper.generate_handle(example)
      expect(actual).to eq(expected)
    end

    # TODO: Not touching the code we would expect it to
    it 'throws an error if collection or identifier are nil' do
      config = {'identifier_field' => '@id',
                'collection_field' => 'http://purl.org/dc/terms/isPartOf'}
      solr_helper.set_mapped_fields(config)
      example = {'@id' => 'http://ns.ausnc.org.au/corpora/ace/items/item'}
      expect { solr_helper.generate_handle(example) }.to raise_error(StandardError)
      example = {'http://purl.org/dc/terms/isPartOf' => [{'@id' => 'http://ns.ausnc.org.au/corpora/collection'}]}
      expect { solr_helper.generate_handle(example) }.to raise_error(StandardError)
    end

  end

  describe '#separate_graphs' do

    it 'separates a JSON-LD hash into item and document graphs' do
      example = [{'@type' => ['http://ns.ausnc.org.au/schemas/ausnc_md_model/AusNCObject']},
                 {'@type' => ['http://xmlns.com/foaf/0.1/Document'],
                  '@id' => 'doc1'},
                 {'@type' => ['http://xmlns.com/foaf/0.1/Document'],
                  '@id' => 'doc2'}]
      expected_item = {'@type' => ['http://ns.ausnc.org.au/schemas/ausnc_md_model/AusNCObject']}
      expected_documents = {'doc1' => {'@type' => ['http://xmlns.com/foaf/0.1/Document'], '@id' => 'doc1'},
                            'doc2' => {'@type' => ['http://xmlns.com/foaf/0.1/Document'], '@id' => 'doc2'}}
      (actual_item, actual_documents) = solr_helper.separate_graphs(example)
      expect(actual_item).to eq(expected_item)
      expect(actual_documents).to eq(expected_documents)
    end

  end

  describe '#create_solr_document' do

    it 'transforms JSON-LD into a Solr document hash' do
      solr_helper.set_solr_config(config[:solr])
      example = JSON.load(File.open('spec/files/json-ld_expanded_example.json'))
      expected = eval(File.open('spec/files/solr_document.hash').read)
      actual = solr_helper.create_solr_document(example)
      expect(actual).to eq(expected)
    end

  end

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
      actual = solr_helper.date_group(example, resolution)
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
      actual = solr_helper.normalise_whitespace(example)
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
      expect {
        solr_helper.extract_year(example)
      }.to raise_error(ArgumentError)
    end

    def test_extract_year(example, expected)
      actual = solr_helper.extract_year(example)
      expect(actual).to eq(expected)
    end

  end

end
