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
# need to make your hash format consistent (where you're placing your curly braces)
		erb :index, :layout => :layout, :locals => {:matching_observation => nil}

	else

		matching_observation = Observation.match_in_timeframe(station_id, '2015-07-05 21:55:00', '2015-07-05 23:55:00')

		if matching_observation.nil?
		# for error when there's no matching observation within the current timeframe (not recent enough), or if there's no observation at all for the queried station (like you found with CYXD). however, this page view doesn't tell the user why there's no results showing.

			station_record = DB[:stations].where(:id=>station_id.upcase).first

# this one is if the station is not in the stations table. but if weather_data depends on stations table then you shouldn't need this if clause because there shouldn't be a station id in weather_data that isn't already in stations
			if station_record.nil?
				erb :index, :layout => :layout, :locals => {:station => nil, # this is no longer referenced in the partials, can be removed
																										:matching_observation => nil}
			else
				# and this one is for queries with an id in the stations table, but without a relevant observation in weather_data table.
				station = Station.from_table(station_record)

# right now you don't have a reference to station in any of the partial views, so either make one or remove it from this hash.
				# could add a note telling the user there are no relevant observations for the station they've entered, and use this station variable to mention the location by name
# right now your index page doesn't do anything when matching_observation is nil, it just shows the home page
				erb :index, :layout => :layout, :locals => {:station => station,
																									:matching_observation => nil
																									}
			end

		else
			# this is for when you have a station AND observation match, but only some of the data is missing. the page view tells you that		
# this is making sure temp, dewpoint and weather conditions coded are present in the query station. could this be done when querying the db? it would be better if it could, kinda ugly here
			if matching_observation.temp.nil? || matching_observation.dewpoint.nil? || matching_observation.weather_primary_coded.nil? ||
				matching_observation.wind_kph.nil? || matching_observation.wind_direction.nil?
# don't need station here as a local because that data would be inside matching_observation
# i've made up a variable called observation_values to set to nil in the case of the an observation that is missing some values, but maybe you could rename it to be more obvious about what it means? because you just want to be able to tell the user you're missing some key values
				erb :index, :layout => :layout, :locals => {:matching_observation => matching_observation,
																										:observation_values => nil,
																										:station => station,
# :matched_stations_to_display doesn't get used anywhere so should be removed
																										:matched_stations_to_display => []}
			else
				
				all_matches = matching_observation.find_matches('2015-07-05 21:55:00', '2015-07-05 23:55:00')

				# need an if all_matches.nil? so you can tell the user there's no current matches for their query
				# andy mentioned that too close could eventually be permanently stored info
				unless all_matches.nil?
					checked_for_distance = all_matches.reject do |ea|
						station_to_check = Station.from_table(ea)
						station_to_check.too_close?(matching_observation.station)
					end
					
					# should make sure this also picks the most recent observation, in case there are 2 or more observations that fall within the window (some stations update more often than once an hour)
					# can you do a query that returns the most recent observation from the db? yes, but if it's not going to make a huge difference in the amount of data coming from the db then you can filter after the query is finished
					# you may not need this uniq call once you get past those initial duplicate rows
					# also, how does uniq! choose? does it just pick the first record it finds? not sure this is good because i don't know what on basis the method chooses a record from 2 or more, seems like just a quick fix that could have unreliable results. kinda lazy
					checked_for_distance.uniq! { |match| match[:station_id] }

# put this Observation.from_table call into the next part where you make the scores_hash, so there's one less step
# or, do you need matched_observations_to_display for the index view? (does it need to be its own variable?) 
					matched_observations_to_display = checked_for_distance.map do |ea|
						Observation.from_table(ea)
					end

					scores_hash = {}

					matched_observations_to_display.map do |ea|

# do you need to assign each category score to its own variable?
# was also thinking of putting this whole thing a separate method inside observation.rb
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
# this is not a good solution to making !(observation_values.nil?). cute, but should be more logical
																											:observation_values => "you got some" }
				end
			end

		end

	end


end

get '/location_search' do

# don't need to set this as a variable, it's not used enough
	stations_table = DB[:stations]

  content_type :json
  query = params[:query]

  matches = stations_table.where(Sequel.ilike(:name, query+'%'))

  content = if matches.empty?
  	erb :_no_result, :layout => false
	else
# rename _data_field partial, too generic sounding. maybe _drop_down_field?
  	erb :_data_field, :layout => false, :locals => { :matches => matches }
	end

 { :html => content }.to_json

end