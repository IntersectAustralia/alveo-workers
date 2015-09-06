require 'rspec'
require 'rspec'
require 'json'
require 'yaml'
require 'simplecov'

require_relative 'support/bunny_mock'

SimpleCov.start do
  add_filter 'spec' # ignore spec files
end

require_relative '../solr_helper'
require_relative '../solr_worker'
