$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'sesame_client'
require 'active_record'
require 'models/item'
require 'models/document'

def main(config)
  sesame_client = SesameClient.new(config[:sesame_worker])
  turtle = File.open("#{File.dirname(__FILE__)}/../spec/files/turtle_example.rdf").read
  options = {adapter: 'postgresql', database: 'hcsvlab', user: 'hcsvlab', host: 'localhost'}
  ActiveRecord::Base.establish_connection(options)
  require 'pry'
  binding.pry
end

if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config)
end