require "json"
require "time"

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

	def self.from_json(hash)
		observations = hash["ob"]
		self.new(
			hash["id"],
			observations["dateTimeISO"],
			observations["tempC"],
			observations["dewpointC"],
			observations["humidity"],
			observations["weatherShort"],
			observations["weatherPrimaryCoded"],
			observations["cloudsCoded"],
			observations["isDay"],
			observations["windKPH"],
			observations["windDir"]
			)
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

end

def matches?(query_station, observations)
	observations.where(:temp => (query_station.temp - 1)..(query_station.temp + 1)).where(
		:dewpoint => (query_station.dewpoint - 1)..(query_station.dewpoint + 1)).where(
		:humidity => (query_station.humidity - 5)..(query_station.humidity + 5)).where(
		:weather_primary_coded => query_station.weather_primary_coded).where(
		:wind_kph => (query_station.wind_kph - 5)..(query_station.wind_kph + 5)).exclude(
		:station_id => query_station.id).all
end

# DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')

# observations = DB[:weather_data]
# stations = DB[:stations]

# stations_data_for_user_id = stations.where(:id => my_id).first

# def get_station_data(id,table)
# 	table.where(:id => id).first
# end

# city_data = get_station_data(my_id, stations)

# def find_city_id(city, table)
# 	id = table.select(:id).where(:name=>city).first
# end

# puts find_city_id(my_city, stations)

# to find the weather data associated with a station id
# def find_station(id)
# 	observations = DB[:weather_data]
# 	match = observations.where(:station_id=>id.upcase).first
# 	match
# end

# station_to_match = find_station(my_id)
# station_to_match_data = Observation.from_table(station_to_match)


# id_to_match = get_station_data(my_id, stations)
# # so with too_close, you get all the stations that match, then, using their ids, check stations to see if they're too close
# all_matches = matches?(station_to_match_data, observations)
# match_data_array = all_matches.map do |ea|
# 	Observation.from_table(ea)
# end

# match_data_ids = all_matches.map do |ea|
# 	ea[:station_id]
# end

# # gives an array of station hashes from stations table
# results = match_data_ids.map do |ea|
# 	result = stations.where(:id=>ea).first
# end

