require "sinatra"
require "json"
require "./models/stations.rb"
require "./models/observation.rb"
require "haversine"
require "byebug"
require "pg"
require "sequel"
require "logger"
require "time"

DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')
# DB.sql_log_level = :debug
DB.loggers << Logger.new($stdout)

get '/' do
	redirect to('/where_weather')
end

get '/where_weather' do
 
	stations_table = DB[:stations]
	observations_table = DB[:weather_data]

	def time_threshold
		current_time = Time.parse("2015-04-20T10:19:00-04:00")
		current_time - 3600
	end
	
	def find_station_observation(station_id) # this finds the record in observations that is within the time window (the last 60min)
		observations = DB[:weather_data]
		time_to_compare = time_threshold
		matching_observation = observations.where{time >= (time_to_compare - 3600)}.where(:station_id => station_id.upcase).first
		matching_observation
	end

# not sure you need a valid check cuz the db search should ignore any records that are missing necessary values
# at some point you'll need to specify that temp, dewpoint and humidity are to be checked first, and then values like
# windspeed etc are more optional and can be checked on a second run
	# valid_stations = stations_to_compare.reject do |ea|
	# 	ea.not_valid?
	# end

	if params.empty?
		erb :index, :layout => :layout, :locals => { :matching_station => nil,
																								:locations_match => nil,
																								:station => nil }
	else
		station_id = params[:id]
		station_to_match = find_station_observation(station_id)
		match_in_stations_table = stations_table.where(:id=>station_id.upcase).first
		station = Station.from_table(match_in_stations_table)

		# for error when there's no matching observation within the current timeframe (not recent enough)
		if station_to_match.nil? # if there's no matching observation for the station id
			erb :index, :layout => :layout, :locals => {:station => station,
																									:station_to_match => station_to_match,
																									:station_to_match_data => nil,
																									:matches_to_display => []}
		else

			station_to_match_data = Observation.from_table(station_to_match)
# this is making sure temp, dewpoint and weather conditions coded are present in the query station. can you find this out while querying the db?
			if station_to_match_data.temp.nil? || station_to_match_data.dewpoint.nil? || station_to_match_data.weather_primary_coded.nil?
				erb :index, :layout => :layout, :locals => {:station => station,
																										:station_to_match => station_to_match,
																										:station_to_match_data => nil,
																										:matches_to_display => []}
			else
				all_matches = station_to_match_data.find_matches # an array of hashes from observations table. not yet Observation instances. this is the first place you have station ids for the matches, so this is the first place you could filter out stations that are too close to the query station

				matches_within_window = all_matches.reject do |ea|
					time_to_compare = time_threshold
					Time.parse(ea[:time]) <= time_to_compare
				end

				all_matches_in_stations = matches_within_window.map do |ea|
					matches = stations_table.where(:id=>ea[:station_id]).first
					matches
				end
	
				valid_matches = all_matches_in_stations.reject do |ea|
					ea.nil?
				end

				matching_stations = valid_matches.map do |ea|
					Station.from_table(ea)
				end

				matches_not_too_close = matching_stations.reject do |ea|
					ea.too_close?(station)
				end

				match_ids = matches_not_too_close.map do |ea|
					ea.id
				end

# now, to find the percentage matches, you have to take the station ids from matches_not_too_close and find them again in observations so you have just the observations you need
				# match_observations = matches_within_window.map do |ea| # Observation instances for matches
				# 	Observation.from_table(ea)
				# end

# right now this is giving me back all the original matches from matches_within_window
				final_matches = matches_within_window.select do |ea|
					matches = match_ids.include?(ea[:station_id])
					matches
				end

# is there a way to save this particular record just by referring to the db id number (not the station id) in the observations table? then you could just save it and plug it in when you need it again, as it's a unique record.
				match_observations = final_matches.map do |ea|
					observation = Observation.from_table(ea)
					# puts observation.temp_score(station_to_match_data.temp)
					temp = observation.temp_score(station_to_match_data.temp)
					dewpoint = observation.dewpoint_score(station_to_match_data.dewpoint)

					total_score = (temp + dewpoint)/50.0
					total_score * 100
				end

				# all_matches_in_stations_table = matches_within_window.map do |ea| # all_matches_in_stations_table is data from stations
				# 	stations_table.where(:id=>ea[:station_id].upcase).first
				# end

		# this shouldn't be necessary if you add the foreign key reference back into weather_data
				# valid_matches = all_matches_in_stations_table.reject do |ea|
				# 	ea.nil?
				# end

				# match_stations_data = valid_matches.map do |ea|
				# 	Station.from_table(ea)
				# end
				
				# matches_not_too_close = match_stations_data.reject do |ea|
				# 	too_close?(ea, station)
				# end


				erb :index, :layout => :layout, :locals => {:station_to_match_data => station_to_match_data,
																										:station => station,
																										:station_to_match => station_to_match,
																										:matches_to_display => matches_not_too_close,
																										:match_observations => match_observations }
			end

		end

	end


end

# this populates the drop down with full location name using input from the user and matching with data from LOCATIONS
get '/location_search' do

	stations_table = DB[:stations]
	# observations_table = DB[:weather_data]

  content_type :json
  query = params[:query]

  matches = stations_table.where(Sequel.ilike(:name, query+'%'))
  # matches = station_list.find_all do |ea|
  # 	next if ea[:name].nil? # do i need this anymore, now the database has a name for each location?
  # 	ea[:name].downcase.start_with?(query.downcase)
  # end

  content = if matches.empty?
  	erb :_no_result, :layout => false
	else
  	erb :_data_field, :layout => false, :locals => { :matches => matches }
	end

# what is this first_city section for?
	# first_city = if matches.empty?
	# 	erb :_no_result
	# else
	# 	erb :_display_span, :layout => false, :locals => {:first_match => matches.first }
	# end

 #  { :html => content, :first_match => first_city }.to_json

 { :html => content }.to_json

end