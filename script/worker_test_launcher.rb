$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'upload_worker'
require 'solr_worker'
require 'sesame_worker'

def main(config)
  launch_workers(config)
  begin
    while true
      print "Upload: #{@upload_worker.processed} " \
            "Solr: #{@solr_worker.processed} " \
            "Sesame: #{@sesame_worker.processed}\r"
      sleep 1
    end
  rescue SignalException
    # TODO: Add methods to shut workers down gracefully
    @solr_worker.commit
  end
end

def launch_workers(config)
  @upload_worker = UploadWorker.new(config[:upload_worker])
  @upload_worker.subscribe()
  @solr_worker = SolrWorker.new(config[:solr_worker])
  @solr_worker.subscribe()
  @sesame_worker = SesameWorker.new(config[:sesame_worker])
  @sesame_worker.subscribe()
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config)
end