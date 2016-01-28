$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'json'
require 'trove_ingester'

def main(config, start=0, stop=0)
  ingester = TroveIngester.new(config[:ingester])
  ingester.connect
  (start..stop).each{ |n|
    ingester.process_chunk("/data/production_collections/trove/data-#{n}.dat")
  }
  ingester.close
end

def process_file(config, file)
  ingester = TroveIngester.new(config[:ingester])
  ingester.connect
  ingester.process_chunk(file)
  ingester.close
end

if __FILE__ == $PROGRAM_NAME
  Process.setproctitle('Trove Ingester')
  Process.daemon(nochdir=true)
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  if ARGV.count == 2
    main(config, ARGV[0], ARGV[1])
  else
    process_file
  end  
end

