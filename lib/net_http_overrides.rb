class Net::HTTP::Get

  def method_missing(method, *args)
    @uri.send(method, *args)
  end

end

class Net::HTTP::Post

  def method_missing(method, *args)
    @uri.send(method, *args)
  end

end