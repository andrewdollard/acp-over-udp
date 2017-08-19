require_relative 'datagram'

class AcpConnection

  def initialize(listen_ip, listen_port, server_ip, server_port)
    @listen_ip = listen_ip
    @listen_port = listen_port
    @server_ip = server_ip
    @server_port = server_port
    @data_outbox = Queue.new
    @acp_outbox = Queue.new
  end

  def poll
    nil
  end

  def data
    nil
  end

  def parse(datagram)
    Datagram.new({
      source_ip: @listen_ip,
      source_port: @listen_port,
      dest_ip: @server_ip,
      dest_port: @server_port,
      seq: 0,
      ack: 5,
      message:'',
    })
  end


  def send(msg)
    Datagram.new({
      source_ip: @listen_ip,
      source_port: @listen_port,
      dest_ip: @server_ip,
      dest_port: @server_port,
      seq: 0,
      ack: 0,
      message: msg,
    })
  end

end

