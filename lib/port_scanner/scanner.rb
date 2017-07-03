require "port_scanner/scanner/open_port"
require "port_scanner/scanner/service_mapper"
require "port_scanner/scanner/worker"

# This is the main scanner class. It accepts the CIDR range, ports array, and worker count
# It provides a setup method to create the workers and populate the input work queue
# It provides a results accessor method to consume the work and respective OpenPorts
# that were detected. The results accessor yields results as they come in, as well as returns them
module PortScanner
  class Scanner

    def initialize(cidr: , ports: , worker_count: 5)
      @workers = []
      @worker_count = worker_count
      @input_queue = Queue.new
      @output_queue = Queue.new
      @service_mapper = ServiceMapper.new
      @ports = ports
      @cidr = Cidr.new(cidr: cidr, ports: @ports, input_queue: @input_queue)
      @results = []
    end

    # Method to start the workers, and build out the input work queue via the Cidr class
    # After populating the input queue, it populates the queues with `kill_thread` so they
    # will end when no work remains
    def setup
      start_workers
      @cidr.setup
      @worker_count.times.each{ @input_queue << 'kill_thread' }
    end

    # Accessor method for the scan results. This method yields per-host results
    # as they are available on the output queue, and also returns the results.
    # The results are an array of arrays, with each element being:
    #  [ 
    #    "Work object (host/port/protocol)",
    #    [ Detected OpenPort objects ]
    #  ]
    def results
      loop do
        queue_pop do |res|
          yield res
        end
        sleep 1
        break if @workers.map {|w| w.alive?}.none?
      end
      # ensure there was nothing added to the queue after the workers completed.
      queue_pop do |res|
        yield res
      end
      @results
    end

    private

    # helper method to pop from the queue in a non blocking way, handling
    # empty queues. 
    def queue_pop
      begin
        loop do
          result = @output_queue.pop(non_block: true)
          @results << result
          yield result
        end
      rescue ThreadError => e
        raise unless e.message == 'queue empty'
      end
    end

    # Helper to start the workers
    def start_workers
      @worker_count.times.each do
        worker = Worker.new(service_mapper: @service_mapper, input_queue: @input_queue, output_queue: @output_queue)
        worker.run
        @workers << worker
      end
    end
  end
end