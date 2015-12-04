
SESAME_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/sesame.yml")[Rails.env]
server = RDF::Sesame::HcsvlabServer.new(SESAME_CONFIG["url"].to_s)
repository = server.repository('ace')
rdf_uri = RDF::URI.new('http://ns.ausnc.org.au/corpora/ace/items/E29a')
basic_results = repository.query(:subject => rdf_uri)

document_predicate = RDF::URI.new('http://ns.austalk.edu.au/document')