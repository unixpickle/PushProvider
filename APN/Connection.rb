require 'openssl'
require 'socket'

module APN

	class Connection

		attr_reader :socket

		def initialize(host, port, pemFile = nil)
			pem = pemFile
			pem = $APN_RESOURCES + '/cert.pem' if !pem
			ctx = OpenSSL::SSL::SSLContext.new
			ctx.cert = OpenSSL::X509::Certificate.new(File::read(pem))
			ctx.key  = OpenSSL::PKey::RSA.new(File::read(pem))

			Logger.log("Connecting to #{host} : #{port}")
			@tcpSock = TCPSocket.new(host, port)
			@socket = OpenSSL::SSL::SSLSocket.new(@tcpSock, ctx)
			@socket.connect()
		end

		def eof?
			return @tcpSock.eof?
		end

		def write(str)
			@socket.syswrite(str)
		end

		def read(len)
			raise 'Unsupported arguments' if len <= 0
			begin
				return @socket.sysread(len)
			rescue EOFError
				return nil
			end
		end

		def state
			return @socket.state
		end

		def close
			@socket.sysclose
			@tcpSock.close
		end

	end

end
