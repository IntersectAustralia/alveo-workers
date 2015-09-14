require 'yaml'

require_relative 'upload_worker'
require_relative 'solr_worker'


def main(config)
  launch_workers(config)
  begin
    while true
      sleep 1
    end
  rescue SignalException
    @solr_worker.commit
  end
end

def launch_workers(config)
  @upload_worker = UploadWorker.new(config[:upload])
  @upload_worker.subscribe()
  @solr_worker = SolrWorker.new(config[:solr_worker])
  @solr_worker.subscribe()
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  config = YAML.load_file('spec/files/config.yml')
  main(config)
end