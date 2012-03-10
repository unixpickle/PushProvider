require 'Connection'

module APN

	class PushPayload

		attr :token
		attr :payload

		def initialize(token, payload)
			@token = token
			@payload = payload
		end

		def encode(identifier=0, expiry=0)
			encoded = String.new
			encoded << [1].pack('C')
			encoded << [identifier, expiry].pack('NN')
			encoded << [token.length].pack('n')
			encoded << token
			encoded << [payload.length].pack('n')
			encoded << payload
			encoded
		end

	end

	class FeedbackPacket

		attr_reader :time
		attr_reader :token

		def initialize(time, token)
			@time = time
			@token = token
		end

		# provide a APN::Connection
		def FeedbackPacket.readPacket(connection)
			return nil if connection.eof?
			timeBuff = connection.read(4)
			return nil if !timeBuff
			time = timeBuff.unpack('N')[0]
			lenBuff = connection.read(2)
			len = lenBuff.unpack('n')[0]
			token = connection.read(len)
			return FeedbackPacket.new(time, token)
		end

	end

end
