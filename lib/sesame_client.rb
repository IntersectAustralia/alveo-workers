require 'net/http/persistent'
require 'json'
require_relative 'net_http_overrides'

class SesameClient

  @@PATHS = {}

  def initialize(config)
    @base_url = config[:base_url]
    @paths = config[:paths]
    @config = config
    @mime_types = {sparql_json: 'application/sparql-results+json',
                   trig: 'application/x-trig',
                   turtle: 'text/turtle'
                  }
  end

  def connect
    @connection = Net::HTTP::Persistent.new('Sesame Client')
  end

  def close
    @connection.shutdown
  end

  def create_repository(name)
    existing_repositories = repositories
    if existing_repositories.include? name
      raise "Repository already contains a collection named #{name}"
    end
    uri = get_named_path(:system)
    request = Net::HTTP::Post.new(uri)
    request.add_field('Content-Type', @mime_types[:trig])
    request.body = get_repository_template(name)
    reponse = @connection.request(request)
    if reponse.code != 204
      raise "Error creating repository: #{reponse.message} (#{reponse.code})"
    end
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
    request = Net::HTTP::Post.new(uri)
    request.add_field('Content-Type', @mime_types[:turtle])
    request.body = ttl_string
    @connection.request(request)
  end

  def repositories
    repositories = []
    query_results = sparql_query(:repositories)
    query_results['results']['bindings'].each { |repository|
      repositories << repository['id']['value']
    }
    repositories
  end

  def sparql_query(path)
    uri = get_named_path(path)
    query = Net::HTTP::Get.new(uri)
    query.add_field('Accept', @mime_types[:sparql_json])
    response = @connection.request(query)
    JSON.parse(response.body)
  end

  def get_named_path(path)
    URI.join(@base_url, @paths[path])
  end

  def get_statements_uri(repository)
    statements_path = "repositories/#{repository}/statements"
    URI.join(@base_url, statements_path)
  end



end