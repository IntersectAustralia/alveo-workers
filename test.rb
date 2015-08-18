require 'pry'
require_relative 'solr_worker'

s = SolrWorker.new("solr.index", "solr.index")

binding.pry
