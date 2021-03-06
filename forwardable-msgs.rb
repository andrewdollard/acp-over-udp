require_relative 'lib/acp'

client_address = '0.0.0.0'
client_rcv_port = 1339
forward_ip = '0.0.0.0'
forward_port = 1338
puts "This socket identified by: #{client_address}:#{client_rcv_port}"

server_ip = '0.0.0.0'
server_port = 1337

client = AcpClient.new(client_address, client_rcv_port, forward_ip, forward_port)

loop do
  string = (0...8).map { (65 + rand(26)).chr }.join
  puts "sending: #{string}"
  client.send(string, server_ip, server_port)
  sleep 10
end

