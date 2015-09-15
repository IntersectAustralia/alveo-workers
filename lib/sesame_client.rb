require 'net/http/persistent'

class SesameClient

  @mime_types {sparql_json: 'application/sparql-results+json'}


  def initialize(config)
    @base_url = URI.parse(config[:base_url])
    @paths = config[:paths]
    @config = config
  end

  def connect
    @sesame_client = Net::HTTP::Persistent.new('Sesame Client')
  end

  def repositories
    sparql_query(@paths[:repos])
  end

  def sparql_query(path)
    request =
    @sesame_client
  end

  def get_named_path(path)
    @base_url.join(@paths[path])
  end

end