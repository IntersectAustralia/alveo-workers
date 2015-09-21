$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'upload_worker'
require 'solr_worker'
require 'sesame_worker'

def main(config)
  start_workers(config)
  begin
    while true
      print "Upload: #{@upload_worker.processed} " \
            "Solr: #{@solr_worker.processed} " \
            "Sesame: #{@sesame_worker.processed}\r"
      sleep 1
    end
  rescue SignalException
    stop_workers
  end
end

def stop_workers
  @upload_worker.stop
  @solr_worker.stop
  @sesame_worker.stop
end

def start_workers(config)
  @upload_worker = UploadWorker.new(config[:upload_worker])
  @upload_worker.start
  @solr_worker = SolrWorker.new(config[:solr_worker])
  @solr_worker.start
  @sesame_worker = SesameWorker.new(config[:sesame_worker])
  @sesame_worker.start
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config)
end