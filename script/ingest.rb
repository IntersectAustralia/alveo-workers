require_relative '../lib/ingester'

def main(directory)
  require 'yaml'
  config = YAML.load_file('../spec/files/config.yml')
  ingester = Ingester.new(config[:ingester])
  ingester.ingest_rdf(directory)
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  main(ARGV[0])
end