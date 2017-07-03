require 'timeout'
require 'socket'

# This class represents one of the threadpool workers responsible
# for scanning a host. It accepts an input and output queue as well as
# a service mapper and connection timeout setting.

# The input queue is polled for Work objects. The Work objects represent a
# host, the ports to scan, and the protocol to scan with.

# The result of the host scan is then put onto the output queue. The format
# for that is an array of the original work object and an array of detected
# OpenPorts
module PortScanner
  class Scanner
    class Worker
      Work = Struct.new(:host, :ports, :protocol)

      def initialize(service_mapper: , input_queue: , output_queue: , connect_timeout: 0.01)
        @service_mapper = service_mapper
        @input_queue = input_queue
        @output_queue = output_queue
        @connect_timeout = connect_timeout
        @thread = nil
      end

      # To start this worker in a background thread
      def run
        @thread = Thread.new do
          load
        end
      end

      # Accessor to whether the work thread is still alive
      def alive?
        @thread.alive?
      end

      # Utility method to block until the thread completes
      def join
        @thread.join
      end

      private

      # Internal method to load work off the input queue.
      # It will break the loop (and thus end the thread) when 'kill_thread'
      # is received.
      def load
        loop do
          input = @input_queue.pop
          break if input == 'kill_thread'
          if input.is_a?(Work)
            work(input)
          end
        end
      end

      # Perform the scan on the given work object (representing one host).
      # This will iterate the defined ports, and rescue EHOSTUNREACH and
      # ENETUNREACH errors. If either error occurs, the rest of the ports are
      # skipped.
      def work(input)
        case input.protocol
        when 'tcp'
          results = []
          begin
            input.ports.each do |port|
              output = scan_tcp(input.host, port)
              results << output unless output.nil?
            end
          rescue *[Errno::EHOSTUNREACH, Errno::ENETUNREACH]
          end
          @output_queue << [input, results]
        end
      end

      # Perform the actual connection test for tcp
      def scan_tcp(host, port)
        s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
        begin
          # @todo don't use Timeout.timeout as it internally uses threads
          # and instead do unblocking connects with the Socket class
          Timeout.timeout(@connect_timeout) do
            s.connect(Socket.pack_sockaddr_in(port, host))
            svc_name = @service_mapper.name(protocol: 'tcp', port: port)
            OpenPort.new(host, port, 'tcp', svc_name)
          end
        rescue *[Timeout::Error, Errno::ECONNREFUSED] => e
          nil
        end
      end

    end
  end
end