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
    # puts "===STARTING POLL==="
    # log_state
    return [] if @ackd_seq == @sent_seq
    sleep 2
    unackd.each_with_index.map do |msg, i|
      Datagram.new({
        source_ip: @listen_ip,
        source_port: @listen_port,
        dest_ip: @server_ip,
        dest_port: @server_port,
        seq: i + @ackd_seq + 1,
        ack: @recd_seq,
        message: msg,
      })
    end
  end

  def send(incoming_msg)
    @messages << incoming_msg
    @sent_seq += 1
    # puts "===STARTING SEND==="
    # log_state
    unackd.each_with_index.map do |msg, i|
      datagram(@ackd_seq + i + 1, @recd_seq, msg)
      # Datagram.new({
      #   source_ip: @listen_ip,
      #   source_port: @listen_port,
      #   dest_ip: @server_ip,
      #   dest_port: @server_port,
      #   seq: i + 1 + @ackd_seq,
      #   ack: @recd_seq,
      #   message: msg,
      # })
    end
  end

  def parse(datagram)
    # puts "===STARTING PARSE==="
    # puts datagram.inspect
    # log_state

    if datagram.ack > @ackd_seq
      @ackd_seq = datagram.ack
    end

    if datagram.seq == @recd_seq + 1
      @recd_seq += 1
      puts "message received: #{datagram.message}"
      return [datagram(@sent_seq, @recd_seq, '')]
      # return [Datagram.new({
      #   source_ip: @listen_ip,
      #   source_port: @listen_port,
      #   dest_ip: @server_ip,
      #   dest_port: @server_port,
      #   seq: @sent_seq,
      #   ack: @recd_seq,
      #   message:'',
      # })]
    elsif datagram.seq <= @recd_seq
      return [datagram(@sent_seq, @recd_seq, '')]
      # return [Datagram.new({
      #   source_ip: @listen_ip,
      #   source_port: @listen_port,
      #   dest_ip: @server_ip,
      #   dest_port: @server_port,
      #   seq: @sent_seq,
      #   ack: @recd_seq,
      #   message:'',
      # })]
    end
    []
  end

  private

  def datagram(seq, ack, msg)
    Datagram.new({
      source_ip: @listen_ip,
      source_port: @listen_port,
      dest_ip: @server_ip,
      dest_port: @server_port,
      seq: seq,
      ack: ack,
      message: msg,
    })
  end

  def unackd
    um = @messages[@ackd_seq..-1]
    puts "unacked: #{um}"
    um
  end

  def log_state
    puts "ackd_seq: #{@ackd_seq} sent_seq: #{@sent_seq} recd_seq: #{@recd_seq}"
    puts "all messages: @messages.inspect"
  end

end

