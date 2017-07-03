describe PortScanner::Scanner do
  let(:cidr) { instance_double(PortScanner::Cidr) }
  let(:service_mapper) { instance_double(PortScanner::Scanner::ServiceMapper) }
  let(:worker) { instance_double(PortScanner::Scanner::Worker) }
  let(:subject) { described_class }

  before(:each) do
    allow(PortScanner::Cidr).to receive(:new).and_return(cidr)
    allow(cidr).to receive(:setup)
    expect(PortScanner::Scanner::ServiceMapper).to receive(:new).and_return(service_mapper)
  end

  context 'initialization creates the queues, service mapper, and workers' do    
    before(:each) do
      expect(Queue).to receive(:new).twice.and_call_original
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

  context "results accessor" do
    let(:queue) { instance_double(Queue) }

    it 'Iterates on the output queue until it is empty, yielding results' do
      allow(Queue).to receive(:new).and_return(queue)
      allow(queue).to receive(:<<)
      expect(PortScanner::Scanner::Worker).to receive(:new).and_return(worker)
      expect(worker).to receive(:run)
      object = subject.new(cidr: '127.0.0.1', ports: (20..25), worker_count: 1)
      object.setup
      expect(queue).to receive(:pop).with(non_block: true).and_return('first_result')
      expect(queue).to receive(:pop).with(non_block: true).and_raise(ThreadError.new('queue empty'))
      expect(worker).to receive(:alive?).and_return(false)
      expect(queue).to receive(:pop).with(non_block: true).and_return('second_result')
      expect(queue).to receive(:pop).with(non_block: true).and_raise(ThreadError.new('queue empty'))
      expect(object).to receive(:sleep)
      yielded_results = []
      results = object.results do |result|
        yielded_results << result
      end
      expect(yielded_results).to eq(['first_result', 'second_result'])
      expect(results).to eq(['first_result', 'second_result'])
    end
  end
end
