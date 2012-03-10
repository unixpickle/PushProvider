require 'sqlite3.rb'
require 'thread'
require 'time'

module APN

	class DevList

		def DevList.universalTime
			# UTC epoch timestamp
			return Time.new.to_i
		end

		def initialize(dbfile)
			@listLock = Mutex.new
			@db = SQLite3::Database.new(dbfile)
			@db.execute('CREATE TABLE IF NOT EXISTS devices (devID BLOB, reg BIGINT, unreg BIGINT);')
		end

		def devices()
			@listLock.lock
			devIDs = Array.new
			results = @db.execute('SELECT devID, reg, unreg FROM devices;')
			@listLock.unlock
			results.each do |row|
				devIDs << row[0] if row[1] > row[2]
			end
			devIDs
		end

		def register(devID, time)
			@listLock.lock
			results = @db.execute('SELECT * FROM devices WHERE (devID=?);', devID)
			if results.count == 0
				Logger.log('Inserting new device...')
				query = 'INSERT INTO devices (devID, reg, unreg) VALUES (?,?,?);'
				@db.execute(query, devID, time, 0)
			else
				query = 'UPDATE devices SET (reg=?) WHERE (devID=?);'
				@db.execute(query, DevList.universalTime(), devID)
			end
			@listLock.unlock
		end

		def unregister(devID, time)
			@listLock.lock
			results = @db.execute('SELECT * FROM devices WHERE (devID=?);', devID)
			if results.count < 1
				query = 'INSERT INTO devices (devID, reg, unreg) VALUES (?, ?, ?);'
				@db.execute(query, devID, 0, time)
			else
				query = 'UPDATE devices SET (unreg=?) WHERE (devID=?);'
				@db.execute(query, time, devID)
			end
			@listLock.unlock
		end

		def times(devID)
			@listLock.lock
			query = 'SELECT reg, unreg FROM devices WHERE (devID=?);'
			results = @db.execute(query, devID)
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
