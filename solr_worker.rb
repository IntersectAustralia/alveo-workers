require_relative 'worker'
require 'rsolr'

class SolrWorker < Worker

  def initialize(inqueue_name, outqueue_name)
    super(inqueue_name, outqueue_name)
  end




end
