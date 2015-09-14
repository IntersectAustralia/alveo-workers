require 'open-uri'
require 'json/ld'

module MetadataHelper

  def expand_json_ld(metadata)
    if metadata.instance_of? String
      metadata = load_json_from_file_url(metadata)
    end
    JSON::LD::API.expand(metadata)
  end

  def load_json_from_file_url(url)
    file_path = get_file_path_from_url(url)
    JSON.load(File.open(file_path))
  end

  def get_file_path_from_url(url)
    parsed_uri = URI.parse(url)
    if parsed_uri.scheme != 'file'
      raise 'Metadata must be in a file URI'
    end
    parsed_uri.path
  end

end