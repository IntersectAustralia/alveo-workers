$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'rsolr'
require 'active_record'
require 'models/item'
require 'models/document'
require 'models/collection'

def main
  require 'yaml'
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  solr = RSolr.connect(url: config[:solr][:url])
  solr.delete_by_query '*:*'
  solr.commit
  ActiveRecord::Base.establish_connection(config[:postgres_worker][:activerecord])
  Item.delete_all
  Collection.delete_all
end


if __FILE__ == $PROGRAM_NAME
  main
end
