require 'port_scanner'
require 'timeout'

describe PortScanner::Scanner::Worker do

  let(:service_mapper) { instance_double(PortScanner::Scanner::ServiceMapper) }
  let(:input_queue) { Queue.new }
  let(:output_queue) { Queue.new }
  let(:subject) { described_class.new(service_mapper: service_mapper, input_queue: input_queue, output_queue: output_queue) }
  let(:socket) { instance_double(Socket) }

  before(:each) do
    allow(Socket).to receive(:new).and_return(socket)
  end

  it 'Kills the thread when a kill_thread message is received' do
    input_queue.push('kill_thread')
    subject.run
    subject.join
  end

  context 'host+port scanning on queue events' do
    it 'does nothing on invalid messages' do
      input_queue.push('Invalid Message')
      input_queue.push('kill_thread')    
      subject.run
      subject.join
      expect{
        output_queue.pop(non_block: true)
      }.to raise_error(ThreadError, /queue empty/)
    end

    context 'Connection Errors / Closed Port behavior' do
      before(:each) do
        input_queue.push(described_class::Work.new('127.0.0.1', 22))
        input_queue.push('kill_thread')    
      end

      it 'Returns no result for ECONNREFUSED' do        
        expect(socket).to receive(:connect).and_raise(Errno::ECONNREFUSED)
      end

      it 'Returns no result for EHOSTUNREACH' do        
        expect(socket).to receive(:connect).and_raise(Errno::EHOSTUNREACH)
      end

      it 'Returns no result for connection timeouts with the default timeout value (1.0)' do        
        expect(Timeout).to receive(:timeout).with(1.0).and_call_original
        expect(socket).to receive(:connect).and_raise(Timeout::Error)
      end

      after(:each) do
        subject.run
        subject.join
        expect{
          output_queue.pop(non_block: true)
        }.to raise_error(ThreadError, /queue empty/)
      end
    end

    it 'honors the optional connect_timeout value' do 
      input_queue.push(described_class::Work.new('127.0.0.1', 22))
      input_queue.push('kill_thread')
      subject = described_class.new(service_mapper: service_mapper, input_queue: input_queue, output_queue: output_queue, connect_timeout: 1337.0)
      expect(Timeout).to receive(:timeout).with(1337.0)
      subject.run
      subject.join
    end
  end

  it 'Returns an OpenPort object if the port connects' do
    input_queue.push(described_class::Work.new('127.0.0.1', 22))
    input_queue.push('kill_thread')
    expect(socket).to receive(:connect)
    expect(service_mapper).to receive(:name).with(protocol: 'tcp', port: 22).and_return('ssh')
    subject.run
    subject.join
    result = output_queue.pop
    expect(result).to be_a(PortScanner::Scanner::OpenPort)
    expect(result.host).to eq('127.0.0.1')
    expect(result.port).to eq(22)
    expect(result.service).to eq('ssh')
  end

end