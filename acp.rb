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

    listen_thread = Thread.new do
      loop do
        sleep 3
        incoming = rcv(1024)
        dg = Datagram.parse(incoming)
        puts "===RECEIVED==="
        puts dg.inspect
        conn = @connections["#{dg.source_ip}#{dg.source_port}"]
        if conn
          responses = conn.parse(dg)
          if responses.length > 0
            puts "===LISTENER SENT==="
            puts responses.inspect
            responses.each do |resp|
              @sock.send(packet(resp), 0, @forward_ip, @forward_port)
            end
          end
        else
          conn = AcpConnection.new(@listen_ip, @listen_port, dg.source_ip, dg.source_port)
          @connections["#{dg.source_ip}#{dg.source_port}"] = conn
          responses = conn.parse(dg)
          if responses.length > 0
            puts "===LISTENER SENT==="
            puts responses.inspect
            responses.each do |resp|
              @sock.send(packet(resp), 0, @forward_ip, @forward_port)
            end
          end
        end
      end
    end

    timer_thread = Thread.new do
      loop do
        sleep 3
        @connections.keys.each do |key|
          conn = @connections[key]
          responses = conn.poll
          if responses.length > 0
            puts "===TIMER SENT==="
            puts responses.inspect
            responses.each do |resp|
              @sock.send(packet(resp), 0, @forward_ip, @forward_port)
            end
          end
        end
      end
    end
  end

  def send(msg, dest_ip, dest_port)
    conn = @connections["#{dest_ip}#{dest_port}"]
    if conn
      responses = conn.send(msg)
      puts "===USER SENT==="
      puts responses.inspect
      responses.each do |resp|
        @sock.send(packet(resp), 0, @forward_ip, @forward_port)
      end
    else
      conn = AcpConnection.new(@listen_ip, @listen_port, dest_ip, dest_port)
      @connections["#{dest_ip}#{dest_port}"] = conn
      responses = conn.send(msg)
      puts "===USER SENT==="
      puts responses.inspect
      responses.each do |resp|
        @sock.send(packet(resp), 0, @forward_ip, @forward_port)
      end
    end
  end

  def wait
    @outbox.pop(false)
  end

  def rcv(len)
    msg, ip_addr = @sock.recv(len)
    msg
  end

  def packet(datagram)
    "('#{datagram.serialize}', ('#{datagram.dest_ip}', #{datagram.dest_port}))"
  end

end

