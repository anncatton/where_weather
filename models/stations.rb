require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"
require "haversine"
require "fileutils"
require "csv"
# require "./models/station_name_map.rb"

class Station

	attr_reader :id, :time, :temp, :dewpoint, :humidity, :conditions, :name, :state, :latitude, :longitude, :country, :pretty_name

	def initialize(id, time, temp, dewpoint, humidity, conditions, name, state, latitude, longitude, country, pretty_name)
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
		@country = country
		@pretty_name = pretty_name
	end

	def to_s
		name
	end

	def print
		if @pretty_name['region'].nil? || @pretty_name['region'] == "-"
			puts "Location: #{@pretty_name['city']}, #{pretty_name['country']}"
			puts "Time observed: #{@time}"
			puts "Temperature: #{@temp} C"
			puts "Dewpoint: #{@dewpoint} C"
			puts "Relative humidity: #{@humidity} %"
			puts "Current conditions: #{@conditions}"
			puts
		else
			puts "Location: #{@pretty_name['city']}, #{@pretty_name['region']}, #{pretty_name['country']}"
			puts "Time observed: #{@time}"
			puts "Temperature: #{@temp} C"
			puts "Dewpoint: #{@dewpoint} C"
			puts "Relative humidity: #{@humidity} %"
			puts "Current conditions: #{@conditions}"
			puts
		end
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
			hash['loc']['long'],
			hash['place']['country'],
			hash['place']['pretty_name']
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

	def matches_time?(other_station)
		other_station.time <= (self.time + 1) && other_station.time >= (self.time - 1)
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

		result = []
		matching.each do |ea|
			unless result.any? { |station| station.too_close?(ea) }
				result << ea
			end
		end

		unless result.empty?
		  place_names = result.map do |ea|
			  if !(ea.pretty_name.nil?) && !(ea.pretty_name['city'].nil?) && !(ea.pretty_name['country'].nil?)
			  	ea.pretty_name['city'] + ", " + ea.pretty_name['country']			  
			  else
			  	ea.name + " pretty name missing"
			  end
			end
			str = place_names.join("; ")
			puts "#{self} matches #{str}."
			puts
		end
	end

end

def build_station_name_map

	station_names = CSV.read('../stations.csv', :encoding => 'windows-1251:utf-8', :headers => true)
	station_id_array = []

	station_names.map do |ea|
		ea.to_hash
		names_hash = {}

		if !(ea['icao_xref'].nil?)
			names_hash[:city] = ea['city']
			names_hash[:region] = ea['region']
			names_hash[:country] = ea['country']
			names_hash[:station] = ea['icao_xref']
			station_id_array << names_hash
			#station_id_hash[ea['city']] = names_hash
		elsif !(ea['icao'].nil?)
			names_hash[:city] = ea['city']
			names_hash[:region] = ea['region']
			names_hash[:country] = ea['country']
			names_hash[:station] = ea['icao']
			station_id_array << names_hash
			#station_id_hash[ea['city']] = names_hash
		end
	end
	# byebug
	station_id_array.uniq { |ea| ea[:station]}

end

# def build_station_name_map
# 	station_names = CSV.read('./stations.csv', :encoding => 'windows-1251:utf-8', :headers => true)
# 	station_id_hash = {}

# 	station_names.map do |ea|
# 		ea.to_hash
# 		names_hash = {}

# 		if !(ea['icao_xref'].nil?)
# 			names_hash['city'] = ea['city']
# 			names_hash['region'] = ea['region']
# 			names_hash['country'] = ea['country']
# 			station_id_hash[ea['icao_xref']] = names_hash
# 		elsif !(ea['icao'].nil?)
# 			names_hash['city'] = ea['city']
# 			names_hash['region'] = ea['region']
# 			names_hash['country'] = ea['country']
# 			station_id_hash[ea['icao']] = names_hash
# 		end
# 	end
# 	station_id_hash

# end

# STATION_NAME_MAP = build_station_name_map
# to print STATION_NAME_MAP to a separate file:
# File.open('station_name_map.rb', 'w') { |file| file.write(STATION_NAME_MAP) }

# def read_and_write_uri(uri, filename)
# 		open(uri) do |io|
# 			json_string = io.read
# 			data_hash = JSON.parse(json_string)

# 			json_output = data_hash.to_json
# 			File.open(filename, 'w') { |file| file.write(json_output) }
# 		end
# end

def build_query(query)
	URI::HTTP.build(
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

def uri_for_country(country)

	query = "country:" + country
	build_query(query)

end

def uri_for_state(state)

	query = "state:" + state
	build_query(query)

end

# def uri_for_station(id)

# 	query = "id:" + id
# 	build_query(query)

# end

def get_country_data(regions)

	FileUtils.mkdir_p "../weather_data/"

	processed_data = {}
	regions.each do |ea|
		processed_data.merge!(processed_data_for_country(ea))
	end

	write_to_json_file(processed_data.to_json)
end

def get_all_data(regions)

	File.open("../weather_data/all_stations.json", "w") do |f|
		f.truncate(f.size)
	end

	get_country_data(regions)

end

stations = []

def get_data_for_country(country_name)
	uri = uri_for_country(country_name)
	open(uri) do |io|
		json_string = io.read
		data_hash = JSON.parse(json_string)
		data_hash["response"]
	end
end

def extract_station_data(raw_data)
	all_stations = {}

	raw_data.map do |ea| # i think the reason it does this separately is that it's using response.each, which is 3 separate
		# arrays, so i end up with 3 distinct hashes. you're actually saying, "for each response, do this" - so the responses remain
		# separate - because map returns an array
		new_station = Station.from_hash(ea)

		station = {} # a hash for each individual station
		station[:name] = new_station.name
		station[:region] = new_station.state
		station[:country] = new_station.country
		station[:temp] = new_station.temp
		station[:dewpoint] = new_station.dewpoint
		station[:humidity] = new_station.humidity
		station[:conditions] = new_station.conditions

		all_stations[new_station.id] = station
	end

	all_stations

end

def write_to_json_file(data)
	File.open("../weather_data/all_stations.json", "a") { |file| file.write(data) }
end


def processed_data_for_country(country_name)

	raw_data = get_data_for_country(country_name)

	extract_station_data(raw_data)

end



# countries = ["ae", "af", "ag", "al", "am", "ao", "aq", "ar", "at", "au", "aw", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bj", "bm", "bo", "br", "bs", "bt", "bw", "by", "bz", "cf", "cg", "ch", "ci", "cl", "cm", "cn", "co", "cr", "cu", "cv", "cy", "cz", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "es", "et", "fi", "fj", "fk", "fm",  "fr", "ga", "gb", "gd", "ge", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gt", "gw", "gy", "hk", "hn", "hr", "hu", "id", "ie", "il", "in", "iq", "ir", "is", "it", "jm", "jo", "jp", "ke", "kg", "kh", "km", "kn", "kr", "kw", "ky", "kz", "la", "lb", "lc", "lk", "lr", "lt", "lu", "lv", "ly", "ma", "md", "mk", "ml", "mm", "mo", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "ne" , "ng", "ni", "nl", "no", "np", "nz", "om", "pa", "pe", "pg", "ph", "pk", "pl", "pt", "py", "qa", "ro", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sk", "sl", "sn", "sr", "st", "sv", "sy", "sz",  "td", "tg", "th", "tj", "tm", "tn", "tr", "tt", "tw", "tz", "ua", "ug", "uy", "uz", "vc", "ve", "vi", "vn", "vu", "ws", "ye", "za", "zm", "zw"]
# countries = ["af", "cf", "ug"]
countries = ["za", "ag", "uz"]

countries_without_data = ["ad", "ai", "as", "ax", "bi", "bl", "bn", "bq", "bv", "cc", "cd", "ck", "cw", "cx", "eh", "er","fo", "gf", "gg", "gs", "gu", "hm", "ht", "im", "io", "je", "ki", "kp", "li", "ls", "mc", "me", "mf", "mg", "mh", "mn", "mp", "nc", "nf", "nr", "nu", "pf", "pm", "pn", "pr", "ps", "pw", "re", "rs", "sj", "sm", "so", "ss", "sx","tc", "tf", "tk", "tl", "to", "tv", "um", "va", "vg", "wf", "xk", "yt"]

# us_and_canada = ["ab", "al", "ak", "az", "ar", "bc", "ca", "co", "ct", "de", "dc", "fl", "ga", "hi", "id", "il", "in", "ia", "ks", "ky", "la", "mb", me", "md", "ma", "mi", "mn", "ms", "mo", "mt", "nb", "ne", "nv", "nh", "nj", "nl", "nm", "ns", "nt", "nu", "ny", "nc", "nd", "oh", "ok", "on", "or", "pa", "pe", "qc", "ri", "sc", "sd", "sk", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi", "wy", "yt"]

get_all_data(countries)
# countries.each do |ea|

# 	FileUtils.mkdir_p "../weather_data/world/"
# 	uri = uri_for_country(ea)
# 	target_filename = "../weather_data/world/" + ea + "_data.json"

# # right this is just writing straight json, what's coming from the api, to each country file, no parsing
# # here uri is the data on the page generated by the api request. so, its the content on the page that would show
# # up if you plugged the uri ("http://aeris.api/blablabla") into the browser

# 	read_and_write_uri(uri, target_filename)
# end

# us_and_canada.each do |ea|

# 	FileUtils.mkdir_p "./weather_data/world/"
# 	uri = uri_for_state(ea)
# 	target_filename = "./weather_data/world/" + ea + "_st_data.json"

# 	read_and_write_uri(uri, target_filename)
# end

# weather_files = Dir.glob('./weather_data/world/*.json')
# # puts weather_files.size
# weather_files.each do |file|

# 	open(file) do |f|

# 		json_file = f.read
# 		parsed_file = JSON.parse(json_file)
# 		# response is an array of hashes from the parsed json file
# 		response = parsed_file['response']
	
# 		stations += response.map { |ea| Station.from_hash(ea) }

# 	end

# end

# # puts stations.flatten.size
# valid_stations = stations.reject { |ea| ea.not_valid? }

# valid_stations.each do |ea|
# 	ea.print_matches_in(valid_stations)
# end

# play with tolerance between matches (result array)
# create a method for taking a location from the user and finding its matches (so i'm not always running tests for all locations)
# if there are several matches within a certain radius (like, 500 km), return only 1 of them (most exact match), then chosen randomly after that, and also return matches that haven't been shown recently to increase variety
# list of stations that are sensible sounding
# show total number of matches so you have an idea how many you're getting (and how many is unwieldy)
# i think you're eventually going to have to go through the whole csv file and make sure the data is accurate.
# show actual conditions of "current location", and conditions of places being matched.
# convert time into current time zone?? (well so far current time only shows up on station being matched) - that's just a matter of changing
# utc into current timezone

# for those countries that don't show up on aeris, you could have a method that accesses data from wunderground, cuz
# they seem to have a lot more locations, using the pws's. just because these places are ones that a user has likely never heard of or doesn't know much about! those are the ones you want to make sure you're including. don't worry about this too much right now
