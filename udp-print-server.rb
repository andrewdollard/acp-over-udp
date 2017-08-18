require_relative 'acp'

server_address = '0.0.0.0'
server_port = 1337
forward_ip = '0.0.0.0'
forward_port = 1337
puts "This socket identified by: #{server_address}:#{server_port}"

client = AcpClient.new(server_address, server_port, forward_ip, forward_port)

loop do
  msg = client.rcv(1024)
  puts "Received payload: #{msg}"
end
