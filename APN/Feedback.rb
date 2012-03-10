require 'Packets'
require 'Log'
require 'DevList'

module APN

	class Feedback

		def initialize(server, devList)
			@server = server
			@devList = devList
			@bgThread = Thread.new do
				feedback()
			end
		end

		private

		def feedback
			# periodically check the feedback server (once an hour)
			while true
				begin
					Logger.log('Fetching feedback from server...')
					c = check_feedback()
					Logger.log("Got #{c} feedback packets.")
				rescue
					Logger.log("Failed to fetch feedback: #{$!}")
				end
				sleep(60 * 60)
			end
		end

		def check_feedback
			connection = Connection.new(@server, 2196)
			count = 0
			loop do
				packet = FeedbackPacket.readPacket(connection)
				break if !packet
				count += 1
				@devList.unregister(packet.token, packet.time)
			end
			connection.close
			count
		end

	end

end
