require 'thor'
require 'pry'

module PortScanner
  class Cli < Thor

    desc 'scan', 'Scan'
    option :cidr, aliases: '-c', desc: 'The CIDR range to scan to scan'
    # @todo option for port range, default to all
    def scan

    end

    desc 'pry', 'Run the pry console'
    def pry
      binding.pry
    end

  end
end
