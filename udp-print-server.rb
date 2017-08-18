require 'socket'
require_relative 'datagram'

sock = UDPSocket.new

server_address = '0.0.0.0'
server_port = 1337

sock.bind(server_address, server_port)

puts "Listening on: #{server_address}:#{server_port}"

datagram = Datagram.new

loop do
  msg, ip_addr = sock.recv(1024)
  puts "Received payload: #{datagram.deserialize(msg)}"
end
