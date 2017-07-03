require 'port_scanner'

describe PortScanner::Scanner::ServiceMapper do

  let(:subject) { described_class.new }

  before(:each) do
    # ensure the file is only read once
    expect(File).to receive(:read).with('/etc/services').once.and_return(load_fixture('etc-services'))
  end

  it 'Returns the service name from /etc/services when provided a port and protocol' do
    expect(subject.name(protocol: 'tcp', port: 22)).to eq('ssh')
    expect(subject.name(protocol: 'tcp', port: 25)).to eq('smtp')
    expect(subject.name(protocol: 'tcp', port: 80)).to eq('http')
  end

  it 'Returns unknown when no service name is found' do
    expect(subject.name(protocol: 'tcp', port: 12345)).to eq('unknown')
  end

end