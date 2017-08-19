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
    nil
  end

  def parse(datagram)
    puts "\n===RECEIVED==="
    puts datagram.inspect
    if datagram.seq == @recd_seq + 1
      @recd_seq += 1
      puts "message received: #{datagram.message}"
      return [Datagram.new({
        source_ip: @listen_ip,
        source_port: @listen_port,
        dest_ip: @server_ip,
        dest_port: @server_port,
        seq: @sent_seq,
        ack: @recd_seq,
        message:'',
      })]
    elsif datagram.seq < @recd_seq
      return [Datagram.new({
        source_ip: @listen_ip,
        source_port: @listen_port,
        dest_ip: @server_ip,
        dest_port: @server_port,
        seq: @sent_seq,
        ack: @recd_seq,
        message:'',
      })]
    end

    if datagram.ack > @ackd_seq
      @ackd_seq = datagram.ack
    end

    []
  end


  def send(incoming_msg)
    @messages << incoming_msg
    @sent_seq += 1
    unsent = @messages[(@ackd_seq)..(@sent_seq - 1)]
    unsent.each_with_index.map do |msg, i|
      Datagram.new({
        source_ip: @listen_ip,
        source_port: @listen_port,
        dest_ip: @server_ip,
        dest_port: @server_port,
        seq: i + 1 + @ackd_seq,
        ack: @recd_seq,
        message: msg,
      })
    end
  end

end

