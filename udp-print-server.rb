require_relative 'acp'

server_address = '0.0.0.0'
server_port = 1337
forward_ip = '0.0.0.0'
forward_port = 1338
puts "This socket identified by: #{server_address}:#{server_port}"

conn = AcpConnection.new(server_address, server_port, forward_ip, forward_port)

loop do
  msg = conn.rcv(1024)
  puts "Received payload: #{msg}"
end
