require 'Notification'

module APN

	class Queue

		def initialize()
			@lock = Mutex.new
			@queue = Array.new
		end

		def push(notification)
			@lock.synchronize do
				@queue << notification
			end
		end

		def push_front(notification)
			@lock.synchronize do
				@queue.insert(0, notification)
			end
		end

		def pop
			obj = nil
			@lock.synchronize do
				if @queue.count != 0
					obj = @queue[0]
					@queue.delete_at(0)
				end
			end
			obj
		end

	end

end
