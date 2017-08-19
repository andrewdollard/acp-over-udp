require 'socket'
require_relative 'datagram'
require_relative 'acp_connection'
require 'pry'

class AcpClient

  def initialize(listen_ip, listen_port, forward_ip, forward_port)
    @connections = {}
    @outbox = Queue.new
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
        conn = @connections["#{dg.source_ip}#{dg.source_port}"]
        if conn
          response = conn.parse(dg)
          new_data = conn.data
          @outbox << new_data if new_data
          puts "listener sending, existing connection: "
          puts response.inspect
          @sock.send(packet(response), 0, @forward_ip, @forward_port)
        else
          conn = AcpConnection.new(@listen_ip, @listen_port, dg.source_ip, dg.source_port)
          @connections["#{dg.source_ip}#{dg.source_port}"] = conn
          response = conn.parse(dg)
          new_data = conn.data
          @outbox << new_data if new_data
          puts "listener sending, new connection: "
          puts response.inspect
          @sock.send(packet(response), 0, @forward_ip, @forward_port)
        end
      end
    end

    timer_thread = Thread.new do
      loop do
        sleep 3
        @connections.keys.each do |key|
          if dg = conn.poll
            puts "timer sending: "
            puts dg.inspect
            @sock.send(packet(dg), 0, @forward_ip, @forward_port)
          end
        end
      end
    end
  end

  def send(msg, dest_ip, dest_port)
    conn = @connections["#{dest_ip}#{dest_port}"]
    if conn
      if dg = conn.send(msg)
        puts "main thread sending, existing connection: "
        puts dg.inspect
        @sock.send(packet(dg), 0, @forward_ip, @forward_port)
      end
    else
      conn = AcpConnection.new(@listen_ip, @listen_port, dest_ip, dest_port)
      @connections["#{dest_ip}#{dest_port}"] = conn
      if dg = conn.send(msg)
        puts "main thread sending, new connection: "
        puts dg.inspect
        @sock.send(packet(dg), 0, @forward_ip, @forward_port)
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

