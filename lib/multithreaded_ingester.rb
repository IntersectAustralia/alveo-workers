require_relative 'ingester'

class MultithreadedIngester

  def initialize(options)
    @worker_count = options[:worker_count]
    @workers = []
    # TODO: Error logger is shared between threads,
    #       this may cause issues.
    @ingester_options = options[:ingester]
    @ingester_options.freeze
  end

  def ingest(dir)
    collection = File.basename(dir)
    jobs = prepare_jobs(dir)
    launch_workers(collection, jobs)
  end

  def launch_workers(collection, jobs)
    jobs.each { |job|
      @workers << Thread.new {
        ingester = Ingester.new(@ingester_options)
        ingester.connect
        ingester.process_job(collection, job)
        ingester.close
      }
    }
    @workers.each{ |worker| worker.join }
  end

  def prepare_jobs(dir)
    work = Ingester.get_rdf_file_paths(dir)
    slice_size = work.size / @worker_count
    work.each_slice(slice_size).to_a
  end

end