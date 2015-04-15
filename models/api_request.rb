require "byebug"
require "json"
require "open-uri"
require "uri"
require "fileutils"
require "active_support/core_ext/object/to_query.rb"
require "haversine"
require "pg"
require "sequel"
# require "sinatra"
require "./stations.rb"

class Observation

	attr_reader :id, :time, :temp, :dewpoint, :humidity, :conditions, :weather_primary_coded, :clouds_coded, :is_day, :wind_kph, :wind_direction

	def initialize(id, time, temp, dewpoint, humidity, conditions, weather_primary_coded, clouds_coded, is_day, wind_kph, wind_direction)
		@id = id
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

	def self.from_table(hash)
		self.new(
			hash[:station_id], # need this for identification, and to join with stations table
			hash[:time],
			hash[:temp],
			hash[:dewpoint],
			hash[:humidity],
			hash[:conditions],
			hash[:weather_primary_coded],
			hash[:clouds_coded],
			hash[:is_day],
			hash[:wind_kph],
			hash[:wind_direction]
			)
	end

# for comparing conditions with coded weather, so that you get matches from day or night
	# def not_valid?
	# 	temp.nil? || dewpoint.nil? || humidity.nil? || weather_primary_coded.nil? || conditions.nil?
	# end

# this is not currently being used. time from api is local, with difference from GMT shown as +/-
	def matches_time?(other_station)
		other_station.time <= (self.time + 1) && other_station.time >= (self.time - 1)
	end

	# def too_close?(station)
	# 	distance = Haversine.distance(self.latitude, self.longitude, station.latitude, station.longitude)
	# 	distance.to_km < 2000
	# end

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
		new_observation = Observation.from_json(ea)

		station = {}
		station[:id] = new_observation.id
		station[:time] = new_observation.time
		station[:temp] = new_observation.temp
		station[:dewpoint] = new_observation.dewpoint
		station[:humidity] = new_observation.humidity
		station[:conditions] = new_observation.conditions
		station[:weather_primary_coded] = new_observation.weather_primary_coded
		station[:clouds_coded] = new_observation.clouds_coded
		station[:is_day] = new_observation.is_day
		station[:wind_kph] = new_observation.wind_kph
		station[:wind_direction] = new_observation.wind_direction

		all_stations[new_observation.id] = station
	end

	all_stations

end

# you're going to want this to write directly into the weather_data table, and skip this file-writing step
def write_to_json_file(data)
	File.open("../weather_data/all_stations.json", "a") { |file| file.write(data) }
end

countries = ["ae", "af", "ag", "al", "am", "ao", "aq", "ar", "at", "au", "aw", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bj", "bm", "bo", "br", "bs", "bt", "bw", "by", "bz", "cf", "cg", "ch", "ci", "cl", "cm", "cn", "co", "cr", "cu", "cv", "cy", "cz", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "es", "et", "fi", "fj", "fk", "fm",  "fr", "ga", "gb", "gd", "ge", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gt", "gw", "gy", "hk", "hn", "hr", "hu", "id", "ie", "il", "in", "iq", "ir", "is", "it", "jm", "jo", "jp", "ke", "kg", "kh", "km", "kn", "kr", "kw", "ky", "kz", "la", "lb", "lc", "lk", "lr", "lt", "lu", "lv", "ly", "ma", "md", "mk", "ml", "mm", "mo", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "ne" , "ng", "ni", "nl", "no", "np", "nz", "om", "pa", "pe", "pg", "ph", "pk", "pl", "pt", "py", "qa", "ro", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sk", "sl", "sn", "sr", "st", "sv", "sy", "sz",  "td", "tg", "th", "tj", "tm", "tn", "tr", "tt", "tw", "tz", "ua", "ug", "uy", "uz", "vc", "ve", "vi", "vn", "vu", "ws", "ye", "za", "zm", "zw"]

us_and_canada = ["ab", "al", "ak", "az", "ar", "bc", "ca", "co", "ct", "de", "dc", "fl", "ga", "hi", "id", "il", "in", "ia", "ks", "ky", "la", "mb", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt", "nb", "ne", "nv", "nh", "nj", "nl", "nm", "ns", "nt", "nu", "ny", "nc", "nd", "oh", "ok", "on", "or", "pa", "pe", "qc", "ri", "sc", "sd", "sk", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi", "wy", "yt"]

# get_all_data(countries, us_and_canada)

# table.insert(:station_id=>station[:station_id], :time=>station[:time], :temp=>station[:temp], :dewpoint=>station[:dewpoint], :humidity=>station[:humidity], :conditions=>station[:conditions], :weather_coded=>station[:weather_coded], :clouds_coded=>station[:clouds_coded], :is_day=>station[:is_day], :wind_kph=>station[:wind_kph], :wind_direction=>station[:wind_direction])

# this section to make an Observation instance from the observations table in mydb

DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')

# my_city = ARGV.first
my_id = ARGV.first
observations = DB[:weather_data]
stations = DB[:stations]

stations_data_for_user_id = stations.where(:id => my_id).first

def get_station_data(id,table)
	table.where(:id => id).first
end

city_data = get_station_data(my_id, stations)

def find_city_id(city, table)
	id = table.select(:id).where(:name=>city).first
end

# puts find_city_id(my_city, stations)

# to find the weather data associated with a station id
def find_station(id)
	observations = DB[:weather_data]
	match = observations.where(:station_id=>id.upcase).first
	match
end

station_to_match = find_station(my_id)
station_to_match_data = Observation.from_table(station_to_match)

def matches?(query_station, observations)
	observations.where(:temp => (query_station.temp - 1)..(query_station.temp + 1)).where(
		:dewpoint => (query_station.dewpoint - 1)..(query_station.dewpoint + 1)).where(
		:humidity => (query_station.humidity - 5)..(query_station.humidity + 5)).where(
		:weather_primary_coded => query_station.weather_primary_coded).where(
		:wind_kph => (query_station.wind_kph - 5)..(query_station.wind_kph + 5)).exclude(
		:station_id => query_station.id).all
end



# def print_matches_in(stations)
# 		matching = stations.find_all do |ea|
# 	 	ea != self && !ea.too_close? && self.matches?(ea)
# 	 	ea != self && !self.too_close?(ea) && self.matches?(ea)
# 		end

# end

id_to_match = get_station_data(my_id, stations)
# so with too_close, you get all the stations that match, then, using their ids, check stations to see if they're too close
all_matches = matches?(station_to_match_data, observations)
match_data_array = all_matches.map do |ea|
	Observation.from_table(ea)
end

match_data_ids = all_matches.map do |ea|
	ea[:station_id]
end

# gives an array of station hashes from stations table
results = match_data_ids.map do |ea|
	result = stations.where(:id=>ea).first
end

puts results
# def too_close?(station_to_compare, user_station)
# 	distance = Haversine.distance(user_station.latitude, user_station.longitude, station_to_compare.latitude, station_to_compare.longitude)
# 	distance.to_km < 2000
# end

def too_close?(station_to_compare, user_station)
	distance = Haversine.distance(user_station[:latitude], user_station[:longitude], station_to_compare[:latitude], station_to_compare[:longitude])
	distance.to_km < 1000
end

matches = results.each do |ea|
	puts too_close?(ea, stations_data_for_user_id)
end

# items.where(:price => 100..200).sql # calling .sql just gives you the raw SQL which is great!
#=> "SELECT * FROM items WHERE (price >= 100 AND price <= 200)"

# would like get_all_data to write directly to the database, not ->to file and then ->to database
# search with city name, find corresponding station id in stations, then use that id to search in weather_data to match other cities
# scoring scheme for matches!
# get the too_close? method working