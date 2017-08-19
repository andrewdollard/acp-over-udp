require_relative 'datagram'

class AcpConnection

  attr_reader :outbox

  def initialize(listen_ip, listen_port, server_ip, server_port)
    @listen_ip = listen_ip
    @listen_port = listen_port
    @server_ip = server_ip
    @server_port = server_port
    @messages = []
    @sent_seq = 0
    @ackd_seq = 0
    @recd_seq = 0
    @outbox = []
  end

  def poll
    return [] if @ackd_seq == @sent_seq
    unackd.each_with_index.map do |msg, i|
      datagram(@ackd_seq + i + 1, msg)
    end
  end

  def send(incoming_msg)
    @messages << incoming_msg
    @sent_seq += 1
    unackd.each_with_index.map do |msg, i|
      datagram(@ackd_seq + i + 1, msg)
    end
  end

  def parse(datagram)
    # log_state("===PARSING===")
    # puts datagram.inspect
    print "#" if datagram.invalid?
    return [] if datagram.invalid?
    if datagram.ack > @ackd_seq
      print "$"
      @ackd_seq = datagram.ack
    end
    if datagram.seq == @recd_seq

    end
    if datagram.seq <= @recd_seq
      print "%"
      return [datagram(@sent_seq, '')]
    elsif datagram.seq == @recd_seq + 1
      @recd_seq += 1
      puts "received: #{datagram.message}"
      # @outbox << datagram.message
      # TODO make this respond with next unacked msg
      return [datagram(@sent_seq, '')]
    end
    []
  end

  private

  def datagram(seq, msg)
    Datagram.new({
      source_ip: @listen_ip,
      source_port: @listen_port,
      dest_ip: @server_ip,
      dest_port: @server_port,
      seq: seq,
      ack: @recd_seq,
      message: msg,
    })
  end

  def unackd
    @messages[@ackd_seq..-1]
  end

  def log_state(header)
    puts header
    puts "ackd_seq: #{@ackd_seq} sent_seq: #{@sent_seq} recd_seq: #{@recd_seq}"
    puts "all messages: #{@messages.inspect}"
  end

end

