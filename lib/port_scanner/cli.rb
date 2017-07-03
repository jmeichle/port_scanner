require 'thor'
require 'pry'

module PortScanner
  class Cli < Thor

    desc 'scan', 'Scan'
    method_option :cidr, aliases: '-c', required: true, desc: 'The CIDR range to scan to scan'
    method_option :ports, aliases: '-r', type: :string, default: '1-65535', desc: "The port range. This option supports multiple port numbers, and ranges (number-number) as CSV. ex: 80,443,1000-1500"
    method_option :worker_count, aliases: '-w', type: :numeric, default: 5, desc: "The number of scanner threads to run"
    def scan
      ports = []
      options[:ports].split(',').each do |split|
        if split.include?('-')
          range_split = split.split('-')
          (range_split.first.to_i..range_split.last.to_i).each do |port|
            ports << port
          end
        else
          ports << split.to_i
        end
      end
      scanner = PortScanner::Scanner.new(cidr: options[:cidr], ports: ports, worker_count: options[:worker_count])
      scanner.setup
      scanner.results do |host_result|
        host_result.last.each do |result|
          puts result.to_s
        end
      end
    end

  end
end
