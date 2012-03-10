require 'Client'

class Admin < Client

	def handle
		APN::Logger.log('Handling admin...')
		loop do
			begin
				authDict = KeyedBits.kbRead(@socket)
				case authDict['cmd']
					when 'list' then send_list()
					when 'note' then send_notification(authDict)
				end
			rescue
				APN::Logger.log("Admin closed: #{$!}")
				return
			end
		end
	end

	def send_list
		APN::Logger.log('Sending device list...')
		devices = @provider.devList.devices
		kbDevs = devices.map { |obj| KeyedBits::BinaryString.new(obj) }
		obj = {'cmd' => 'list', 'devices' => kbDevs}
		obj.kbWrite(@socket)
	end

	def send_notification(notificationCont)
		notification = notificationCont['info']
		devID = notification['device']
		alert = notification['alert']
		badge = notification['badge']
		sound = notification['sound']
		APN::Logger.log("Sending note to dev: #{devID.to_s}")
		msg = APN::Notification.new(alert, badge, sound, devID)
		@provider.sender.send(msg)
	end

end
