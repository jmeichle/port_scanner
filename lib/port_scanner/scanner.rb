require "port_scanner/scanner/open_port"
require "port_scanner/scanner/service_mapper"
require "port_scanner/scanner/worker"

module PortScanner
  class Scanner

    def initialize(cidr: , port_range: , worker_count: 5)
      @workers = []
      @worker_count = worker_count
      @input_queue = Queue.new
      @output_queue = Queue.new
      @service_mapper = ServiceMapper.new
      @port_range = port_range
      @cidr = Cidr.new(cidr: cidr, port_range: @port_range, input_queue: @input_queue, output_queue: @output_queue)
    end

    def setup
      @cidr.setup
      start_workers
    end

    def results
      @worker_count.times.each{ @input_queue << 'kill_thread' }
      join_workers
      @cidr.results
    end

    def host_count
      @cidr.host_count
    end

    def host_queue_size
      @input_queue.size
    end

    private

    def start_workers
      @worker_count.times.each do
        worker = Worker.new(service_mapper: @service_mapper, input_queue: @input_queue, output_queue: @output_queue)
        worker.run
        @workers << worker
      end
    end

    def join_workers
      @workers.each(&:join)
    end

  end
end