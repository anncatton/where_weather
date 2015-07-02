require "json"
require "time"
require "haversine"
# require "rspec"

class Observation

	attr_reader :station, :time, :temp, :dewpoint, :humidity, :conditions, :weather_primary_coded, :clouds_coded, :is_day, :wind_kph, :wind_direction

	def initialize(station, time, temp, dewpoint, humidity, conditions, weather_primary_coded, clouds_coded, is_day, wind_kph, wind_direction)
		@station = station
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

	def self.from_table(join_hash)
		self.new(
			Station.new(join_hash[:station_id], join_hash[:name], join_hash[:region], join_hash[:country], join_hash[:latitude], join_hash[:longitude]),
			join_hash[:time],
			join_hash[:temp],
			join_hash[:dewpoint],
			join_hash[:humidity],
			join_hash[:conditions],
			join_hash[:weather_primary_coded],
			join_hash[:clouds_coded],
			join_hash[:is_day],
			join_hash[:wind_kph],
			join_hash[:wind_direction]
			)
	end

	def self.match_in_timeframe(station_id, start_time, end_time)


		stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)
# where{time >= start_time}.where{time <= end_time}.
		result = stations_and_observations_join.where(:station_id => station_id.upcase).first
		
		if result 
			from_table(result)
		end
	end

	def find_matches
		# in this method, self is an Observation instance, not the whole db record for the query location
		# this method returns an array of db records, not instances of Observation
		stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)
	
		matches = stations_and_observations_join.where(:temp => (temp - 1)..(temp + 1)).where(
			:dewpoint => (dewpoint - 1)..(dewpoint + 1)).where(
			:humidity => (humidity - 5)..(humidity + 5)).where(	
			:weather_primary_coded => weather_primary_coded).where(
			:wind_kph => (wind_kph - 5)..(wind_kph + 5)).exclude(
			:station_id => station.id).all

		time_matches = matches.reject do |ea|
			ea[:time] <= (self.time - 3600)
		end

	end

	def temp_score(query_temp)

		if temp == query_temp
			score = 30
		elsif (temp - query_temp) || (query_temp - temp) == 1
			score = 20
		else
			score = 10
		end
		
		score
	end

	def dewpoint_score(query_dewpoint)

		if dewpoint == query_dewpoint
			score = 20
		elsif (dewpoint - query_dewpoint) || (query_dewpoint - dewpoint) == 1
			score = 15
		else
			score = 10
		end

		score
	end

	def humidity_score(query_humidity)

		if humidity == query_humidity
			score = 15
		elsif (humidity - query_humidity) || (query_humidity - humidity) == 1
			score = 14
		elsif (humidity - query_humidity) || (query_humidity - humidity) == 2
			score = 13
		elsif (humidity - query_humidity) || (query_humidity - humidity) == 3
			score = 12
		elsif (humidity - query_humidity) || (query_humidity - humidity) == 4
			score = 11
		else
			score = 10
		end

		score
	end

	def wind_kph_score(query_wind_kph)

		if wind_kph == query_wind_kph
			score = 15
		elsif (wind_kph - query_wind_kph) || (query_wind_kph - wind_kph) == 1
			score = 14
		elsif (wind_kph - query_wind_kph) || (query_wind_kph - wind_kph) == 2
			score = 13
		elsif (wind_kph - query_wind_kph) || (query_wind_kph - wind_kph) == 3
			score = 12
		elsif (wind_kph - query_wind_kph) || (query_wind_kph - wind_kph) == 4
			score = 11
		else
			score = 10
		end

		score
	end
	# this method is for finding the entry in stations table that matches what the user has entered on the website, so you have
	# access to the station id (which is needed to locate it in observations). - Incorrect. this is using the id that is passed into
	# the navigation bar to look in the observations table for that location's record in the database.
	# in order for this to work, does this have to be an instance of the Observation class? that's what happens when you put a method
	# inside a class, you can only call that method on instances of that class. but then, similar or same methods for different classes can
	# have the same name, and ruby will know what to do for each one because it belongs to a class (.to_s is an example of this)

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

