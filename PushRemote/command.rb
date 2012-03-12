class Command

	attr_reader :arguments

	def initialize(string)
		@arguments = Array.new
		current = ""
		quoted = false
		string.each_char do |char|
			quoted = !quoted if char == '"'
			if (char == ' ' || char == "\t") && !quoted
				@arguments << current
				current = ""
			elsif char != '"'
				current = current + char
			end
		end
		@arguments << current if current.length > 0
	end

	def command
		return "" if arguments.count == 0
		return arguments[0]
	end

end
