$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'rsolr'
require 'active_record'
require 'models/item'
require 'models/document'

def main
  require 'yaml'
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  solr = RSolr.connect(url: config[:solr][:url])
  response = solr.get 'select', :params => {:wt => 'ruby'}
  solr_items = response['response']['numFound']
  ActiveRecord::Base.establish_connection(config[:postgres_worker][:activerecord])
  postges_items = Item.count
  puts "Postgres Items: #{postges_items}\t\t(#{config[:postgres_worker][:activerecord][:host]})"
  puts "Solr Items: #{solr_items}\t\t(#{config[:solr][:url]})"
end


if __FILE__ == $PROGRAM_NAME
  main
end
