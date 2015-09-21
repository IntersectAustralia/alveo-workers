$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'jruby_multithreaded_ingester'
require 'yaml'
require 'benchmark'

def main(directory)
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  jr_mt_ingester = JRubyMultithreadedIngester.new(config[:mt_ingester])
  collection = File.basename(directory)
  Benchmark.bm { |reporter|
    reporter.report("Ingest (#{collection}):") {
      jr_mt_ingester.ingest(directory)
    }
  }
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  main(ARGV[0])
end