class RSolrMock

  def initialize(options)
    @responses = []
  end

  def set_responses(response)
    @responses += response
  end

  def post(options)
    @responses.shift
  end


  # def connect(options)
  #   Connection.new
  # end


  class Connection

    @responses = []

    def set_responses(response)
      @responses += response
    end

    def post(options)
      @responses.shift
    end

  end

end