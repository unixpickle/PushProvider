require 'Admin'
require 'Device'

class ClientListener

	def initialize(provider, port)
		@provider = provider
		@port = port
	end

	def listen_clients()
		APN::Logger.log("Listening on port #{@port}...")
		dts = TCPServer.new(@port)
		loop do		
			Thread.start(dts.accept) do |s|		
				handle_client(s)
			end		
		end		
	end

	def handle_client(socket)
		APN::Logger.log("Handling socket...")

		begin
			authDict = KeyedBits.kbRead(socket)
		rescue
			APN::Logger.log("Invalid auth dict: disconnecting")
			socket.close()
			return
		end

		APN::Logger.log("Received authentication")

		cliClass = case authDict['type']
			when 'device' then Device
			when 'admin' then Admin
			else nil
		end

		if !cliClass
			socket.close()
			return
		end

		client = cliClass.new(@provider, socket)
		client.handle()
		client.disconnect()
	end

end


def handle_client(provider, socket)
	client.disconnect
end
