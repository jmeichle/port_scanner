require 'ipaddress'

module PortScanner
  class Cidr

    # This class parses a CIDR range, submits ports to scan to the work queue
    # and handles results
    def initialize(cidr: , port_range: , input_queue: , output_queue: , protocols: ['tcp'])
      @cidr = IPAddress.parse(cidr)
      @port_range = port_range
      @input_queue = input_queue
      @output_queue = output_queue
      @protocols = protocols
      @results = []
    end

    def setup
      enqueue_work
    end

    def results
      consume_results
      @results
    end

    private

    def enqueue_work
      # ensure we dont scan network addresses
      # however http://www.rubydoc.info/gems/ipaddress/0.8.0/IPAddress/IPv4#hosts-instance_method
      # does odd things with /32 and single host strings, so check manually
      @cidr.each do |host|
        unless (host.network?)
          @protocols.each do |protocol|
            @port_range.each do |port|
              @input_queue << PortScanner::Scanner::Worker::Work.new(host.address, port, protocol)
            end
          end
        end
      end
    end

    def consume_results
      begin
        loop do
          @results << @output_queue.pop(non_block: true)
        end
      rescue ThreadError => e
        raise unless e.message == 'queue empty'
      end
    end

  end
end