require 'net/http/persistent'
require 'json'
require_relative 'net_http_overrides'
require_relative 'persistent_client'

class SesameClient < PersistentClient

  @@PATHS = {}

  def initialize(config)
    @base_url = config[:base_url]
    @paths = config[:paths]
    @config = config
    @mime_types = {sparql_json: 'application/sparql-results+json',
                   trig: 'application/x-trig',
                   turtle: 'text/turtle'
                  }
    super('SesameClient')
  end

  def create_repository(name)
    existing_repositories = repositories
    if existing_repositories.include? name
      raise "Repository already contains a collection named #{name}"
    end
    uri = get_statements_uri('SYSTEM')
    body = get_repository_template(name)
    request(uri, :post, {'Content-Type' => @mime_types[:trig]}, body)
    name
  end

  # TODO: move to module
  def get_repository_template(name)
    %Q(
        @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
        @prefix rep: <http://www.openrdf.org/config/repository#>.
        @prefix sr: <http://www.openrdf.org/config/repository/sail#>.
        @prefix sail: <http://www.openrdf.org/config/sail#>.
        @prefix sys: <http://www.openrdf.org/config/repository#> .
        @prefix ns: <http://www.openrdf.org/config/sail/native#>.

        _:#{name}{
          [] a rep:Repository ;
            rep:repositoryID "#{name}" ;
            rdfs:label "Metadata and Annotations for #{name} collection" ;
            rep:repositoryImpl [
              rep:repositoryType "openrdf:SailRepository" ;
              sr:sailImpl [
                sail:sailType "openrdf:NativeStore" ;
                ns:tripleIndexes "spoc,posc"
              ]
            ].
        }
        {
          _:#{name} a sys:RepositoryContext .
        }
      )
  end

  # TODO handle reponse errors
  def insert_statements(repository, ttl_string)
    uri = get_statements_uri(repository)
    request(uri, :post, {'Content-Type' => @mime_types[:turtle]}, ttl_string)
  end

  def repositories
    uri = get_repositories_uri
    repositories = []
    query_results = parse_json_response(request(uri, :get, {'Accept' => @mime_types[:sparql_json]}))
    query_results['results']['bindings'].each { |repository|
      repositories << repository['id']['value']
    }
    repositories
  end

  def get_repositories_uri
    URI.join(@base_url, 'repositories')
  end

  def get_statements_uri(repository)
    statements_path = "repositories/#{repository}/statements"
    URI.join(@base_url, statements_path)
  end



end