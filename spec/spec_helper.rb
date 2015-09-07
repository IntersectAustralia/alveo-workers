require 'rspec'
require 'rspec'
require 'json'
require 'yaml'
require 'simplecov'

require_relative 'support/bunny_mock'
require_relative 'support/r_solr_mock'

SimpleCov.start do
  add_filter 'spec' # ignore spec files
end

require_relative '../solr_helper'
require_relative '../metadata_helper'

require_relative '../worker'
require_relative '../solr_worker'
require_relative '../upload_worker'
