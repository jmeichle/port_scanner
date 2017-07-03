# Ruby PortScanner

This is a ruby based port scanner.

## Installation

This program was written using ruby `2.3.1`, but should work on older versions. To use it:

Clone the repo, and then execute:

    $ bundle install

If bundler is not available, install it with `gem install bundler`.

## Usage

The tool is exposed via the `bin/port-scan` Thor binary. It has a single task, `scan`. The method docs are shown here:

```
jmeichle@jkm-desktop:~/port_scanner$ ruby bin/port-scan help scan
Usage:
  port-scan scan -c, --cidr=CIDR

Options:
  -c, --cidr=CIDR         # The CIDR range to scan to scan
  -r, [--ports=PORTS]     # The port range. This option supports multiple port numbers, and ranges (number-number) as CSV. example: 80,443,1000-1500
                          # Default: 1-65535
  -w, [--worker-count=N]  # The number of scanner threads to run
                          # Default: 5

Perform a TCP based port scan of the provided CIDR range and port range.
```
## Overview

The scanner operates in a threaded model. The worker threads operate on a host within the network range. Within each host, ports are scanned sequentially.

If a host is unreachable, or a network is unreachable, the remaining ports for the host are not scanned to save resources.

## Next steps

Investigate if having a separate threadpool for scanning blocks of ports on each host would help performance. There is an overhead with ruby queues, but the next step of slicing each per-host port range might help.

## Examples

* `ruby bin/port-scan scan -c 127.0.0.1` 

Scans all ports on localhost. Example output:

```
jmeichle@jkm-desktop:~/port_scanner$
tcp 127.0.0.1:22 (ssh)
tcp 127.0.0.1:111 (sunrpc)
tcp 127.0.0.1:631 (ipp)
tcp 127.0.0.1:3306 (mysql)
tcp 127.0.0.1:33349 (unknown)
tcp 127.0.0.1:34062 (unknown)
tcp 127.0.0.1:34491 (unknown)
tcp 127.0.0.1:45666 (unknown)
tcp 127.0.0.1:55526 (unknown)
```

This will scan all ports by default

* `ruby bin/port-scan scan -c 192.168.0.1/24 -r 1-1024 -w 10` 

This will scan the 192.168.0.1/24 range, and only scan ports 1 through 1024. It will also use 10 threads for scanning as opposed to the default of 32 threads.

* `ruby bin/port-scan scan -c 192.168.0.1/24 -r 22,25,80,443,8080`

This will also scan the 192.168.0.1/24 range, but only for ports 22, 25, 80, 443, and 8080, using the default number of threads (32).

## Development

After checking out the repo and running `bundle install`, unit tests can be ran via `rake spec`. Coverage reports will be written to `coverage/index.html`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jmeichle/port_scanner.
