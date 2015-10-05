require 'bunny'

class TroveIngester

  def initialize(options)
    bunny_client_class = Module.const_get(options[:client_class])
    @bunny_client = bunny_client_class.new(options)
    @exchange_name = options[:exchange]
    @error_logger = Logger.new(options[:error_log])
    @upload_queue_name = options[:upload_queue]
  end

  def connect
    @bunny_client.start
    @channel = @bunny_client.create_channel
    @exchange = @channel.direct(@exchange_name)
    @upload_queue = add_queue(@upload_queue_name)
  end

  def close
    @bunny_client.close
  end

  def add_queue(name)
    queue = @channel.queue(name)
    queue.bind(@exchange, routing_key: name)
    queue
  end

  def self.get_rdf_file_paths(dir)
    Dir[File.join(dir, '**', '*')].keep_if { |path|
      (File.file? path) && (File.extname(path) == '.rdf')
    }
  end

  def process_chunk(trove_chunk)
    File.open(trove_chunk, 'r').each { |trove_record|
      begin
        trove_fields = JSON.parse(trove_record)
        message = map_to_json_ld(trove_fields)
        properties = {routing_key: @upload_queue.name, headers: {action: 'create'}}
        @exchange.publish(message, )
      rescue Exception => e
        # TODO: Error queue instead of log file
        @error_logger.error "#{e.class}: #{e.to_s}"
      end
    }
  end

  def map_to_json_ld(trove_fields)
    %Q(
      {
        "@context": ["https://app.alveo.edu.au/schema/json-ld",
          {
            "ausnc:audience" : { "@type": "@id"},
            "ausnc:communication_setting": { "@type": "@id" },
            "ausnc:mode": {  "@type": "@id" },
            "ausnc:publication_status": {  "@type": "@id" },
            "ausnc:written_mode": {  "@type": "@id" },
            "ausnc:itemwordcount": { "@type": "xsd:integer"},
            "dcterms:extent": { "@type": "xsd:integer"},
            "dcterms:source": {  "@type": "@id" }
         }],
        "@graph": {
          "@id": "#{trove_fields['@id']}", # TODO: Generated, this should probably be mapped to dc:identifier
          "@type": "ausnc:AusNCObject",
          "ausnc:audience": "ausnc:mass_market",
          "ausnc:communication_medium": "ausnc:newspaper",
          "ausnc:communication_setting": "ausnc:popular",
          "ausnc:itemwordcount": "#{trove_fields['wordCount']}",
          "ausnc:mode": "ausnc:written",
          "ausnc:publication_status": "ausnc:published",
          "ausnc:state": "#{trove_fields['state']}",
          "ausnc:written_mode": "ausnc:print",
          "dc:date": "#{trove_fields['date']}",
          "dc:identifier": "#{trove_fields['id']}",
          "dc:source": "#{trove_fields['titleName']}",
          "dc:title": "#{trove_fields['heading']}",
          "fulltext": "#{trove_fields['fulltext']}", # TODO: Perhaps this fields goes outside the graph?
          "trove:category": "#{trove_fields['category']}",
          "trove:firstPageId": "#{trove_fields['firstPageId']}",
          "trove:firstPageSeq": "#{trove_fields['firstPageSeq']}",
          "olac:language": "eng",
          "ausnc:document": [
            {
              "@type": "foaf:Document",
              "dcterms:extent": "#{trove_fields['fulltext'].size}",
              "dcterms:identifier": "", TODO: Generated
              "dcterms:source": "", TODO: Generated, linking to Steve's index
              "dcterms:type": "Text"
            },
        }
      }
    )
  end


end
