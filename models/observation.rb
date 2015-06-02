require "json"
require "time"
# require "rspec"

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

	def find_matches
		observations_table = DB[:weather_data]
		# this is where the error is, when the station entered as the query is missing data: you can't say 'nil - 1' or 'nil + 1'
		# produces a no method error
		observations_table.where(:temp => (temp - 1)..(temp + 1)).where(
			:dewpoint => (dewpoint - 1)..(dewpoint + 1)).where(
			:humidity => (humidity - 5)..(humidity + 5)).where(
			:weather_primary_coded => weather_primary_coded).where(
			:wind_kph => (wind_kph - 5)..(wind_kph + 5)).exclude(
			:station_id => id).all
	end

	def temp_score(query_temp)

		if temp == query_temp
			score = 30
		elsif (temp - query_temp) == 1
			score = 20
		elsif (query_temp - temp) == 1
			score = 20
		else
			score = 10
		end
		
		score
	end

	def dewpoint_score(query_dewpoint)

		if dewpoint == query_dewpoint
			score = 20
		elsif (dewpoint - query_dewpoint) == 1
			score = 15
		elsif (query_dewpoint - dewpoint) == 1
			score = 15
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

