$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'trove_ingester'
require 'yaml'

def main(directory)
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  work = Dir[File.join(directory, '*.dat']
  processes = config[:trove_ingester][:processes]
  job_size = work.size / processes
  jobs = work.each_slice(job_size).to_a
  if jobs.size % processes != 0
    jobs.first.concat(jobs.last)
    jobs.delete(jobs.last)
  end
  jobs.each { |job|
    fork {
      ingester = TroveIngester.new(config[:trove_ingester])
      ingester.connect
      ingester.set_work(job)
      ingester.process
      ingester.close
    }
  }
 p Process.waitall
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  main(ARGV[0])
end