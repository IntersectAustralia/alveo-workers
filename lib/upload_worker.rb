require_relative 'worker'
require_relative 'metadata_helper'
require_relative 'solr_helper'
require_relative 'postgres_helper'

class UploadWorker < Worker

  include MetadataHelper
  include SolrHelper
  include PostgresHelper

  def initialize(options)
    @solr_queue_name = options[:solr_queue]
    @postgres_queue_name = options[:postgres_queue]
    super(options[:rabbitmq])
  end

  def connect
    super
    @solr_queue = add_queue(@solr_queue_name)
    @postgres_queue= add_queue(@postgres_queue_name)
  end

  def process_message(headers, message)
    # TODO change these to CRUD verbs
    if headers['action'] == 'create'
      add_item(message['metadata'])
    end
  end

  def add_item(metadata)
    # generate catalogue url
    # extract full text if its not there already
    # generate handle?
    expanded_json_ld = expand_json_ld(metadata)
    create_item_solr(expanded_json_ld)
    create_item_postgres(expanded_json_ld)
  end

  def create_item_sesame(expanded_json_ld)
    # TODO: Sends JSON-LD
    properties = {routing_key: @sesame_queue.name, headers: {action: 'create'}}
    message = "{\"payload\": #{turtle.to_json}}"
    @exchange.publish(message, properties)
  end

  def create_item_solr(expanded_json_ld)
    solr_document = create_solr_document(expanded_json_ld)
    properties = {routing_key: @solr_queue.name, headers: {action: 'create'}}
    message = "{\"document\": #{solr_document.to_json}}"
    @exchange.publish(message, properties)
  end

  def create_item_postgres(expanded_json_ld)
    postgres_data = create_pg_statement(expanded_json_ld)
    properties = {routing_key: @postgres_queue.name, headers: {action: 'create'}}
    message = "{\"payload\": #{postgres_data.to_json}}"
    @exchange.publish(message, properties)
  end

end