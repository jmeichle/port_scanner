require 'socket'

module PortScanner
  class Scanner
    class OpenPort
      attr_reader :host, :port, :service

      def initialize(host, port, service)
        @host = host
        @port = port
        @service = service
      end

      def to_s
        log = "#{@host}:#{@port}"
        log = log + " (#{@service})" unless @service.nil?
        log
      end
    end
  end
end
