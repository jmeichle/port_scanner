
# This class represents an open port on a host,
# and provides a convenience method for displaying
# the port
module PortScanner
  class Scanner
    class OpenPort
      attr_reader :host, :port, :service

      def initialize(host, port, protocol, service)
        @host = host
        @port = port
        @protocol = protocol
        @service = service
      end

      def to_s
        log = "#{@protocol} #{@host}:#{@port}"
        log = log + " (#{@service})" unless @service.nil?
        log
      end
    end
  end
end
