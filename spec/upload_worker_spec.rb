require 'spec_helper'

describe UploadWorker do

  before(:all) do
    @options = {rabbitmq: {client_class: 'BunnyMock', work_queue: 'upload'},
               solr_queue: 'solr_queue', solr: {}, postgres_queue: 'postgres'}
    @upload_worker = UploadWorker.new(@options)
    @upload_worker.connect
    @exchange = @upload_worker.instance_variable_get(:@exchange)
  end

  # describe '#create_item_solr' do

  #   it 'adds a create item job to the Solr Worker queue' do
  #     example = {key: 'value'}
  #     allow(@upload_worker).to receive(:create_solr_document).and_return(example)
  #     expected = '{"document": {"key":"value"}}'
  #     solr_queue = @exchange.get_queue(@options[:solr_queue])
  #     @upload_worker.create_item_solr('')
  #     expect(solr_queue.messages.first).to eq(expected)
  #   end

  # end

  # describe '#create_item_postgres' do

  #   it 'adds a create item job to the Postgres Worker queue' do
  #     example = {key: 'vaule'}
  #     allow(@upload_worker).to receive(:create_pg_statement).and_return(example)
  #     expected = '{"payload": {"key":"vaule"}}'
  #     postgres_queue = @exchange.get_queue(@options[:postgres_queue])
  #     @upload_worker.create_item_postgres('')
  #     expect(postgres_queue.messages.first).to eq(expected)
  #   end

  # end


end