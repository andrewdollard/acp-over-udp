import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

client_address = '0.0.0.0'
client_rcv_port = int(input("Type the port number you desire for this socket: "))

print("This socket identified by: " + client_address + ":" + str(client_rcv_port))

server_ip = input('Enter the ip address you wish to send to: ')
server_port = int(input('Type the port number you wish to send to: '))
forward_ip = input('Enter the ip address to forward this message to: ')
forward_port = int(input('Enter the port to be forwarded to: '))

while True:
    message = input('Enter a string to be echoed: ')
    complete_message = (message, (forward_ip, forward_port))
    sock.sendto(bytes(str(complete_message), "utf-8"), (server_ip, server_port))
    print("sent: " + str(complete_message))
