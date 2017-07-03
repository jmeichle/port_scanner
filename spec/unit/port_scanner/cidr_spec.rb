describe PortScanner::Cidr do
  let(:input_queue) { Queue.new }
  let(:work_class) { PortScanner::Scanner::Worker::Work }
  let(:work_double) { instance_double(work_class) }
  let(:subject) { described_class }

  context 'Work Creation' do
    it 'Enqueues a work object for each host, protocol, and port for the arguments' do
      expect(work_class).to receive(:new).with('127.0.0.1', 20..22, 'tcp').and_return(work_double)
      expect(input_queue).to receive(:<<).with(work_double)
      subject.new(input_queue: input_queue, cidr: '127.0.0.1', ports: (20..22), protocols: ['tcp']).setup
    end

    it 'Accepts CIDR ranges and parses them accordingly' do
      expect(work_class).to receive(:new).with('192.168.0.21', 22..22, 'tcp').and_return(work_double)
      expect(work_class).to receive(:new).with('192.168.0.22', 22..22, 'tcp').and_return(work_double)
      expect(work_class).to receive(:new).with('192.168.0.23', 22..22, 'tcp').and_return(work_double)
      expect(input_queue).to receive(:<<).exactly(3).times.with(work_double)
      subject.new(input_queue: input_queue, cidr: '192.168.0.20/30', ports: (22..22), protocols: ['tcp']).setup
    end

  end
end
