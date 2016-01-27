$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'json'
require 'trove_ingester'

def main(config, start, stop)
  Process.setproctitle('Trove Ingester')
  Process.daemon(nochdir=true)
  ingester = TroveIngester.new(config[:ingester])
  ingester.connect
  (start..stop).each{ |n|
    ingester.process_chunk("/data/production_collections/trove/data-#{n}.dat")
    sleep(60*60*3)
  }
end

if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config, ARGV[0], ARGV[1])
end

