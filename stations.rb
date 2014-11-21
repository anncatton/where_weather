require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"
require "haversine"
require "fileutils"

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
		distance.to_km < 4000
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

# all countries except canada and us. 182 with data available on aeris, + us and canada
countries = ["ae", "af", "ag", "al", "am", "ao", "aq", "ar", "at", "au", "aw", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bj", "bm", "bo", "br", "bs", "bt", "bw", "by", "bz", "cf", "cg", "ch", "ci", "cl", "cm", "cn", "co", "cr", "cu", "cv", "cy", "cz", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "es", "et", "fi", "fj", "fk", "fm",  "fr", "ga", "gb", "gd", "ge", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gt", "gw", "gy", "hk", "hn", "hr", "hu", "id", "ie", "il", "in", "iq", "ir", "is", "it", "jm", "jo", "jp", "ke", "kg", "kh", "km", "kn", "kr", "kw", "ky", "kz", "la", "lb", "lc", "lk", "lr", "lt", "lu", "lv", "ly", "ma", "md", "mk", "ml", "mm", "mo", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "ne" , "ng", "ni", "nl", "no", "np", "nz", "om", "pa", "pe", "pg", "ph", "pk", "pl", "pt", "py", "qa", "ro", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sk", "sl", "sn", "sr", "st", "sv", "sy", "sz",  "td", "tg", "th", "tj", "tm", "tn", "tr", "tt", "tw", "tz", "ua", "ug", "uy", "uz", "vc", "ve", "vi", "vn", "vu", "ws", "ye", "za", "zm", "zw"]

# 66 countries without data on aeris api
countries_without_data = ["ad", "ai", "as", "ax", "bi", "bl", "bn", "bq", "bv", "cc", "cd", "ck", "cw", "cx", "eh", "er","fo", "gf", "gg", "gs", "gu", "hm", "ht", "im", "io", "je", "ki", "kp", "li", "ls", "mc", "me", "mf", "mg", "mh", "mn", "mp", "nc", "nf", "nr", "nu", "pf", "pm", "pn", "pr", "ps", "pw", "re", "rs", "sj", "sm", "so", "ss", "sx","tc", "tf", "tk", "tl", "to", "tv", "um", "va", "vg", "wf", "xk", "yt"]

ca_provinces = ["bc", "ab", "sk", "mb", "on", "qc", "nb", "ns", "nl", "pe", "yt", "nu", "nt"]

stations = []

def uri_for(country)

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
end
# btw that you're studying internet access is awesome and very interesting
countries.each do |ea|
# this says for each country, check to see if this directory exists, and if it doesn't, create it. and then
# put this file in it.
	FileUtils.mkdir_p "./weather_data/world/"
	uri = uri_for(ea)
	target_filename = "./weather_data/world/" + ea + "_data.json"

	open(uri) do |io|
		json_string = io.read
		File.open(target_filename, 'w') { |file| file.write(json_string) }
	end
end

# run this once the data has been written to the files in weather_data

weather_files = Dir.glob('./weather_data/world/*.json') 
weather_files.each do |file|

	open(file) do |f|
		json_file = f.read
		parsed_file = JSON.parse(json_file)
		response = parsed_file['response']

		stations += response.map { |ea| Station.from_hash(ea) }

	end
end

puts stations.flatten.size

# valid_stations = stations.reject { |ea| ea.not_valid? }

# valid_stations.each {|ea| ea.print_matches_in(valid_stations)}


# for individual states
# us_states = ["al", "ak", "az", "ar", "ca", "co", "ct", "de", "dc", "fl", "ga"]

# , "hi", "id", "il", "in", "ia", "ks", "ky", "la", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt", "ne", "nv", "nh", "nj", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", "ri", "sc", "sd", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi", "wy"
# us_stations = []

# def uri_for(state)

# 	query = "state:" + state

# 	my_uri = URI::HTTP.build(
# 		{
# 			:host => "api.aerisapi.com", 
# 			:path => "/observations/search", 
# 			:query => {
# 				:client_id => "yotRMCnX8QTlcpwPx71pg", 
# 				:client_secret => "H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx",
# 				:limit => 250,
# 				:query => query
# 			}.to_query
# 		}
# 	)
# end

# us_states.each do |ea|

# 	FileUtils.mkdir_p "./weather_data/us/"
# 	uri = uri_for(ea)
# 	target_filename = "./weather_data/us/" + ea + "_data.json"

# 	open(uri) do |io|
# 		json_string = io.read
# 		File.open(target_filename, 'w') { |file| file.write(json_string) }
# 	end

# end

# weather_files = Dir.glob('./weather_data/us/*.json') 
# weather_files.each do |file|

# 	open(file) do |f|
# 		json_file = f.read
# 		parsed_file = JSON.parse(json_file)
# 		response = parsed_file['response']

# 		us_stations += response.map { |ea| Station.from_hash(ea) }

# 	end
# end

# puts us_stations.flatten.size

# valid_us_stations = us_stations.reject { |ea| ea.not_valid? }

# valid_us_stations.each {|ea| ea.print_matches_in(valid_us_stations)}


# countries with this error returns:
# {"success":true,"error":{"code":"warn_no_data","description":"No data was returned for the request."},"response":[]}
# which i guess is saying that contact with the api was successful but it had no data to transmit, which must mean there are no [official] weather stations in that region


# for those countries that don't show up on aeris, you could have a method that accesses data from wunderground, cuz
# they seem to have a lot more locations, using the pws's. just because these places are ones that a user has likely never heard of or doesn't know much about! those are the ones you want to make sure you're including. don't worry about this too much right now

# didn't update some files that should have updated - they updated when i tried them individually
# but just did it again and all files updated. check again tomorrow. i think you fucked something up, maybe ran
# stations.rb with the wrong array cuz i looked at the hits on aeris and this last time, that everything updated, there
# were WAY more hits
# too many stations in canada and us. but i don't want to get rid of them, i just don't want to return all of them as matches,
# or you'll have like 20 returns from a 100 mile radius, for example. need to just pick of them, and make sure you don't get the same returns all the time
# too many stations within a small area
# list of stations that are sensible sounding
# need to combine cdn and us locations with worldwide
# create uri_for method for states and ca_provinces
# too many matches within states. so many available stations
# show total number of matches so you have an idea how many you're getting (and how many is unwieldy)
# show state/province for location being matched. also show its current conditions. when you get the matches down to a
# manageable number, show the conditions for returned matched locations as well so you can see how the range is working.
# if there are several matches within a certain radius (like, 500 km), return only 1 of them (most exact match), then chosen randomly after that, and also return matches that haven't been shown recently to increase variety