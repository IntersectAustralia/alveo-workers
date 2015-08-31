module SolrHelper

  def create_solr_document()

  end

    ##
  # :call-seq
  #   date_group('6 September 1986') => '1980 - 1989'
  #   date_group('6 September 1986', 20) => '1980 - 1999'
  #
  # Takes the year from a `dc:created` string and returns the range
  # that it falls within, as specified by the option resolution

  def date_group(dc_created_string, resolution=10)
    begin
      year = extract_year(dc_created_string)
      increment = year / resolution
      range_start = increment * resolution
      range_end = start + resolution - 1
      result "#{range_start} - #{range_end}"
    rescue ArgumentError
      result = 'Unknown'
    end
      result
  end

  ##
  # :call-seq
  #   extract_year('6 September 1986') => 1986
  #   extract_year('Phase I fall') => 'Unknown'
  #
  # Extracts the year from a `dc:created` string. Returns
  #
  #   * "1913?"
  #   * "30/10/93"
  #   * "96/05/17"
  #   * "7-11/11/94"
  #   * "17&19/8/93"
  #   * "2012-03-07"
  #   * "August 2000"
  #   * "6 September 1986"
  #   * "4 Spring 1986"
  #   * "Phase I fall"

  def extract_year(dc_created_string)
    dc_created_string.chomp!('?')
    date_array = dc_created_string.split(/[\-\/\&\s]/)
    begin
      candidate = Integer date_array.first
      if candidate > 31
        year = candidate
      else
        year = Integer date_array.last
      end
    rescue ArgumentError
      year = Integer date_array.last
    end
    year = year + 1900 if year < 100
    year
  end

end