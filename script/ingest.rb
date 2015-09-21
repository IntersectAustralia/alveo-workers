$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'ingester'
require 'yaml'

def main(directory)
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  ingester = Ingester.new(config[:ingester])
  ingester.connect
  ingester.ingest_directory(directory)
  ingester.close
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  main(ARGV[0])
end