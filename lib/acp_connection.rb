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
    next_datagram
  end

  def send(incoming_msg)
    @messages << incoming_msg
    @sent_seq += 1
    next_datagram
  end

  def parse(datagram)
    return [] if datagram.invalid?

    new_ack = false
    if datagram.ack > @ackd_seq
      @ackd_seq = datagram.ack
      new_ack = true
    end

    if (datagram.seq <= @recd_seq) && !new_ack
      return next_datagram

    elsif datagram.seq == @recd_seq + 1
      @recd_seq += 1
      @outbox << datagram.message
      return next_datagram
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

  def next_datagram
    if @messages.length > 0
      [datagram(@ackd_seq + 1, @messages[@ackd_seq])]
    else
      [datagram(@ackd_seq, '')]
    end
  end

end

