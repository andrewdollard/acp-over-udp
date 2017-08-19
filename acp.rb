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
        incoming = rcv(1024)
        dg = Datagram.parse(incoming)
        # puts "===RECEIVED: dg.inspect"
        responses = find_conn(dg.source_ip, dg.source_port).parse(dg)
        if responses.length > 0
          # puts "===LISTENER SENT: responses.inspect"
          responses.each do |resp|
            @sock.send(packet(resp), 0, @forward_ip, @forward_port)
          end
        end
      end
    end

    Thread.new do
      loop do
        sleep 5
        @connections.keys.each do |key|
          conn = @connections[key]
          responses = conn.poll
          if responses.length > 0
            # puts "===TIMER SENT: responses.inspect"
            responses.each do |resp|
              @sock.send(packet(resp), 0, @forward_ip, @forward_port)
            end
          end
        end
      end
    end
  end

  def send(msg, dest_ip, dest_port)
    responses = find_conn(dest_ip, dest_port).send(msg)
    # puts "===USER SENT: responses.inspect"
    responses.each do |resp|
      @sock.send(packet(resp), 0, @forward_ip, @forward_port)
    end
  end

  def rcv(len)
    msg, ip_addr = @sock.recv(len)
    msg
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

