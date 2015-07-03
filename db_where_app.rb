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

	# do i want to access DB through these variables or just directly? the format only matters if you'll be referencing a db query a lot, then 
	# you'd want to store it in a variable. if you only need it a few times, it's not worth it
	# stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)
	
	# def time_threshold
	# 	time_to_compare = Time.parse('2015-06-29 22:00:00-04')
	# 	time_to_compare - 3600
	# end

# this finds the record in observations that is within the time window (the last 60min)
	# def find_station_and_observation(station_id)
	# 	stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)
	# 	time_to_compare = time_threshold
	# 	stations_and_observations_join.where{time >= (time_to_compare - 3600)}.where(:station_id => station_id.upcase).first
	# end

	station_id = params[:id]

	if station_id.nil?

		erb :index, :layout => :layout, :locals => {:matching_observation => nil}

	else

		matching_observation = Observation.match_in_timeframe(station_id, '2015-07-02 00:00:00', '2015-07-02 02:00:00')

		if matching_observation.nil? # this saves error if someone types in a random set of letters, numbers, or nothing after id= in the address bar. does not save if someone types where_weather?id without the =
		# also for error when there's no matching observation within the current timeframe (not recent enough), or if there's no observation at all for the queried station (like you found with CYXD). however, this page view doesn't tell the user anything
		# station_to_match being nil means the station id exists, but there are no observations within the right time frame
		# station_to_match_data being nil means there is some data missing, but there is an observation record within the right time frame
		# reading those last 2 lines, your variable names really don't make any sense!
			station_record = DB[:stations].where(:id=>station_id.upcase).first

			# this one is if the station is not in the stations table. you shouldn't need this if weather_data depends on stations
			if station_record.nil?
				erb :index, :layout => :layout, :locals => {:station => nil,
																										:matching_observation => nil}
			else
				# and this one is for queries with an id in the stations table, but nothing in the weather_data table. example of this?
				station = Station.from_table(station_record)

				erb :index, :layout => :layout, :locals => {:station => station,
																									:matching_observation => nil
																									}
			end

		else
			# this is for when you have a station AND observation match, but only some of the data is missing. the page view tells you that
			# my_station = matching_observation.station

			# station_to_match_data = Observation.from_table(station_to_match)
			
# this is making sure temp, dewpoint and weather conditions coded are present in the query station. can you find this out while querying the db? and, do you? at least if you'd like to display what data you actually have for the user
			if matching_observation.temp.nil? || matching_observation.dewpoint.nil? || matching_observation.weather_primary_coded.nil? ||
				matching_observation.wind_kph.nil? || matching_observation.wind_direction.nil?

				erb :index, :layout => :layout, :locals => {:matching_observation => matching_observation,
																										:observation_values => nil,
																										:station => station,
																										:matched_stations_to_display => []}
			else
				
				all_matches = matching_observation.find_matches('2015-07-02 00:00:00', '2015-07-02 02:00:00')
				# i put the time check inside find_matches. is that better than having it here? yes. you want to remove as much logic as possible
				# from your controller file

				unless all_matches.nil?
					checked_for_distance = all_matches.reject do |ea|
						station_to_check = Station.from_table(ea)
						station_to_check.too_close?(matching_observation.station)
					end
					
					# should make sure this also picks the most recent observation, in case there are 2 or more observations that fall within the window
					# can you do a query that returns the most recent observation from the db? yes, but if it's not going to make a huge difference in the amount of data coming from the db then you can filter after the query is finished
					# you may not need this uniq call once you get past those initial duplicate rows
					checked_for_distance.uniq! { |match| match[:station_id] }

					matched_observations_to_display = checked_for_distance.map do |ea|
						Observation.from_table(ea)
					end

					scores_hash = {}

					matched_observations_to_display.map do |ea|

						temp = ea.temp_score(matching_observation.temp)
						dewpoint = ea.dewpoint_score(matching_observation.dewpoint)
						humidity = ea.humidity_score(matching_observation.humidity)
						wind_kph = ea.wind_kph_score(matching_observation.wind_kph)

						total_score = (temp + dewpoint + humidity + wind_kph)/80.0
						percentage = (total_score * 100).round(2)
						scores_hash[ea.station.id] = percentage

					end

					erb :index, :layout => :layout, :locals => {:matching_observation => matching_observation,
																											:matched_observations_to_display => matched_observations_to_display,
																											:scores_hash => scores_hash,
																											:observation_values => "you got some" }
				end
			end

		end

	end


end

get '/location_search' do

	stations_table = DB[:stations]

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