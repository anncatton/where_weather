require "json"
require "time"
require "haversine"
# require "rspec"

class Observation

# thinking anything that is the actual station id should be renamed station_id to differentiate it from an instance of Station - or not, because your from_table method uses an actual Station instance for @station?
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

# noticing i have 'name' for city because that's what it's named in the db table. thinking 'city' is better everywhere for this because it's more specific
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

# will this method be able to accept the eventual move to checking against the time of the user query, not just a time i've put in for convenience?
# this is the method that finds the join record that matches the query location. rename method to something that makes it specific to the query, otherwise 'match' feels a little vague
# change start_ and end_time to 
	def self.match_in_timeframe(station_id, start_time, end_time)

# i keep referring to weather_data table as either singular or plural, should pick just one!
		stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)
		# this does not return the most recent observation, it returns the first record it finds that matches the criteria. i haven't yet worked out how to do the time check here or in find_matches. for the real app, i think you'll want query record to be the most recent in comparison to the time that the user makes the query - comparing to the current time minus 1 hour. this of course won't work until you can regularly update your data with new observations. if a user queries a station that doesn't update that often (like, less than every 3hrs for example) you can either display that there is not a recent enough observation, or you can use the most recent observation available with a caveat that the conditions may have changed since, and the resulting matches may not be accurate
		result = stations_and_observations_join.where(:station_id => station_id.upcase).where{time >= start_time}.where{time <= end_time}.first
		
		if result 
			from_table(result)
		end
	end

# how will find_matches structure look when it starts using the user's current time minus 1 hr?
	def find_matches(start_time, end_time)
		# in this method, self is an Observation instance, not the whole db record for the query location
		# this method returns an array of db records, not instances of Observation
		stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)
	
		matches = stations_and_observations_join.where(:temp => (temp - 1)..(temp + 1)).where(
			:dewpoint => (dewpoint - 1)..(dewpoint + 1)).where(
			:humidity => (humidity - 5)..(humidity + 5)).where(	
			:weather_primary_coded => weather_primary_coded).where(
			:wind_kph => (wind_kph - 5)..(wind_kph + 5)).where{
			time >= start_time}.where{
			time <= end_time}.exclude(
			:station_id => station.id).all

# somewhere in here maybe create an if/else for observations that are missing just some data values, so you don't have to check this in the controller file
	end

# could rewrite these with self.temp_score and so on, like with self.from_table or self.match_in_timeframe. i remember that this can be beneficial but why so? right now it's getting called on the array of matches, so like: ea.temp_score(query_temp) with query_temp being the value from the query location. so it feels kinda backwards. although maybe not since the scores belong to the mathces, not the query location. it doesn't need a matching score.
# also, put the adding up of the scores in a total_score method in this file so that it's not in the controller file, so there's less logic in the controller
	def temp_score(query_temp)

# is there a way to make all these scoring methods simpler? they're kinda long but not sure if they're alike enough to combine
		if temp == query_temp
			score = 30
		elsif (temp - query_temp) || (query_temp - temp) == 1
			score = 20
		else
			score = 10
		end
		# don't need to put score again, all these methods will return that value
		score
	end

	def dewpoint_score(query_dewpoint)

		if dewpoint == query_dewpoint
			score = 20
		# could this line be simplified by using just one of the expressions and then calling absolute value on the result, to see if it == 1?
		elsif (dewpoint - query_dewpoint) || (query_dewpoint - dewpoint) == 1
			score = 15
		else
			score = 10
		end

		score
	end

# 
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

end

# def total_score(match_to_score, query_observation)

# 	temp_score = match_to_score.temp_score(query_observation.temp)
# 	dewpoint_score = match_to_score.dewpoint_score(query_observation.dewpoint)
# 	humidity_score = match_to_score.humidity_score(query_observation.humidity)
# 	wind_kph_score = match_to_score.wind_kph_score(query_observation.wind_kph)

# 	score = (temp_score + dewpoint_score + humidity_score + wind_kph_score)/80.0
# 	percentage = (score * 100).round(2)

# 	scores_hash[match_to_score.station.id] = percentage

# end


