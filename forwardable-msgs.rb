require 'socket'
require_relative 'datagram'

sock = UDPSocket.new

client_address = '0.0.0.0'
client_rcv_port = 1339
puts "This socket identified by: #{client_address}:#{client_rcv_port}"

server_ip = '0.0.0.0'
server_port = 1338
forward_ip = '0.0.0.0'
forward_port = 1337

datagram = Datagram.new

loop do
  print "Enter a string to be echoed: "
  message = gets.chomp
  complete_message = "('#{datagram.serialize(message)}', ('#{forward_ip}', #{forward_port}))"
  sock.send(complete_message, 0, server_ip, server_port)
end

