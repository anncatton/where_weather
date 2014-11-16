require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"
require "haversine"

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

	def too_close?(station)
		distance = Haversine.distance(self.latitude, self.longitude, station.latitude, station.longitude)
		distance.to_km < 1000
	end

	def print_matches_in(stations)
		matching = stations.find_all do |ea|
		 	ea != self && !self.too_close?(ea) && self.matches?(ea)
		end
		unless matching.empty?
		  place_names = matching.map { |ea| ea.name + " " + ea.state }
		  str = place_names.join(", ") 
			puts "#{self} matches #{str}."
			puts
		end
	end

end

# user enters location to match
# first return values for that location
# then return locations that match
# so you'd have to specify that the app needs to look in every data file. how to do that?

# stations = []

# weather_files = Dir.glob('./weather_data/worldwide/*.json') 
# weather_files.each do |file|

# 	open(file) do |f|
# 		json_file = f.read
# 		parsed_file = JSON.parse(json_file)
# 		response = parsed_file['response']

# 		stations += response.map { |ea| Station.from_hash(ea) }

# 	end
# end

# puts stations.flatten.size

# valid_stations = stations.reject { |ea| ea.not_valid? }

# valid_stations.each {|ea| ea.print_matches_in(valid_stations)}

# making a request should be separate from matching within the files
# now i want every country in an array, then iterate through each one to make requests

def request(country)

	query = "country:" + country

	my_uri = URI::HTTP.build(
		{
			:host => "api.aerisapi.com", 
			:path => "/observations/search", 
			:query => {
				:client_id => "yotRMCnX8QTlcpwPx71pg", 
				:client_secret => "H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx",
				:limit => 250,
				:query => query
			}.to_query
		}
	)
	# puts my_uri
end

countries = ["fr", "it", "gi", "gb"]

uri = countries.map do |ea|
	request(ea)
end

uri.each do |ea|

	open(ea) do |f|

		json_string = f.read
		parsed_json = JSON.parse(json_string)
		puts parsed_json

	end
end