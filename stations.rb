require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"


class Station

	attr_reader :id, :time, :temp, :dewpoint, :humidity, :conditions, :name, :state, :latitude, :longitude
	@@station_count = 0

	def initialize(id, time, temp, dewpoint, humidity, conditions, name, state, latitude, longitude)
		@id = id
		@time = time
		@temp = temp
		@dewpoint = dewpoint
		@humidity = humidity
		@conditions = conditions
		@name = name
		@state = state
		@latitude = latitude
		@longitude = longitude
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
			hash['place']['state'],
			hash['loc']['lat'],
			hash['loc']['long']
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

	# def too_close?(station)
	# 	self.latitude
	# 	self.longitude
	# end

	def print_matches_in(stations)
		matching = stations.find_all do |ea|
		 	ea != self && !ea.too_close? && self.matches?(ea)
		end

		unless matching.empty?
	  	place_names = matching.map { |ea| ea.name + " " + ea.state }
	  	str = place_names.join(", ") 
			puts "#{self} matches #{str}."
			puts
		end

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
# file request for specific region:
# http://api.aerisapi.com/observations/search?query=state:nu&limit=100&client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx

# user enters location to match
# first return values for that location
# then return locations that match
# so you'd have to specify that the app needs to look in every data file. how to do that?

# write a method that reads data from each file, and tells you how many stations there are in each one (:id)
# push each file to an array, then iterate through it to read all the data?

# do i need to make a relative path for the directory name?
# puts Dir.foreach("weather_data") { |filename| }
# uri = ARGV[0]

stations = []

weather_files = Dir.glob('./weather_data/*.json') 
weather_files.each do |file|

	open(file) do |f|
		json_file = f.read
		parsed_file = JSON.parse(json_file)
		response = parsed_file['response']

		stations += response.map { |ea| Station.from_hash(ea) }

	end
end

puts stations.flatten.size

valid_stations = stations.reject { |ea| ea.not_valid? }

valid_stations.each {|ea| ea.print_matches_in(valid_stations)}





