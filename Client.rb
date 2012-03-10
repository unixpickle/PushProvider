require 'KeyedBits'
require 'Provider'

class Client

	def initialize(provider, socket)
		@provider, @socket = provider, socket
	end

	def handle
		# sub-classes should implement client-type
		# specific behavior here
	end

	def disconnect
		# sub-classes might want to send some kind of
		# information regarding the close before
		# shutting down
		@socket.close()
	end

end
