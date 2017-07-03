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
      Thread.new do
        last_size = max_queue_size
        loop do
          sleep 3
          current_size = scanner.host_queue_size
          percentage = ((max_queue_size - current_size) / max_queue_size.to_f).round(6) * 100
          tick_amount = (last_size - current_size)
          last_size = current_size
          STDERR.puts "Completed ( %3.2f precent) remaining: (#{current_size} hosts / #{max_queue_size} total hosts) " % percentage
        end
      end
      scanner.results.each do |host_work, results|
        results.each do |result|
          puts result.to_s
        end
      end
    end

  end
end
