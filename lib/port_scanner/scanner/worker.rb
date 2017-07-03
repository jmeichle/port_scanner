require 'timeout'

module PortScanner
  class Scanner
    class Worker
      Work = Struct.new(:host, :port_range, :protocol)

      def initialize(service_mapper: , input_queue: , output_queue: , connect_timeout: 0.01)
        @service_mapper = service_mapper
        @input_queue = input_queue
        @output_queue = output_queue
        @connect_timeout = connect_timeout
        @thread = nil
      end

      def run
        @thread = Thread.new do
          load
        end
      end

      def alive?
        @thread.alive?
      end

      def join
        @thread.join
      end

      private

      def load
        loop do
          input = @input_queue.pop
          break if input == 'kill_thread'
          if input.is_a?(Work)
            work(input)
          end
        end
      end

      def work(input)
        case input.protocol
        when 'tcp'
          results = []
          begin
            input.port_range.each do |port|
              output = scan_tcp(input.host, port)
              results << output unless output.nil?
            end
          rescue *[Errno::EHOSTUNREACH, Errno::ENETUNREACH]
          end
          @output_queue << [input, results]
        end
      end

      def scan_tcp(host, port)
        s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
        begin
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