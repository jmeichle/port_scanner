module PortScanner
  class Scanner
    class Worker
      Work = Struct.new(:host, :port)

      def initialize(service_mapper: , input_queue: , output_queue: , connect_timeout: 1.0)
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

      def join
        @thread.join
      end

      private

      def load
        loop do
          input = @input_queue.pop
          break if input == 'kill_thread'
          if input.is_a?(Work)
            output = work(input)
            @output_queue << output unless output.nil?
          end
        end
      end

      def work(input)
        s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
        begin
          Timeout.timeout(@connect_timeout) do
            s.connect(Socket.pack_sockaddr_in(input.port, input.host))
            svc_name = @service_mapper.name(protocol: 'tcp', port: input.port)
            OpenPort.new(input.host, input.port, svc_name)
          end
        rescue *[Timeout::Error, Errno::ECONNREFUSED, Errno::EHOSTUNREACH] => e
          nil
        end
      end

    end
  end
end