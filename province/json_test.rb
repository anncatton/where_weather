require 'json'
require 'byebug'

#byebug

# you could set the file name to be whatever was entered by the user in the command line
weather_input = ARGV[0]

class Station
	def initialize(id, temp, dewpoint, humidity, conditions)
		@id = id
		@temp = temp
		@dewpoint = dewpoint
		@humidity = humidity
		@conditions = conditions
	end

	def print
		puts "#{@id}: #{@temp}"
	end

	def self.from_hash(hash)
		observations = hash['ob']
		self.new(hash['id'], observations['tempC'], observations['dewpoint'], observations['humidity'], observations['weatherShort'])
	end	

end

open(weather_input) do |f|

	json_file = f.read
	parsed_file = JSON.parse(json_file)
	response = parsed_file['response']

	# [{'id': 123, 'ob': {...} }]

	response.each { |ea| ea['ob']}
	response[0]

	response[0]['ob']

	stations = response.map { |ea| Station.from_hash(ea) }

	stations.each do |ea|
		ea.print
	end

	# current = parsed_file['response'][0]['ob']
	# tempC = current['tempC']
	# dewpointC = current['dewpointC']
	# humidity = current['humidity']
	# conditions = current['weatherShort']

	# puts tempC.to_s + " C"
	# puts dewpointC.to_s + " C"
	# puts humidity.to_s + " %"
	# puts conditions

	# station_hashes = parsed_file['response']

	# puts station_id.is_a? Hash => true
	# puts station_id.inspect

	#select {|key, value| block} → a_hash

	# measurements = {}

	# station_id.select { |key, val| 
	# 	if key == 'id'
	# 		measurements[key] = val
	# 	end
	# }
	# puts measurements
	# returns first station id only. how to return all of them?
	#puts station_id

	# ['response'][0]['ob']['key'] => value
	# for each station (inside the hash that is the first and only element of the array inside 'response'), i want the values
	# 	from 4 keys: tempC, humidity, dewpointC, weatherShort
	# 	- so you'd need the station id too otherwise the numbers won't belong to a location
	# 	- for each unique station id, grab 4 observation values

end

# so, you need to call something like .each but its a hash so what method does a similar thing. can you use .each?

# so now this grabs data from one station only. if the file contains more than one station it will just return the
# first humidity file. i got confused and thought it was returning nothing, but the ab file just happened to have 
# null as its first humidity value.
# so now we need a method that will return ALL the values, from each station
# let's use the pei file cuz it's the smallest

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