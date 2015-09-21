require_relative 'ingester'
require 'java'

# 'java_import' is used to import java classes


class IngesterThreadWrapper

  java_import 'java.util.concurrent.Callable'
  include Callable

  def initialize(ingester_options, collection, job)
    @ingester_options = ingester_options
    @collection = collection
    @job = job
  end

  def call
    ingester = Ingester.new(@ingester_options)
    ingester.connect
    ingester.process_job(@collection, @job)
    ingester.close
  end

end


class JRubyMultithreadedIngester

  java_import 'java.util.concurrent.FutureTask'
  java_import 'java.util.concurrent.LinkedBlockingQueue'
  java_import 'java.util.concurrent.ThreadPoolExecutor'
  java_import 'java.util.concurrent.TimeUnit'

  def initialize(options)
    @worker_count = options[:worker_count]
    @workers = []
    # TODO: Error logger is shared between threads,
    #       this may cause issues.
    @ingester_options = options[:ingester]
    @ingester_options.freeze
  end

  def launch_workers(collection, jobs)
    executor = ThreadPoolExecutor.new(@worker_count, # core_pool_treads
                                      @worker_count, # max_pool_threads
                                      60, # keep_alive_time
                                      TimeUnit::SECONDS,
                                      LinkedBlockingQueue.new)
    jobs.each { |job|
      task = FutureTask.new(IngesterThreadWrapper.new(@ingester_options, collection, job))
      executor.execute(task)
      @workers << task
    }
    @workers.each{ |worker| worker.get }
  end

  def ingest(dir)
    collection = File.basename(dir)
    jobs = prepare_jobs(dir)
    launch_workers(collection, jobs)
  end

  def prepare_jobs(dir)
    work = Ingester.get_rdf_file_paths(dir)
    slice_size = work.size / @worker_count
    work.each_slice(slice_size).to_a
  end

end
