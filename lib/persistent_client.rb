require 'net/http/persistent'
require_relative 'net_http_overrides'

class PersistentClient


  def initialize(name)
    @connection = Net::HTTP::Persistent.new(name)  
  end    

  def close
    @connection.shutdown
  end


  def perform_request(request)    
    response = @connection.request(request)
    if not reponse <= Net::HTTPSuccess
      raise "Error performing request: #{reponse.message} (#{reponse.code})"
    end
  end

  def build_request(path, request_type=:get, headers={}, body=nil)
    uri = URI.parse(path)
    request_class = Module.const_get("Net::HTTP::#{request_type.to_s.capitalize}")
    request = request_class.new(uri)
    headers.each_pair { |field, value|
      request.add_field(field, value)
    }
    request.body = body if body
    request
  end

end