require 'Sender'
require 'Feedback'

module APN

	class Provider

		SandboxGateway = 'gateway.sandbox.push.apple.com'
		SandboxFeedback = 'feedback.sandbox.push.apple.com'

		attr_reader :sender
		attr_reader :feedback
		attr_reader :devList

		def initialize(apns = SandboxGateway, fb = SandboxFeedback)
			Logger.log('Setting up provider...')
			@devList = DevList.new($APN_RESOURCES + '/devices.db')
			@sender = Sender.new(apns)
			@feedback = Feedback.new(fb, @devList)
		end

		def shutdown
			@devList.close
			exit(0)
		end

	end

end
