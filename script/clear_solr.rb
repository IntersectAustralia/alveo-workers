require 'rsolr'

def main
  require 'yaml'
  config = YAML.load_file('../spec/files/config.yml')
  solr = RSolr.connect(url: config[:solr][:url])
  solr.delete_by_query '*:*'
  solr.commit
end


if __FILE__ == $PROGRAM_NAME
  main
end
