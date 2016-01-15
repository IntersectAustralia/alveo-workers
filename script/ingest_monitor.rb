$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require 'active_record'
require 'rsolr'
require 'yaml'
require 'net/http'
require 'models/item'

def main(config)
  Process.setproctitle('Ingest Monitor')
  Process.daemon(nochdir=true)
  begin
    thread = Thread.new {
      @monitoring = true
      connect(config)
      prev_pg_count = 0
      prev_solr_count = 0
      prev_sesame_count = 0
      while @monitoring
        pg_count = get_pg_count
        solr_count = get_solr_count
        sesame_count = get_sesame_count
        pg_diff = prev_pg_count - pg_count
        solr_diff = prev_solr_count - solr_count
        sesame_diff = prev_sesame_count - sesame_count
        File.open('ingest_count.log', 'a') { |f|
          f.write "#{pg_count}\t#{solr_count}\t#{sesame_count}\t#{pg_diff}\t#{solr_diff}\t#{sesame_diff}\n"
        }
        prev_pg_count = pg_count
        prev_solr_count = solr_count
        prev_sesame_count = sesame_count
        sleep 60
      end
      close
    }
    thread.join
  rescue SignalException
    @monitoring = false
  end
end

def connect(config)
  @sesame_url = URI.parse('http://alveo-qa-sesame.intersect.org.au:8080/openrdf-sesame/repositories/trove/size')
  @solr_client = RSolr.connect(url: config[:solr_worker][:url])
  ActiveRecord::Base.establish_connection(config[:postgres_worker][:activerecord])
end


def close
  ActiveRecord::Base.connection.close
end


def get_pg_count
  Item.count
end

def get_solr_count
  solr_response = @solr_client.get('select', params: {q: '*:*', rows: 0})
  solr_count = solr_response['response']['numFound']
end

def get_sesame_count
  req = Net::HTTP::Get.new(@sesame_url.to_s)
  res = Net::HTTP.start(@sesame_url.host, @sesame_url.port) {|http|
    http.request(req)
  }
  res.body.to_i
end


if __FILE__ == $PROGRAM_NAME
  # TODO: use an argument parser
  config = YAML.load_file("#{File.dirname(__FILE__)}/../spec/files/config.yml")
  main(config)
end
