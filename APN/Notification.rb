require 'json'

module APN

	class Notification

		attr_reader :message
		attr_reader :badge
		attr_reader :sound
		attr_reader :devID

		def initialize(message, badge, sound, devID)
			@message, @badge, @sound = message, badge, sound
			@devID = devID
		end

		def to_json
			aps = Hash.new
			aps['alert'] = @message if @message
			aps['sound'] = @sound if @sound
			aps['badge'] = @badge if @badge
			{:aps => aps}.to_json
		end

	end

end
