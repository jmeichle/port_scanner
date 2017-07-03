require 'ipaddress'

module PortScanner
  class Cidr

    # This class parses a CIDR range, submits ports to scan to the work queue
    # and handles results
    def initialize(cidr: , ports: , input_queue: , output_queue: , protocols: ['tcp'])
      @cidr = IPAddress.parse(cidr)
      @ports = ports
      @input_queue = input_queue
      @output_queue = output_queue
      @protocols = protocols
      @host_count = 0
    end

    def setup
      enqueue_work
    end

    def host_count
      @host_count
    end

    private

    def enqueue_work
      # ensure we dont scan network addresses
      # however http://www.rubydoc.info/gems/ipaddress/0.8.0/IPAddress/IPv4#hosts-instance_method
      # does odd things with /32 and single host strings, so check manually
      @cidr.each do |host|
        unless (host.network?)
          @protocols.each do |protocol|
            @host_count = @host_count + 1
            @input_queue << PortScanner::Scanner::Worker::Work.new(host.address, @ports, protocol)
          end
        end
      end
    end

  end
end