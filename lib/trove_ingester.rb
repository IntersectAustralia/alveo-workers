#encoding: utf-8
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
    limit = 100000
    count = 0
    File.open(trove_chunk, 'r:ascii-8bit').each { |trove_record|
      begin
        trove_fields = JSON.parse(trove_record.encode('utf-8'))
        message = map_to_json_ld(trove_fields)
        properties = {routing_key: @upload_queue.name, headers: {action: 'create'}}
        @exchange.publish(message, properties)
        count += 1
        break if count >= limit
      rescue Exception => e
        # TODO: Error queue instead of log file
        @error_logger.error "#{e.class}: #{e.to_s}"
      end
    }
  end

  def map_to_json_ld(trove_fields)
    # TODO: see if qualified values can be removed, e.g. ausnc:popular
    %Q({
        "items":[{
        "@context": [
          {
            "ausnc": "http://ns.ausnc.org.au/schemas/ausnc_md_model/",
            "dc": "http://purl.org/dc/terms/",
            "alveo": "http://alveo.edu.au/vocabulary/",
            "olac": "http://www.language-archives.org/OLAC/1.1/"
         }],
        "alveo:metadata": {
            "ausnc:audience": "mass_market",
            "ausnc:communication_medium": "newspaper",
            "ausnc:communication_setting": "popular",
            "ausnc:itemwordcount": "#{trove_fields['wordCount']}",
            "ausnc:mode": "written",
            "ausnc:publication_status": "published",
            "ausnc:state": "#{trove_fields['state'].first}",
            "ausnc:written_mode": "print",
            "dc:created": "#{trove_fields['date']}",
            "dc:identifier": "#{trove_fields['id']}",
            "dc:source": #{trove_fields['titleName'].to_json},
            "dc:title": #{trove_fields['heading'].to_json},
            "dc:isPartOf": "trove",
            "alveo:fulltext": #{trove_fields['fulltext'].to_json},
            "alveo:display_document": "http://trove.alveo.edu.au/document/#{trove_fields['id']}",
            "alveo:indexable_document": "http://trove.alveo.edu.au/document/#{trove_fields['id']}",
            "olac:language": "eng"
          },
          "ausnc:document": [{
            "dc:extent": #{trove_fields['fulltext'].size},
            "dc:identifier": "#{trove_fields['id']}",
            "dc:source": "http://trove.alveo.edu.au/document/#{trove_fields['id']}",
            "dc:type": "Text",
            "alveo:size": #{trove_fields['fulltext'].bytesize}
          }]
        }
    ]})
  end

  #"trove:category": "#{trove_fields['category']}",
  #"trove:firstPageId": "#{trove_fields['firstPageId']}",
  #"trove:firstPageSeq": "#{trove_fields['firstPageSeq']}",

end
