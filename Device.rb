require 'Client'

class Device < Client

	def handle
		APN::Logger.log("Handling device...")
		authDict = nil
		begin
			authDict = KeyedBits.kbRead(@socket)
		rescue
			APN::Logger.log('Failed to read device dict')
			return
		end
		APN::Logger.log('Got device authDict')
		if authDict['device']
			aDevID = authDict['device']
			time = APN::DevList.universalTime()
			APN::Logger.log("Registering: #{aDevID.to_s}")
			@provider.devList.register(aDevID, time)
		else
			APN::Logger.log('Invalid authDict provided')
		end
	end

end

