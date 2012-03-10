require 'Packets'
require 'Queue'
require 'Log'

module APN

	class Sender

		def initialize(server)
			@idCount = 1
			@server = server
			@queue = Queue.new
			@thread = Thread.new do
				socket_thread
			end
		end

		def send(notification)
			@queue.push(notification)
		end

		private

		def socket_thread
			@connection = nil
			@opened = nil
			while true
				notification = @queue.pop
				if notification
					begin
						Logger.log('Sending notification...')
						send_note(notification)
						Logger.log('Sent notification')
					rescue
						@connection = nil
						@opened = nil
						@queue.push_front(notification)
						Logger.log("Failed to send: #{$!}")
						sleep(2)
					end
				end
				if @opened
					# 3 minute timeout
					if Time.new.to_i - @opened.to_i > 180
						Logger.log('Connection timeout exceeded, closing...')
						@connection.close
						@opened = nil
						@connection = nil
					end
				end
				sleep(0.1)
			end
		end

		def send_note(notification)
			if !@connection
				open_connection
			end
			json = notification.to_json
			Logger.log("JSON: #{json}")
			payload = PushPayload.new(notification.devID, json)
			binary = payload.encode(@idCount, 60*60*24*2) # 2 day expiry
			str = KeyedBits::BinaryString.new(binary).to_s
			Logger.log("payload: #{str}")
			@connection.write(binary)
			@idCount += 1
		end

		def open_connection
			@connection = Connection.new(@server, 2195)
			@opened = Time.now
		end

	end

end
