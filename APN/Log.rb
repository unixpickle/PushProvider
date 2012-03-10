require 'thread'

module APN

	class Logger

		def initialize()
			@lock = Mutex.new
			@msgs = Array.new
			@lthread = Thread.new do
				logger()
			end
		end

		def log(msg)
			@lock.synchronize do
				@msgs << [Time.new, msg]
			end
		end

		private

		def logger
			while true
				@lock.synchronize do
					if @msgs.count > 0
						first = @msgs[0]
						@msgs.delete_at(0)
						timestr = first[0].strftime("%Y-%m-%d %H:%M:%S")
						puts "[#{timestr}] #{first[1]}"
					end
				end
				sleep(0.1)
			end
		end

	end

	def Logger.setup
		$APNLogger = Logger.new
	end

	def Logger.log(msg)
		Logger.setup if !$APNLogger
		$APNLogger.log(msg)
	end

end
