class RSolrMock

  def initialize(options)
    @responses = []
  end

  def set_responses(response)
    @responses += response
  end

  def respond(options)
    @responses.shift
  end

  def add(options)
    respond(options)
  end

end