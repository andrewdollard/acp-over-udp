require 'socket'
require_relative 'datagram'
require_relative 'acp_connection'
require 'pry'

class AcpClient

  connections = {}

  def initialize(listen_ip, listen_port, forward_ip, forward_port)
    @listen_ip = listen_ip
    @listen_port = listen_port
    @forward_ip = forward_ip
    @forward_port = forward_port
    @sock = UDPSocket.new
    @sock.bind(listen_ip, listen_port)
  end

  def send(msg, dest_ip, dest_port)
    d = Datagram.new({
      source_ip: @listen_ip,
      source_port: @listen_port,
      dest_ip: dest_ip,
      dest_port: dest_port,
      message: msg,
    })

    packet = "('#{d.serialize}', ('#{dest_ip}', #{dest_port}))"
    @sock.send(packet, 0, @forward_ip, @forward_port)
  end

  def rcv(len)
    msg, ip_addr = @sock.recv(len)
    datagram = Datagram.parse(msg)
    datagram.message

    ack_datagram = Datagram.new({
      source_ip: @listen_ip,
      source_port: @listen_port,
      dest_ip: dest_ip,
      dest_port: dest_port,
      ack: datagram.seq,
    })
  end

end

class AcpConnection

end
