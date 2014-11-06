require 'json'
require 'byebug'

weather_input = ARGV[0]

class Station

	attr_reader :id, :time, :temp, :dewpoint, :humidity, :conditions, :name

	def initialize(id, time, temp, dewpoint, humidity, conditions, name)
		@id = id
		@time = time
		@temp = temp
		@dewpoint = dewpoint
		@humidity = humidity
		@conditions = conditions
		@name = name
	end

	def to_s
		id
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
			hash['place']['name']
			)
	end	

	def valid?
		!temp.nil? && !dewpoint.nil? && !humidity.nil? && !conditions.nil?
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

open(weather_input) do |f|

	json_file = f.read
	parsed_file = JSON.parse(json_file)
	response = parsed_file['response']

	# map returns an array
	stations = response.map { |ea| Station.from_hash(ea) }
	valid_stations = stations.select { |ea| ea.valid? }
	# why do i need this to print out the values?
	# stations.each do |ea|
	# 	ea.print
	# end

# @time needs to be an exact match
# @conditions should be exact match
# @temp within 2? degrees either side? maybe just 1. then its only a 3 degree range
# @dewpoint also within 1 i think. cuz theres a big difference from, say, 15 C to 19 C (if your comparison is with 17 C)
# @humidity i think can have a bigger range. i may even get rid of it altogether cuz dewpoint is more important to feel. lets say 5%


	a_station = valid_stations.first
	matching = valid_stations[1..-1].find_all do |ea|
		a_station.matches?(ea)
	end

  place_names = matching.map { |ea| ea.name }
  str = place_names.join(", ")
	puts "#{a_station} matches #{str}."

# what does it say if there are no matches? could give options for 'rather similar' but not the same?

	# station_hashes = parsed_file['response']

	# ['response'][0]['ob']['key'] => value
	# for each station (inside the hash that is the first and only element of the array inside 'response'), i want the values
	# 	from 4 keys: tempC, humidity, dewpointC, weatherShort
	# 	- so you'd need the station id too otherwise the numbers won't belong to a location
	# 	- for each unique station id, grab 4 observation values

end

# puts @current.inspect
# So solution is to use [0], or #first method, in the assignment:

# @current = @parse['data']['current_condition'].first
# this TypeError in ruby usually is caused by accessing an array via string instead of integer value.
# this is what parsed_file.inspect returns:

# {"response"=>[
# 		{"id"=>"CWIP",
# 		"loc"=>{"long"=>-66.433333333333, "lat"=>50.166666666667}, 
# 		"place"=>{"name"=>"pointe noires cs", "state"=>"qc", "country"=>"ca"}, 
# 		"obDateTime"=>"2014-11-01T16:00:00-04:00", 
# 		"ob"=>{"tempC"=>3, 
# 			"dewpointC"=>nil, 
# 			"humidity"=>nil, 
# 			"weatherShort"=>"Mostly Sunny"}
# 		}
# 	]
# }

# which means response is pointing to an array of hashes ??

# now, i don't know if this is screwing around with things i shouldn't, but if you take out the array that response points to, you can skip
# the [0] step when accessing values inside the keys in response. so instead of:

# open(qc_file) do |f|

# 	json_file = f.read
# 	parsed_file = JSON.parse(json_file)

# 	current = parsed_file['response']
# 	tempC = current[0]['ob']['tempC']

# 	puts tempC

# end

# you can put:

# open(qc_file) do |f|

# 	json_file = f.read
# 	parsed_file = JSON.parse(json_file)

# 	current = parsed_file['response']
# 	tempC = current['ob']['tempC']

# 	puts tempC

# end

# i'm just not sure if the array needs to be left there - i.e. when i'm accessing data from the api, it's going to return it in the array form
# so i should just leave the [0] code in there. because to get rid of it you have to mess around with the json files...