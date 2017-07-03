describe PortScanner::Cli do
  let(:subject) { described_class.new }
  context 'ports parsing' do
    it 'Accepts simple CSV of port numbers' do
      expect(subject.parse_ports('1,2,3,4,5')).to eq([1,2,3,4,5])
    end

    it 'Accepts port ranges' do
      expect(subject.parse_ports('1-5')).to eq([1,2,3,4,5])
    end

    it 'Fails on invalid port ranges' do
      expect{
        subject.parse_ports('5-1')
      }.to raise_error(Thor::Error, /Ranges must start with the lower number \(5 < 1\)/)
    end

    it 'Allows combinations' do
      expect(subject.parse_ports('1,10,20-25')).to eq([1,10,20,21,22,23,24,25])
    end
  end

  context 'scan method' do
    let(:scanner) { instance_double(PortScanner::Scanner) }
    it 'Builds a scanner, printing results' do
      expect(PortScanner::Scanner).to receive(:new).with(cidr: '127.0.0.1', ports: [22,23,24], worker_count: 32).and_return(scanner)
      expect(scanner).to receive(:setup)
      expect(scanner).to receive(:results).and_yield([nil, ['mock output']])
      expect {
        described_class.start('scan -c 127.0.0.1 -r 22-24'.split, debug: true)
      }.to output("mock output\n").to_stdout
    end
  end
end
