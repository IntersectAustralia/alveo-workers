$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'ingester'
require 'yaml'

def main(directory)
  collection = File.basename(directory)
  work = Ingester.get_rdf_file_paths(directory)
  processes = get_cores
  job_size = work.size / processes
  jobs = work.each_slice(job_size).to_a
  if jobs.size % processes != 0
    jobs.first.concat(jobs.last)
    jobs.delete(jobs.last)
  end
  jobs.each { |job|
    fork {
      config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
      ingester = Ingester.new(config[:ingester])
      ingester.connect
      ingester.process_job(collection, job)
      ingester.close
    }
  }
 p Process.waitall
end

def get_cores
  cores = 1
  case RbConfig::CONFIG['host_os']
    when /darwin.*/
      cores = `sysctl -n hw.ncpu`.to_i
    when /linux/
      cores = `cat /proc/cpuinfo | grep processor | wc -l`.to_i
  end
  cores
end

if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  main(ARGV[0])
end