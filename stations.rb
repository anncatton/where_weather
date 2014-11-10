require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"


class Station

	attr_reader :id, :time, :temp, :dewpoint, :humidity, :conditions, :name, :state

	def initialize(id, time, temp, dewpoint, humidity, conditions, name, state)
		@id = id
		@time = time
		@temp = temp
		@dewpoint = dewpoint
		@humidity = humidity
		@conditions = conditions
		@name = name
		@state = state
	end

	def to_s
		name
	end

	def print
		puts "Location: #{@id}"
		puts "Time observed: #{@time}"
		puts "Temperature: #{@temp} C"
		puts "Dewpoint: #{@dewpoint} C"
		puts "Relative humidity: #{@humidity} %"
		puts "Current conditions: #{@conditions}"
		puts
	end

	def self.from_hash(hash)
		observations = hash['ob']
		self.new(
			hash['id'], 
			observations['dateTimeISO'], 
			observations['tempC'], 
			observations['dewpointC'], 
			observations['humidity'], 
			observations['weatherShort'], 
			hash['place']['name'],
			hash['place']['state']
			)
	end	

# set up a validity check that rejects the bad ones, as opposed to selecting the good ones, so the bad ones are just tossed?
# have a method that gets all the data, then sorts it. then, start the comparisons. ??
# andy suggestec just starting out by gathering the data and storing it in files, then assessing it. i wonder if there's a way
# to just get the measurements i need, not all of them?
	def not_valid?
		temp.nil? || dewpoint.nil? || humidity.nil? || conditions.nil?
	end

	def valid?
		!temp.nil? && !dewpoint.nil? && !humidity.nil? && !conditions.nil?
		#!(temp.nil? || dewpoint.nil? || humidity.nil? || conditions.nil?) - this could be a less desirable approach because you have to 
		# read right to the end of the expression to find out what it's saying, as opposed to the one above which is in discrete sections
		# and is easier to read. this is important in logical statements cuz they can get confusing pretty fast
	end

	def matches_temp?(other_station)
		other_station.temp <= (self.temp + 1) && other_station.temp >= (self.temp - 1)
	end

	def matches_dewpoint?(other_station)
		other_station.dewpoint <= (self.dewpoint + 1) && other_station.dewpoint >= (self.dewpoint - 1)
	end

	def matches?(other_station)
		other_station.conditions == self.conditions && 
			matches_temp?(other_station) &&
			matches_dewpoint?(other_station)
	end

end

# 	uri = URI::HTTP.build(
# 	{
# 		:host => "api.aerisapi.com", 
# 		:path => "/observations/toronto,on,ca",
# 		# query is whatever comes after the question mark
# 		:query => {
# 			:client_id => "yotRMCnX8QTlcpwPx71pg", 
# 			:client_secret => "H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx"
# 		}.to_query
# 	}
# )


uri = ARGV[0]

	open(uri) do |f|
		json_file = f.read
		parsed_file = JSON.parse(json_file)
		response = parsed_file['response']

	stations = response.map { |ea| Station.from_hash(ea) }

	  # valid_stations = stations.select { |ea| ea.valid? }

		valid_stations = stations.reject { |ea| ea.not_valid? }
		# puts valid_stations
		a_station = valid_stations.first
		matching = valid_stations[1..-1].find_all do |ea|
			a_station.matches?(ea)
		end

  	place_names = matching.map { |ea| ea.name + " " + ea.state }
  	str = place_names.join(", ") 
		puts "#{a_station} matches #{str}."
	end

# now want to get data from a wider source. put everything in one file or still separate files in one folder?
# Issues:

# display of station names - you don't want the station name displayed cuz no one's really going to know what those are. you could use
# them behind the scenes to point to place names that ARE displayed to the user, database style. or you could write a method that converts
# the weird-sounding place names (like 'leader arpt (aut') to something more recognizable (like "Leader, SK"). although i have no idea how
# i would do that
# what does it say if there are no matches? could give options for 'rather similar' but not the same?


