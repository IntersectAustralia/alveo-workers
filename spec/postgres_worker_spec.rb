require 'spec_helper'

describe PostgresWorker do

  before(:all) do
    options = {
      activerecord: {},
      rabbitmq:
       {client_class: 'BunnyMock',
        work_queue: 'postgres'}
    }
    @postgres_worker = PostgresWorker.new(options)
  end

  let(:example_documents) {
    [{'file_name' => 'primary_text.txt',
     'file_path' => '/path/to/primary_text.txt',
     'doc_type' => 'Original',
     'mime_type' => 'text/plain'}]
  }

  let(:example_item) {
    {'uri' => 'http://ns.ausnc.org.au/corpora/ace/E29a',
        'handle' => 'ace:E29a',
        'primary_text_path' => 'file:///path/to/primary_text.txt',
        'documents' => example_documents,
        'json_metadata' => {key: 'value'}
        }
  }

  let(:example_message) {
    {'action' => 'create item',
     'payload' => {'item' => example_item,
                   'documents' => example_documents}
     }
  }

  describe '#create_item' do


  end

  
end
