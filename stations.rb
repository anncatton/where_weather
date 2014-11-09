require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"

# so now i need a way to input files not from the command line? or just find a way to input more than one file from the command line
# the question is, do you want your app to gather a bunch of data from different locations, then compare to the origin station, or take
# the data from the origin, and search out locations that match the given criteria? i think either way you're going to end up having to
# access a lot of data
class Station

	attr_reader :id, :time, :temp, :dewpoint, :humidity, :conditions, :name, :state

	# keep in mind that you'll probably need to change these parameters for a couple reasons - it's simpler to skip dewpoint and humidity
	# and just use 'feelslike' + weatherShort, and also maybe measurements like dewpoint aren't available at enough locations. you could run some tests
	# that check to see how many stations come back as not valid (and why) and decide based on that what the best measurement strategy is
	# you don't want to be rejecting a ton of interesting places just because you're missing a piece of data that could be replaced by 
	# another one that could serve the same purpose. although i would imagine if things like humidity and dewpoint aren't measured, feelslike temp
	# is probably also null. * i just found a case where this isn't true - no dewpoint or humidity, but a feelslike measure. what are they using to measure
	# feelslike temp?
	# at some point you're going to have to find out what the most accurate system is - the actual separate measurements, or relying on things like
	# feelslike etc. also thinking that different sites will have different systems for feelslike. that's why i like the separate measurements better.
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

# because you're planning on making this more convoluted, it's probably wise to change this to STDIN.gets instead of ARGV (since
# you wan to get into query type, query parameters, locations, etc from user).
# maybe you shouldn't worry about this at all and start making it input a user will put into a website!
# http://api.aerisapi.com/observations/search?query=country:ca&limit=200&client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx
user_request = ARGV
query_type = ARGV[0]
locations = ARGV[1..-1]

request = locations.map do |ea|
	"/" + query_type + "/" + ea
end

def make_uri(path)

	my_uri = URI::HTTP.build(
	{
		:host => "api.aerisapi.com", 
		:path => path,
		:query => {
			:client_id => "yotRMCnX8QTlcpwPx71pg", 
			:client_secret => "H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx"
		}.to_query
	}
)

end

requests = request.map do |ea|
	make_uri(ea)
end

def make_request(uri)

	open(uri) do |f|
		json_file = f.read
		parsed_json = JSON.parse(json_file)
		puts parsed_json
	end

end

requests.each do |ea|
	make_request(ea)
end

# user input for file names (for now), then write those files to a new file that will be opened by the open(weather_input) method
# i just realized i was trying to combine too many things - you're not going to be putting file names into your uri.build, cuz that
# doesn't make any sense! you want to just put in locations from the command line, then create a request to be sent to the api

# uri = URI::HTTP.build(
# 	{
# 		:host => "api.aerisapi.com", 
# 		:path => "/observations/toronto,on,ca", 
# 		:query => {
# 			:client_id => "yotRMCnX8QTlcpwPx71pg", 
# 			:client_secret => "H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx"
# 		}.to_query
# 	}
# )

# open(uri) do |f|

# 	json_file = f.read
# 	parsed_file = JSON.parse(json_file)
# 	response = parsed_file['response']

# 	# map returns an array
# 	# so to access more than one file, do i need to redefine stations
# 	# ok, you get your data from the api. then, you check each station to see if it's provided valid data. then, the valid data is sent to 
# 	# the app to use for comparison. i think that's better than checking each station for validity with each comparison request
# 	stations = response.map { |ea| Station.from_hash(ea) }
# 	#valid_stations = stations.select { |ea| ea.valid? }

# 	valid_stations = stations.reject { |ea| ea.not_valid? }

# 	a_station = valid_stations.first
# 	matching = valid_stations[1..-1].find_all do |ea|
# 		a_station.matches?(ea)
# 	end

#   place_names = matching.map { |ea| ea.name + " " + ea.state }
#   str = place_names.join(", ") 
# 	puts "#{a_station} matches #{str}."

# # what does it say if there are no matches? could give options for 'rather similar' but not the same?

# end

# now want to get data from a wider source. put everything in one file or still separate files in one folder?
# Issues:

# display of station names - you don't want the station name displayed cuz no one's really going to know what those are. you could use
# them behind the scenes to point to place names that ARE displayed to the user, database style. or you could write a method that converts
# the weird-sounding place names (like 'leader arpt (aut') to something more recognizable (like "Leader, SK"). although i have no idea how
# i would do that

warning: You ran 'git add' with neither '-A (--all)' or '--ignore-removal',
whose behaviour will change in Git 2.0 with respect to paths you removed.
Paths like 'province/ab_data.json' that are
removed from your working tree are ignored with this version of Git.

* 'git add --ignore-removal <pathspec>', which is the current default,
  ignores paths you removed from your working tree.

* 'git add --all <pathspec>' will let you also record the removals.

Run 'git status' to check the paths you removed from your working tree.
