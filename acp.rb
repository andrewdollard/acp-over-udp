require 'socket'

class AcpConnection

  def initialize(listen_ip, listen_port, forward_ip, forward_port)
    @listen_ip = listen_ip
    @listen_port = listen_port
    @forward_ip = forward_ip
    @forward_port = forward_port
    @sock = UDPSocket.new
    @sock.bind(listen_ip, listen_port)
  end

  def send(msg, dest_ip, dest_port)
    complete_message = "('#{msg}', ('#{dest_ip}', #{dest_port}))"
    @sock.send(complete_message, 0, @forward_ip, @forward_port)
  end

  def rcv(len)
    msg, ip_addr = @sock.recv(len)
    msg
  end

end
