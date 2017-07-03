require 'port_scanner'

describe PortScanner::Scanner::OpenPort do
  let(:subject) { described_class.new('127.0.0.1', '22', 'ssh') }

  it 'Has a simple to_s method that includes the service' do
    expect(subject.to_s).to eq("127.0.0.1:22 (ssh)")
  end
end