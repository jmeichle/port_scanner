describe PortScanner::Scanner do
  let(:cidr) { instance_double(PortScanner::Cidr) }
  let(:service_mapper) { instance_double(PortScanner::Scanner::ServiceMapper) }
  let(:worker) { instance_double(PortScanner::Scanner::Worker) }
  let(:subject) { described_class }

  context 'initialization creates the queues, service mapper, and workers' do
    before(:each) do
      expect(Queue).to receive(:new).twice.and_call_original
      allow(PortScanner::Cidr).to receive(:new).and_return(cidr)
      allow(cidr).to receive(:setup)
      expect(PortScanner::Scanner::ServiceMapper).to receive(:new).and_return(service_mapper)
    end
    
    it 'Defaults to 5 workers' do
      expect(PortScanner::Scanner::Worker).to receive(:new).exactly(5).times.and_return(worker)
      expect(worker).to receive(:run).exactly(5).times
      subject.new(cidr: '127.0.0.1', ports: (20..25)).setup
    end

    it 'Accepts a worker_count for the number of workers' do
      expect(PortScanner::Scanner::Worker).to receive(:new).exactly(13).times.and_return(worker)
      expect(worker).to receive(:run).exactly(13).times
      subject.new(cidr: '127.0.0.1', ports: (20..25), worker_count: 13).setup
    end
  end
end
