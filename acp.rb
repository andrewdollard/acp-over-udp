require 'pry'
require 'socket'
require_relative 'datagram'
require_relative 'acp_connection'

class AcpClient

  def initialize(listen_ip, listen_port, forward_ip, forward_port)
    @connections = {}
    @listen_ip = listen_ip
    @listen_port = listen_port
    @forward_ip = forward_ip
    @forward_port = forward_port
    @sock = UDPSocket.new
    @sock.bind(listen_ip, listen_port)

    Thread.new do
      loop do
        dg = Datagram.parse(sock_read)
        responses = find_conn(dg.source_ip, dg.source_port).parse(dg)
        # puts "===RECEIVED: dg.inspect"
        # puts "===LISTENER SENT: responses.inspect"
        responses.each { |resp| sock_write(resp) }
      end
    end

    Thread.new do
      loop do
        sleep 2
        @connections.each_value do |conn|
          responses = conn.poll
          # puts "===TIMER SENT: responses.inspect"
          responses.each { |resp| sock_write(resp) }
        end
      end
    end

  end

  def send(msg, dest_ip, dest_port)
    responses = find_conn(dest_ip, dest_port).send(msg)
    # puts "===USER SENT: responses.inspect"
    responses.each { |resp| sock_write(resp) }
  end

  private

  def sock_read
    msg, ip_addr = @sock.recv(1024)
    msg
  end

  def sock_write(datagram)
      @sock.send(packet(datagram), 0, @forward_ip, @forward_port)
  end

  def packet(datagram)
    "('#{datagram.serialize}', ('#{datagram.dest_ip}', #{datagram.dest_port}))"
  end

  def find_conn(ip, port)
    conn = @connections["#{ip}#{port}"]
    return conn if conn
    conn = AcpConnection.new(@listen_ip, @listen_port, ip, port)
    @connections["#{ip}#{port}"] = conn
    conn
  end

end

