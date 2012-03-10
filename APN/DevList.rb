require 'sqlite3.rb'
require 'thread'
require 'time'

module APN

	class DevList

		def DevList.universalTime
			# UTC epoch timestamp
			return Time.new.to_i
		end

		def DevList.to_hex(str)
			str.unpack('C' * str.length).collect {|x| x.to_s(16).rjust(2, '00')}
		end

		def DevList.to_bin(hex)
			binStr = ""
			buff = ""
			hex.each_char do |char|
				buff = buff + char
				if buff.length == 2
					binStr << buff.hex
					buff = ""
				end
			end
			binStr
		end

		def initialize(dbfile)
			@listLock = Mutex.new
			@db = SQLite3::Database.new(dbfile)
			@db.execute('CREATE TABLE IF NOT EXISTS devices (devID TEXT, reg BIGINT, unreg BIGINT)')
		end

		def devices()
			@listLock.lock
			devIDs = Array.new
			results = @db.execute('SELECT devID, reg, unreg FROM devices')
			@listLock.unlock
			results.each do |row|
				binDevID = DevList.to_bin(row[0])
				devIDs << binDevID if row[1] > row[2]
			end
			devIDs
		end

		def register(devID, time)
			hexID = DevList.to_hex(devID)
			@listLock.lock
			exists = false
			res = @db.execute("SELECT * FROM devices WHERE devID='#{hexID}'")
			exists = res.count > 0
			if !exists
				Logger.log('Inserting new device...')
				query = "INSERT INTO devices (devID, reg, unreg) VALUES ('#{hexID}', #{DevList.universalTime()}, 0)"
				@db.execute(query)
			else
				Logger.log('Updating existsing device...')
				query = "UPDATE devices SET reg=#{DevList.universalTime()} WHERE devID='#{hexID}'"
				@db.execute(query)
			end
			@listLock.unlock
		end

		def unregister(devID, time)
			hexID = DevList.to_hex(devID)
			@listLock.lock
			results = @db.execute("SELECT * FROM devices WHERE (devID='#{hexID}')")
			if results.count < 1
				query = "INSERT INTO devices (devID, reg, unreg) VALUES ('#{hexID}', 0, #{time})"
				@db.execute(query)
			else
				query = "UPDATE devices SET unreg=#{time} WHERE devID='#{hexID}'"
				@db.execute(query)
			end
			@listLock.unlock
		end

		def times(devID)
			hexID = DevList.to_hex(devID)
			@listLock.lock
			query = "SELECT reg, unreg FROM devices WHERE (devID='#{hexID}')"
			results = @db.execute(query)
			@listLock.unlock
			return nil if results.count < 1
			return results[0]
		end

		def registered?(devID)
			info = self.times(devID)
			return false if !info
			info[1] < info[0]
		end

		def close
			@listLock.lock
			@db.close
			@listLock.unlock
		end

	end

end
