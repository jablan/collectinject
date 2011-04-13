module CollectInject

  # base worker class. you should inherit it and implement methods
  # +map+ and +reduce+. See examples/ dir for possible implementations.
  class WorkerBase
    attr_reader :intermediate_data # mapper outputs here
    attr_reader :output_data # reducer outputs here

    def initialize 
      reset
    end

    # runs +map+ on each item in an input chunk and emits its result
    def map_items items
      items.each do |item|
        map_emit(*map(item))
      end
    end

    # map method should receive an item which should be processed
    # returns corresponding (key, value) pair
    # This is just example implementation and should be overridden in inherited class
    def map item
      [:key, item]
    end

    # reduce processes a list generated for each key and returns a single value
    # This is just example implementation and should be overridden in inherited class
    def reduce key, list
      :result
    end

    # stores result of single +map+ operation to intermediate data store
    def map_emit key, value
      @intermediate_data[key] ||= []
      @intermediate_data[key] << value
    end

    # clears all local storage, preparing for be filled with new data
    def reset
      @map_data = nil
      @reduce_data = {}
      @intermediate_data = {}
      @output_data = []
    end

    # Feed worker with initial dataset (usually a chunk of original input data)
    def load_map_data data
      @map_data = data
    end
    
    # between map and reduce, feed reduce with appropriate data
    def append_reduce_data key, list
      @reduce_data[key] ||= []
      @reduce_data[key] << list
    end

    # run map on initial data chunk
    def run_map
      map_items @map_data
    end

    # run reduce on data processed by map
    def run_reduce
      @reduce_data.each do |key, list|
        result = reduce key, list
        @output_data << result
      end
    end
  end

  # Manager instantiates workers, feeds them with data and puts them to work
  class Manager
    # receives worker class and number of workers to instantiate and run
    def initialize worker_class, worker_count
      @worker_class = worker_class
      @worker_count = worker_count
      @workers = (0...@worker_count).map{
        @worker_class.new
      }
    end

    # based on data key, decide which worker should be fed with data for reduce
    def get_reducer_index key
      key.hash % @worker_count
    end

    # executing collectinject job on given data
    # returns processed data
    def run data
      # splitting data into N chunks:
      data.group_by.with_index{|elem, i| i % @worker_count}.map{ |i, chunk|
        Thread.new do
          # initializing workers and running map
          @workers[i].reset
          @workers[i].load_map_data chunk
          @workers[i].run_map
        end
      }.map(&:join) # waiting for all to finish

      # distributing data for reduce phase
      @workers.each do |worker|
#        p worker.intermediate_data
        worker.intermediate_data.each do |k, v|
          @workers[get_reducer_index(k)].append_reduce_data(k, v)
        end
      end

      # running reduce phase
      (0...@worker_count).map{ |i|
        Thread.new do
          @workers[i].run_reduce
        end
      }.map(&:join) # waiting for all to finish

      # collect data from reducers and return it
      @workers.map(&:output_data).inject(&:+)
    end
  end
end
