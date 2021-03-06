require "json"
require "open-uri"
require "uri"
require "byebug"
require "haversine"
require "fileutils"
require "active_support/core_ext/object/to_query.rb"
require "csv"

# require "time"

# require "./edited_cities_map.rb"
# does the path for these local files seem strange because the path is not actually
# relative from the file you're in, but relative to where ruby normally looks for required files and libraries?
# seems to depend which part of the program is using the require:
# for code run inside this file, it's "./edited_cities_map.rb"
# for where_app.rb, it's "./models/edited_cities_map.rb"
require "./models/edited_cities_map.rb" # for running on local server

class Station

	attr_reader :id, :city, :region, :country, :latitude, :longitude, :time, :temp, :dewpoint, :humidity, :conditions, :weather_primary_coded, :clouds_coded, :is_day, :wind_kph, :wind_direction

	def initialize(id, city, region, country, latitude, longitude, time, temp, dewpoint, humidity, conditions, weather_primary_coded, clouds_coded, is_day, wind_kph, wind_direction)
		@id = id
		@city = city
		@region = region
		@country = country
		@latitude = latitude
		@longitude = longitude
		@time = time
		@temp = temp
		@dewpoint = dewpoint
		@humidity = humidity
		@conditions = conditions
		@weather_primary_coded = weather_primary_coded
		@clouds_coded = clouds_coded
		@is_day = is_day
		@wind_kph = wind_kph
		@wind_direction = wind_direction
	end

	def self.from_hash(hash)
		observations = hash['ob']
		self.new(
			hash['id'],
			hash['place']['name'],
			hash['place']['state'],
			hash['place']['country'],
			hash['loc']['lat'],
			hash['loc']['long'],
			observations['dateTimeISO'], 
			observations['tempC'], 
			observations['dewpointC'], 
			observations['humidity'], 
			observations['weatherShort'],
			observations['weatherPrimaryCoded'],
			observations['cloudsCoded'],
			observations['isDay'],
			observations['windKPH'],
			observations['windDir']
			)
	end

	def self.from_json(hash)
		self.new(
			hash["id"],
			hash["city"],
			hash["region"],
			hash["country"],
			hash["latitude"],
			hash["longitude"],
			hash["time"],
			hash["temp"],
			hash["dewpoint"],
			hash["humidity"],
			hash["conditions"],
			hash['weather_primary_coded'],
			hash['clouds_coded'],
			hash['is_day'],
			hash['wind_kph'],
			hash['wind_direction']
			)
	end

# doesn't look like this one is being called in where_app anymore? however self.from_hash is still used in the data gathering from
# the api
	def self.find(station_id)
	# finds the [:station] inside LOCATIONS that matches station_id (which is coming from params[:id])
		match = LOCATIONS.find do |ea|
			station_id.downcase == ea[:station].downcase
		end
		# then create a new instance of Station using the key-value pairs inside whichever station hash matches station_id
		self.from_hash(match)

	end

# for comparing conditions with coded weather, so that you get matches from day or night
	def not_valid?
		temp.nil? || dewpoint.nil? || humidity.nil? || weather_primary_coded.nil? || conditions.nil?
	end

# for comparing conditions with conditions string, so only day == day, and night == night
	# def not_valid?
	# 	temp.nil? || dewpoint.nil? || humidity.nil? || conditions.nil?
	# end

# this is not currently being used. time from api is local, with difference from GMT shown as +/-
	def matches_time?(other_station)
		other_station.time <= (self.time + 1) && other_station.time >= (self.time - 1)
	end

	def matches_temp?(other_station)
		other_station.temp <= (self.temp + 1) && other_station.temp >= (self.temp - 1)
	end

	def matches_dewpoint?(other_station)
		other_station.dewpoint <= (self.dewpoint + 1) && other_station.dewpoint >= (self.dewpoint - 1)
	end

	def matches_humidity?(other_station)
		other_station.humidity <= (self.humidity + 10) && other_station.humidity >= (self.humidity - 10)
	end

	def matches_windspeed?(other_station)
		other_station.wind_kph <= (self.wind_kph + 5) && other_station.wind_kph >= (self.wind_kph - 5)
	end

# uses weather code to compare sky conditions. this allows day <-> night matches
	def matches?(other_station)
		other_station.weather_primary_coded == self.weather_primary_coded && 
			matches_temp?(other_station) &&
			matches_dewpoint?(other_station) &&
			matches_humidity?(other_station) &&
			unless other_station.wind_kph.nil? || self.wind_kph.nil?
				matches_windspeed?(other_station)
			end
	end

# conditions string instead of weatherCode, no windspeed
	# def matches?(other_station)
	# 	other_station.conditions == self.conditions && 
	# 		matches_temp?(other_station) &&
	# 		matches_dewpoint?(other_station) &&
	# 		matches_humidity?(other_station)
	# end

	def too_close?(station)
		distance = Haversine.distance(self.latitude, self.longitude, station.latitude, station.longitude)
		distance.to_km < 2000
	end

end
# this section is for building requests to the api
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

# you'll then want this to automatically update every several hours
def get_all_data(country_array, state_array)

	File.open("../weather_data/all_stations.json", "w") do |f|
		f.truncate(f.size)
	end

	get_region_data(country_array, state_array)

end

# this is the method where the data gets written. so regions is an array of countries/states
def get_region_data(countries, states)

	FileUtils.mkdir_p "../weather_data/"

	processed_data = {}

	countries.each do |ea|
		processed_data.merge!(processed_data_for_country(ea))
	end

	states.each do |ea|
		processed_data.merge!(processed_data_for_state(ea))
	end

	write_to_json_file(processed_data.to_json)

end

def processed_data_for_country(country_name)
	raw_data = get_data_for_country(country_name)
	extract_station_data(raw_data)
end

def processed_data_for_state(state_name)
	raw_data = get_data_for_state(state_name)
	extract_station_data(raw_data)
end

def open_region_uri(uri)
	open(uri) do |io|

		json_string = io.read
		data_hash = JSON.parse(json_string)
		data_hash["response"]
	end
end

def get_data_for_country(country_name)
	country_uri = uri_for_country(country_name)
	open_region_uri(country_uri)
end

def get_data_for_state(state_name)
	state_uri = uri_for_state(state_name)
	open_region_uri(state_uri)
end

def extract_station_data(raw_data)
	all_stations = {}

	raw_data.map do |ea|
		new_station = Station.from_hash(ea)

		station = {}
		station[:id] = new_station.id
		station[:city] = new_station.city
		station[:region] = new_station.region
		station[:country] = new_station.country
		station[:latitude] = new_station.latitude
		station[:longitude] = new_station.longitude
		station[:time] = new_station.time
		station[:temp] = new_station.temp
		station[:dewpoint] = new_station.dewpoint
		station[:humidity] = new_station.humidity
		station[:conditions] = new_station.conditions
		station[:weather_primary_coded] = new_station.weather_primary_coded
		station[:clouds_coded] = new_station.clouds_coded
		station[:is_day] = new_station.is_day
		station[:wind_kph] = new_station.wind_kph
		station[:wind_direction] = new_station.wind_direction

		all_stations[new_station.id] = station
	end

	all_stations

end

def write_to_json_file(data)
	File.open("../weather_data/all_stations.json", "a") { |file| file.write(data) }
end

countries = ["ae", "af", "ag", "al", "am", "ao", "aq", "ar", "at", "au", "aw", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bj", "bm", "bo", "br", "bs", "bt", "bw", "by", "bz", "cf", "cg", "ch", "ci", "cl", "cm", "cn", "co", "cr", "cu", "cv", "cy", "cz", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "es", "et", "fi", "fj", "fk", "fm",  "fr", "ga", "gb", "gd", "ge", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gt", "gw", "gy", "hk", "hn", "hr", "hu", "id", "ie", "il", "in", "iq", "ir", "is", "it", "jm", "jo", "jp", "ke", "kg", "kh", "km", "kn", "kr", "kw", "ky", "kz", "la", "lb", "lc", "lk", "lr", "lt", "lu", "lv", "ly", "ma", "md", "mk", "ml", "mm", "mo", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "ne" , "ng", "ni", "nl", "no", "np", "nz", "om", "pa", "pe", "pg", "ph", "pk", "pl", "pt", "py", "qa", "ro", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sk", "sl", "sn", "sr", "st", "sv", "sy", "sz",  "td", "tg", "th", "tj", "tm", "tn", "tr", "tt", "tw", "tz", "ua", "ug", "uy", "uz", "vc", "ve", "vi", "vn", "vu", "ws", "ye", "za", "zm", "zw"]

us_and_canada = ["ab", "al", "ak", "az", "ar", "bc", "ca", "co", "ct", "de", "dc", "fl", "ga", "hi", "id", "il", "in", "ia", "ks", "ky", "la", "mb", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt", "nb", "ne", "nv", "nh", "nj", "nl", "nm", "ns", "nt", "nu", "ny", "nc", "nd", "oh", "ok", "on", "or", "pa", "pe", "qc", "ri", "sc", "sd", "sk", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi", "wy", "yt"]

# get_all_data(countries, us_and_canada)

def parse_json_file(filename)

	with_downcased_keys = {}

	File.open(filename, "r") do |f|
		json_file = f.read
		parsed_file = JSON.parse(json_file)

		parsed_file.each do |k,v| 
			with_downcased_keys[k.downcase] = v
		end
	end

	with_downcased_keys

end

# station_hash = parse_json_file("../weather_data/all_stations.json")
# File.open("../weather_data/parsed_station_file.rb", "w") { |f| f.write(station_hash) }

# this matches a station id with a station id in the json conditions file. specific to all_stations
def find_station(station_id)
	station_hash = parse_json_file("./weather_data/all_stations.json")
	station_hash[station_id.downcase]
end


# need to figure out which file (all_stations and valid_station_map) should contain which data. for example, does all_stations need
# to have all the city, region, country etc?
# both need station ids because that's the unique identifier

# this removed non-relevant stations from location_id_map
# parsed_all_stations = parse_json_file("../weather_data/all_stations.json")

# all_station_times = parsed_all_stations.map do |k, v|
# 	v["time"]
# end

# valid_stations = LOCATIONS.select do |ea|
# 	if all_stations_ids.include?(ea[:station])
# 		ea
# 	end
# end

# File.open("./valid_stations.rb", "w") { |file| file.write(valid_stations) }

# matching_station = find_station(my_station_id)
# new_station = Station.from_json(matching_station)
# station_hash = parse_json_file("./weather_data/all_stations.json") # hash of station hashes, main station keys (k) lowercase

# # makes an array of Station instances
# stations_to_compare = station_hash.map do |k, v|
# 	Station.from_json(v)
# end

# valid_stations = stations_to_compare.reject do |ea|
# 	ea.not_valid?
# end

# edited_locations = LOCATIONS.each do |ea|
# 	if ea[:city].include? "|"
# 		new_city = ea[:city].gsub!(/\|.*/, "")
# 		ea[:city] = new_city
# 	else
# 		ea[:city]
# 	end

# end


# File.open("./edited_cities_map.rb", "w") { |file| file.write(edited_locations) }

# ob.dateTimeISO	(string) ISO 8601 date of the observation.
# irb(main):001:0> Time.parse("2015-02-22T19:00:00-03:00")
# NoMethodError: undefined method `parse' for Time:Class
# 	from (irb):1
# 	from /Users/anncatton/.rbenv/versions/2.1.3/bin/irb:11:in `<main>'
# irb(main):002:0> require 'time'
# => true
# irb(main):003:0> Time.parse("2015-02-22T19:00:00-03:00")
# => 2015-02-22 17:00:00 -0500
# irb(main):004:0> Time.parse("2015-02-22T19:00:00-03:00").utc
# => 2015-02-22 22:00:00 UTC
# irb(main):005:0> Time.parse("2015-02-22T19:00:00-03:00").class
# => Time
# irb(main):006:0> Time.parse("2015-02-22T19:00:00-03:00").utc
# => 2015-02-22 22:00:00 UTC
# irb(main):007:0> time = Time.parse("2015-02-22T19:00:00-03:00")
# => 2015-02-22 17:00:00 -0500
# irb(main):008:0> time2 = Time.parse("2015-02-22T19:32:00-03:00")
# => 2015-02-22 17:32:00 -0500
# irb(main):009:0> time - time2
# => -1920.0 # this is in seconds
# irb(main):011:0> (time - time2) / 60 # this converts the seconds figure above to minutes
# => -32.0
