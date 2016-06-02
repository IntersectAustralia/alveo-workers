module SolrHelper

  def create_solr_document(item_json_ld)
    item_metadata = item_json_ld['alveo:metadata']
    item_metadata.default = 'unspecified'
    {
      collection_name_facet: item_metadata['dc:isPartOf'],
      date_group_facet: item_json_ld['generated']['date_group'],
      DC_type_facet: item_json_ld['generated']['types'],
      OLAC_discourse_type_facet: item_metadata['olac:discourse_type'],
      OLAC_language_facet: item_metadata['olac:language'],
      AUSNC_mode_facet: item_metadata['ausnc:mode'],
      AUSNC_speech_style_facet: item_metadata['ausnc:speech_style'],
      AUSNC_interactivity_facet: item_metadata['ausnc:interactivity'],
      AUSNC_communication_context_facet: item_metadata['ausnc:communication_context'],
      AUSNC_audience_facet: item_metadata['ausnc:audience'],
      AUSNC_written_mode_facet: item_metadata['ausnc:written_mode'],
      AUSNC_communication_setting_facet: item_metadata['ausnc:communication_setting'],
      AUSNC_publication_status_facet: item_metadata['ausnc:publication_status'],
      AUSNC_communication_medium_facet: item_metadata['ausnc:communication_medium'],
      handle: item_json_ld['generated']['handle'],
      id: item_json_ld['generated']['handle'],
      full_text: item_metadata['alveo:fulltext'], #TODO: fulltext should be a property of a document
      discover_access_group_ssim: "#{item_metadata['dc:isPartOf']}-discover",
      read_access_group_ssim: "#{item_metadata['dc:isPartOf']}-read",
      edit_access_group_ssim: "#{item_metadata['dc:isPartOf']}-edit",
      discover_access_person_ssim: item_json_ld['generated']['owner'],
      read_access_person_ssim: item_json_ld['generated']['owner'],
      edit_access_person_ssim: item_json_ld['generated']['owner'],
      DC_created_sim: item_metadata['dc:created'],
      DC_created_tesim: item_metadata['dc:created'],
      DC_title_sim: item_metadata['dc:title'],
      DC_title_tesim: item_metadata['dc:title']
    }
  end

end
