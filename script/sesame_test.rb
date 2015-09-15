$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'sesame_client'


def main
  sesame_client = SesameClient.new(config[:sesame])

end

if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config)
end