module NewSolrHelper

  # TODO: These fields wouldn't need to be mapped if the Solr
  #       schema matched the RDF namespaces
  @@MAPPED_FACETS = {
      'ausnc:audience' => 'AUSNC_audience_facet',
      'ausnc:communication_setting' => 'AUSNC_communication_setting_facet',
      'ausnc:mode' => 'AUSNC_mode_facet',
      'ausnc:written_mode' => 'AUSNC_written_mode_facet',
      'dc:isPartOf' => 'collection_name_facet'
      'olac:language' => 'OLAC_language_facet',
      'olac:discourse_type' => 'OLAC_discourse_type_facet',
      'ausnc:speech_style' => 'AUSNC_speech_style_facet'
      'ausnc:interactivity' => 'AUSNC_interactivity_facet'
  }


      'hcsvlab:default_document' => '',
      'hcsvlab:indexable_document' => '',
      'ausnc:source' => '',
      'ausnc:publication_status' => '',
      'ausnc:itemwordcount' => '',
      'dcterms:contributor' => '',
      'dcterms:created' => '',
      'dcterms:identifier' => '',
      'dcterms:isPartOf' => '',
      'dcterms:publisher' => '',
      'dcterms:title' => '',
      'ace:genre' => '',


end
