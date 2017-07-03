# This class parses /etc/services and provides a method
# for looking up the name of a service given the protocol
# and port number

module PortScanner
  class Scanner
    class ServiceMapper

      Service = Struct.new(:name, :port, :protocol, :description)
  
      attr_reader :services
  
      def initialize
        @services = []
        load_service_map
      end
  
      # Return the name of a service based on the port and protocol from /etc/services
      # @param protocol [String]
      # @param port [Fixnum]
      def name(protocol: , port: )
        svc = @services.find{|s| s.protocol == protocol && s.port == port.to_i}
        if svc.nil?
          'unknown'
        else
          svc.name
        end
      end
  
      private
  
      def load_service_map
        raw_contents = File.read("/etc/services").split("\n")
        raw_contents.reject!{|line| line.start_with?(' ') || line.start_with?('#') || line == ''}
        # split on whitespace:
        #  service name is position zero
        #  port/protocol are position two
        raw_contents.each do |service_line|
          chunks = service_line.split(/\s+/)
          service_name = chunks.shift
          port_protocol = chunks.shift
          port = port_protocol.split('/').first.to_i
          protocol = port_protocol.split('/').last
 
          @services << Service.new(service_name, port, protocol)
        end
      end
    end
  end
end
