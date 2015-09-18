require 'net/http/persistent'
require 'json'

# TODO: Refactor to persistent overrides module
class Net::HTTP::Get

  def method_missing(method, *args)
    @uri.send(method, *args)
  end

end

class Net::HTTP::Post

  def method_missing(method, *args)
    @uri.send(method, *args)
  end

end

class SesameClient

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
    # TODO: check if repository exists
    uri = get_named_path(:system)
    request = Net::HTTP::Post.new(uri)
    request.add_field('Content-Type', @mime_types[:trig])
    request.body = get_repository_template(name)
    @connection.request(request)
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

  def insert_statements(repository, ttl_string)
    uri = URI.parse("http://alveo-qa-sesame.intersect.org.au:8080/openrdf-sesame/repositories/#{repository}/statements")
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

end