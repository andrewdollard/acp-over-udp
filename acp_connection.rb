require_relative 'datagram'

class AcpConnection

  def initialize(listen_ip, listen_port, server_ip, server_port)
    @listen_ip = listen_ip
    @listen_port = listen_port
    @server_ip = server_ip
    @server_port = server_port
    @messages = []
    @sent_seq = 0
    @ackd_seq = 0
    @recd_seq = 0
  end

  def poll
    # log_state("===STARTING POLL===")
    return [] if @ackd_seq == @sent_seq
    unackd.each_with_index.map do |msg, i|
      datagram(@ackd_seq + i + 1, msg)
    end
  end

  def send(incoming_msg)
    @messages << incoming_msg
    @sent_seq += 1
    # log_state("===STARTING SEND===")
    unackd.each_with_index.map do |msg, i|
      datagram(@ackd_seq + i + 1, msg)
    end
  end

  def parse(datagram)
    # log_state("===STARTING PARSE===")
    # puts datagram.inspect
    if datagram.ack > @ackd_seq
      @ackd_seq = datagram.ack
      return []
    end
    if datagram.seq == @recd_seq + 1
      @recd_seq += 1
      puts "message received: #{datagram.message}"
      return [datagram(@sent_seq, '')]
    elsif datagram.seq <= @recd_seq
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
    um = @messages[@ackd_seq..-1]
    # puts "unacked: #{um}"
    um
  end

  def log_state(header)
    puts header
    puts "ackd_seq: #{@ackd_seq} sent_seq: #{@sent_seq} recd_seq: #{@recd_seq}"
    puts "all messages: @messages.inspect"
  end

end

