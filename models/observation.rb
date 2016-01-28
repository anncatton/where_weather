require "json"
# require "ruby-prof"

class Observation

	attr_reader :station, :time, :temp, :dewpoint, :humidity, :conditions, :weather_primary_coded, :clouds_coded,
		:is_day, :wind_kph, :wind_direction

	def initialize(station, time, temp, dewpoint, humidity, conditions, weather_primary_coded, clouds_coded,
		is_day, wind_kph, wind_direction)
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
			Station.new(join_hash[:station_id],
				join_hash[:name],
				join_hash[:region], 
				join_hash[:country], 
				join_hash[:latitude], 
				join_hash[:longitude]),
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

# this uses the query station's last observed time as a reference point for start and end time
	# def find_most_recent_observation(station_id)
	# 	observations = DB[:weather_data]
	# 	observations.where(station_id: station_id.upcase).max(:time)
	# end

	def self.match_in_timeframe(station_id)

		observations = DB[:weather_data]
		query_time = observations.where(station_id: station_id.upcase).max(:time)

		stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)
		result = stations_and_observations_join.where(
			:station_id => station_id.upcase).where(
			time: query_time).first

		if result
			if result[:temp].nil? || result[:dewpoint].nil? || result[:weather_primary_coded].nil?
				result = nil
			else
				from_table(result)
			end
		end

	end


# are you getting the right time matches? or is it changing db times to local time when they're actually utc?
# your hash result from above parses to local time
	def find_matches(start_time, end_time)

		stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)

		initial_match_query = stations_and_observations_join.where(
			:temp => (temp - 1)..(temp + 1)).where(
			:dewpoint => (dewpoint - 1)..(dewpoint + 1)).where(
			:weather_primary_coded => weather_primary_coded).where{
			time >= start_time}.where{
			time <= end_time}.exclude(
			:station_id => station.id)

		query = initial_match_query

		if wind_kph
			query = query.where(
				:wind_kph => (wind_kph - 5)..(wind_kph + 5))
		end

		if humidity
			query = query.where(
				:humidity => (humidity - 5)..(humidity + 5))
		end

		query.all

	end

	def temp_score(query_temp)

		if temp == query_temp
			30
		elsif ((temp - query_temp) || (query_temp - temp)).abs == 1
			20
		else
			10
		end
		
	end

	def dewpoint_score(query_dewpoint)

		if dewpoint == query_dewpoint
			20
		elsif ((dewpoint - query_dewpoint) || (query_dewpoint - dewpoint)).abs == 1
			15
		else
			10
		end

	end

	def humidity_score(query_humidity)

		if query_humidity.nil? || humidity.nil?
			0
		elsif humidity == query_humidity
			15
		elsif ((humidity - query_humidity) || (query_humidity - humidity)).abs == 1
			14
		elsif ((humidity - query_humidity) || (query_humidity - humidity)).abs == 2
			13
		elsif ((humidity - query_humidity) || (query_humidity - humidity)).abs == 3
			12
		elsif ((humidity - query_humidity) || (query_humidity - humidity)).abs == 4
			11
		else
			10
		end

	end

	def wind_kph_score(query_wind_kph)

		if query_wind_kph.nil? || wind_kph.nil?
			0
		elsif wind_kph == query_wind_kph
			15
		elsif ((wind_kph - query_wind_kph) || (query_wind_kph - wind_kph)).abs == 1
			14
		elsif ((wind_kph - query_wind_kph) || (query_wind_kph - wind_kph)).abs == 2
			13
		elsif ((wind_kph - query_wind_kph) || (query_wind_kph - wind_kph)).abs == 3
			12
		elsif ((wind_kph - query_wind_kph) || (query_wind_kph - wind_kph)).abs == 4
			11
		else
			10
		end

	end

end