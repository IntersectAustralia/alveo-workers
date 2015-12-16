# require 'open-uri'
# require 'rdf/turtle'
# require 'json/ld'
require 'active_record'
require 'models/item'
require 'models/document'
require 'models/collection'
require 'models/user'

module MetadataHelper

  @@COLLECTIONS = {}

  # TODO: be consistent in referring to 'item' or 'item_metadata'

  def get_collection(item)
    name = item['alveo:metadata']['dc:isPartOf']
    if @@COLLECTIONS.has_key? name
      collection = @@COLLECTIONS[name]
    else
      # TODO: super dodgy, fix this
      config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
      ActiveRecord::Base.establish_connection(config[:postgres_worker][:activerecord])
      ar_collection = Collection.find_by_name(name)
      collection = {id: ar_collection.id, owner: ar_collection.owner.email}
      @@COLLECTIONS[name] = collection
      ActiveRecord::Base.connection.close
    end
    collection
  end

  def get_handle(item)
    collection = item['alveo:metadata']['dc:isPartOf']
    identifier = item['alveo:metadata']['dc:identifier']
    "#{collection}:#{identifier}"
  end

  def get_types(item_metadata)
    types = []
    item_metadata['ausnc:document'].each { |document|
      type = document.has_key?('dc:type') ? document['dc:type'] : 'unspecified'
      types << type
    }
    types
  end

  ##
  # call-seq:
  #   date_group('6 September 1986') => '1980 - 1989'
  #   date_group('6 September 1986', 20) => '1980 - 1999'
  #
  # Takes the year from a `dc:created` string and returns the range
  # that it falls within, as specified by optional resolution parameter

  def get_date_group(item, resolution=10)
    result = 'Unknown'
    date_string = item['alveo:metadata']['dc:created']
    unless date_string.nil?
      begin
        year = extract_year(date_string)
        increment = year / resolution
        range_start = increment * resolution
        range_end = range_start + resolution - 1
        result = "#{range_start} - #{range_end}"
      rescue ArgumentError
        # TODO: Log error
      end
    end
    result
  end

  ##
  # call-seq:
  #   extract_year('6 September 1986') => 1986
  #   extract_year('Phase I fall') => 'Unknown'
  #
  # Extracts the year from a dc:created string. Handles the following examples
  #
  # * "1913?"
  # * "30/10/93"
  # * "96/05/17"
  # * "7-11/11/94"
  # * "17&19/8/93"
  # * "2012-03-07"
  # * "August 2000"
  # * "6 September 1986"
  # * "4 Spring 1986"
  # * "Phase I fall"

  def extract_year(created_field)
    created_field.chomp!('?')
    date_array = created_field.split(/[\-\/\&\s]/)
    begin
      candidate = Integer date_array.first
      if candidate > 31
        year = candidate
      else
        year = Integer date_array.last
      end
    rescue ArgumentError
      year = Integer date_array.last
    end
    year = year + 1900 if year < 100
    year
  end


end