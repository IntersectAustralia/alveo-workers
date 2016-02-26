$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'json'
require 'trove_ingester'

@ingesting = true
@resume = 'resume.log'
@processed = 'processed.log'
@resume_point = -1

def get_file_paths(directory)
  file_paths = Dir[File.join(directory, '*.dat')]
  processed = []
  if File.exists? @processed
    processed = File.read(@processed).split    
  end
  file_paths.select! { |file|
    !processed.include? file
  }
  if File.exists? @resume
    resume_file = File.read(@resume).split
    file_paths.unshift(resume_file.first)
    @resume_point = resume_file.last
  end
end

def main(config, directory)
  file_paths = get_file_paths(directory)
  ingester = TroveIngester.new(config[:ingester])
  ingesting = true
  Signal.trap('TERM') {
    ingesting = false
    ingester.ingesting = ingesting
  }
  ingester.connect
  file_paths.each { |file_path|
    ingester.process_chunk(file_path, @resume_point)
    @resume_point = -1
    if ingesting
      File.open(@processed, 'a') { |processed|
        processed.write("#{file_path}\n")
      }
    else
      File.open(@resume, 'w') { |processed|
        processed.write("#{file_path}\t{ingester.record_count}\n")
      }
      break
    end
  }
  ingester.close
end


if __FILE__ == $PROGRAM_NAME
  Process.setproctitle('TroveIngester')
  Process.daemon(nochdir=true)
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config, ARGV[0])
end

