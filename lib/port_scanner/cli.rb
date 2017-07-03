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
      puts "Creating work..."
      scanner.setup
      puts "Work created."
      max_queue_size = scanner.queue_size
      Thread.new do
        last_size = max_queue_size
        loop do
          sleep 1
          current_size = scanner.queue_size
          percentage = ((max_queue_size - current_size) / max_queue_size.to_f).round(6) * 100
          tick_amount = (last_size - current_size)
          last_size = current_size
          puts "Completed ( %3.2f precent) (#{max_queue_size}/#{current_size}) (this tick: #{tick_amount})" % percentage
        end
      end
      puts "Starting scan"
      scanner.results.each do |res|
        puts res.to_s
      end
      puts "done"
    end

  end
end
