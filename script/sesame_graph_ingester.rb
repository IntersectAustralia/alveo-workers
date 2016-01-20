$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'yaml'
require 'sesame_client'

def main(rdf_file)
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  sesame_client = SesameClient.new(config[:sesame_worker])
  batch_size = 250000
  count = 0
  batch = ''
  File.foreach(rdf_file) { |line|
    batch << line
    batch << "\n"
    count += 1
    if count >= batch_size
      uri = sesame_client.get_statements_uri('trove')
      sesame_client.request(uri, :post, {'Content-Type' => 'text/rdf+n3'}, batch)
      batch = ''
      count = 0
    end
  }
end



if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  main(ARGV[0])
end
