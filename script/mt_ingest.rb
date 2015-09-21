$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'multithreaded_ingester'
require 'yaml'
require 'benchmark'

def main(directory)
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  mt_ingester = MultithreadedIngester.new(config[:mt_ingester])
  collection = File.basename(directory)
  Benchmark.bm { |reporter|
    reporter.report("Ingest (#{collection}):") {
      mt_ingester.ingest(directory)
    }
  }
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  main(ARGV[0])
end