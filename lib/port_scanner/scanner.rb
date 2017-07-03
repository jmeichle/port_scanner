require "port_scanner/scanner/open_port"
require "port_scanner/scanner/service_mapper"
require "port_scanner/scanner/worker"

module PortScanner
  class Scanner

    def initialize(cidr: , ports: , worker_count: 5)
      @workers = []
      @worker_count = worker_count
      @input_queue = Queue.new
      @output_queue = Queue.new
      @service_mapper = ServiceMapper.new
      @ports = ports
      @cidr = Cidr.new(cidr: cidr, ports: @ports, input_queue: @input_queue, output_queue: @output_queue)
      @results = []
    end

    def setup
      start_workers
      @cidr.setup
      @worker_count.times.each{ @input_queue << 'kill_thread' }
    end

    def results
      loop do
        begin
          loop do
            result = @output_queue.pop(non_block: true)
            @results << result
            yield result
          end
        rescue ThreadError => e
          raise unless e.message == 'queue empty'
        end
        sleep 1
        break if @workers.map {|w| w.alive?}.none?
      end
      @results
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