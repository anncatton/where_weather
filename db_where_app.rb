require "sinatra"
require "json"
require "./models/stations.rb"
require "./models/observation.rb"
require "byebug"
require "pg"
require "sequel"
require "logger"
require "time"

DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')
DB.loggers << Logger.new($stdout)

get '/' do
	redirect to('/where_weather')
end

get '/where_weather' do

	# do i want to access DB through these variables or just directly?
	stations_table = DB[:stations]
	observations_table = DB[:weather_data]
	stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)

	def time_threshold
		current_time = Time.parse("2015-04-20T10:19:00-04:00")
		current_time - 3600
	end
	
	# def find_station_observation(station_id) # this finds the record in observations that is within the time window (the last 60min)
	# 	observations = DB[:weather_data]
	# 	time_to_compare = time_threshold
	# 	# do i need the upcase call on station_id here?
	# 	matching_observation = observations.where{time >= (time_to_compare - 3600)}.where(:station_id => station_id.upcase).first
	# 	matching_observation
	# end

	def find_station_and_observation(station_id)
		# stations_table = DB[:stations]
		# observations_table = DB[:weather_data]
		stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)
		time_to_compare = time_threshold
		stations_and_observations_join.where{time >= (time_to_compare - 3600)}.where(:station_id => station_id.upcase).first
	end

	station_id = params[:id]

	if params.empty?
		erb :index, :layout => :layout, :locals => { :matching_station => nil,
																								:locations_match => nil,
																								:station => nil }
	else
		station_to_match = find_station_and_observation(station_id)

		if station_to_match.nil? # this saves error if someone types in a random set of letters, numbers, or nothing after id= in the address bar. does not save if someone types where_weather?id without the =
		# also for error when there's no matching observation within the current timeframe (not recent enough), or if there's no observation at all for the queried station (like you found with CYXD). however, this page view doesn't tell the user anything
		# station_to_match being nil means the station id exists, but there are no observations within the right time frame
		# station_to_match_data being nil means there is some data missing, but there is an observation record within the right time frame
		# reading those last 2 lines, your variable names really don't make any sense!
			station_record = stations_table.where(:id=>station_id.upcase).first

			# this one is if the station is not in the stations table
			if station_record.nil?
				erb :index, :layout => :layout, :locals => {:station => nil,
																									:station_to_match => nil,
																									:station_to_match_data => nil,
																									:matched_stations_to_display => nil}
			else
				# and this one is for queries with an id in the stations table, but nothing in the weather_data table
				station = Station.from_table(station_record)

				erb :index, :layout => :layout, :locals => {:station => nil,
																									:station_to_match => nil,
																									:station_to_match_data => nil,
																									:matched_stations_to_display => []
																									}
			end

		else
			# this is for when you have a station AND observation match, but only some of the data is missing. the page view tells you that

			station = Station.from_table(station_to_match)																			
			station_to_match_data = Observation.from_table(station_to_match)
			
# this is making sure temp, dewpoint and weather conditions coded are present in the query station. can you find this out while querying the db?
			if station_to_match_data.nil? || station_to_match_data.temp.nil? || station_to_match_data.dewpoint.nil? || station_to_match_data.weather_primary_coded.nil?
				erb :index, :layout => :layout, :locals => {:station => station,
																										:station_to_match => station_to_match,
																										:station_to_match_data => nil,
																										:matched_stations_to_display => []}
			else
				
				all_matches = station_to_match_data.find_matches


				matches_within_window = all_matches.reject do |ea|
					time_to_compare = time_threshold
					Time.parse(ea[:time]) <= time_to_compare
				end

				checked_for_distance = matches_within_window.reject do |ea|
					station_to_check = Station.from_table(ea)
					station_to_check.too_close?(station)
				end

				matched_observations_to_display = checked_for_distance.map do |ea|
					Observation.from_table(ea)
				end
				
				matched_stations_to_display = checked_for_distance.map do |ea|
					Station.from_table(ea)
				end

				match_observation_scores = matched_observations_to_display.map do |ea|
					# observation = Observation.from_table(ea)
					temp = ea.temp_score(station_to_match_data.temp)
					dewpoint = ea.dewpoint_score(station_to_match_data.dewpoint)
					humidity = ea.humidity_score(station_to_match_data.humidity)
					wind_kph = ea.wind_kph_score(station_to_match_data.wind_kph)

					total_score = (temp + dewpoint + humidity + wind_kph)/80.0
					(total_score * 100).round(2)
					
				end

				erb :index, :layout => :layout, :locals => {:station_to_match_data => station_to_match_data,
																										:station => station,
																										:station_to_match => station_to_match,
																										:matched_stations_to_display => matched_stations_to_display,
																										:matched_observations_to_display => matched_observations_to_display,
																										:match_observation_scores => match_observation_scores }
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

  content = if matches.empty?
  	erb :_no_result, :layout => false
	else
  	erb :_data_field, :layout => false, :locals => { :matches => matches }
	end

 { :html => content }.to_json

end