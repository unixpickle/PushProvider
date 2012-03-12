require 'socket'
require 'command'

$: << './RKBKit'
require 'KeyedBits'


def receive
	begin
		packet = KeyedBits.kbRead($socket)
		return packet
	rescue
		return nil
	end
end

def listDevices
	{'cmd' => 'list'}.kbWrite($socket)
	packet = receive
	devices = packet['devices']
	devices.each do |dev|
		chars = dev.unpack('C' * dev.length)
		binary = chars.collect { |o| o.to_s(16).rjust(2, '00') }
		puts binary.to_s
	end
end

def hextobin(hex)
	binStr, buff = '', ''
	hex.each_char do |char|
		buff = buff + char
		if buff.length == 2
			binStr << buff.hex
			buff = ''
		end
	end
	binStr
end

$socket = TCPSocket.open('localhost', '1337')
{'type' => 'admin'}.kbWrite($socket)

loop do
	printf '> '
	cstr = gets.chomp
	command = Command.new(cstr)
	if command.command == 'list'
		listDevices
	elsif command.command == 'send'
		devID = KeyedBits::BinaryString.new(hextobin(command.arguments[1]))
		msg = command.arguments[2]
		info = {'device' => devID, 'alert' => msg}
		payload = {'cmd' => 'note', 'info' => info}
		payload.kbWrite($socket)
	elsif command.command == 'quit'
		$socket.close
		break
	end
end
