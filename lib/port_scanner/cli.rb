require 'thor'
require 'pry'

module PortScanner
  class Cli < Thor

    desc 'scan', 'Scan'
    method_option :cidr, aliases: '-c', required: true, desc: 'The CIDR range to scan to scan'
    method_option :port_range, aliases: '-r', type: :string, desc: "The port range. @TODO how to do string to range for this?"
    method_option :worker_count, aliases: '-w', type: :numeric, default: 5, desc: "The number of scanner threads to run"
    def scan
      scanner = PortScanner::Scanner.new(cidr: options[:cidr], port_range: (1..65535), worker_count: options[:worker_count])
      scanner.setup
      max_queue_size = scanner.host_count
      scanner.results do |host_work, results|
        results.each do |result|
          puts result.to_s
        end
      end
    end

  end
end
