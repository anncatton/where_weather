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
DB.loggers << Logger.new($stdout)

get '/' do
	redirect to('/where_weather')
end

get '/where_weather' do
 
#  DB[:items].left_outer_join(:categories, :id => :category_id).sql 
# # SELECT * FROM items
# # LEFT OUTER JOIN categories ON categories.id = items.category_id

# DB[:items].join(:categories, :id => :category_id).join(:groups, :id => :items__group_id) 
# # SELECT * FROM items
# # INNER JOIN categories ON categories.id = items.category_id
# # INNER JOIN groups ON groups.id = items.group_id

	stations_table = DB[:stations]
	observations_table = DB[:weather_data]
	stations_and_observations_join = stations_table.join(observations_table, :station_id => :id)

	def time_threshold
		current_time = Time.parse("2015-04-20T10:19:00-04:00")
		current_time - 3600
	end
	
	def find_station_observation(station_id) # this finds the record in observations that is within the time window (the last 60min)
		observations = DB[:weather_data]
		time_to_compare = time_threshold
		# do i need the upcase call on station_id here?
		matching_observation = observations.where{time >= (time_to_compare - 3600)}.where(:station_id => station_id.upcase).first
		matching_observation
	end

def find_station_observation_new(station_id)
	stations_table = DB[:stations]
	observations_table = DB[:weather_data]
	stations_and_observations_join = stations_table.join(observations_table, :station_id => :id)
	time_to_compare = time_threshold
	matching_observation = stations_and_observations_join.where{time >= (time_to_compare - 3600)}.where(:station_id => station_id.upcase).first
	matching_observation
end

	# sample2 = find_station_observation_new('CYYZ')
	# sample1 = stations_and_observations_join.where(:station_id=>'CYYZ').all # sample1 is a hash that has data from both observations and stations
	# # tables for one location, in this case, CYYZ. however, it doesn't yet discriminate between observation times so it probably isn't choosing the correct observation time. it's actually choosing the first one because that's what you asked it to do, and that'll be the oldest observation
	# byebug

	# new_station = Station.new(sample1[:station_id], sample1[:name], sample1[:region], sample1[:country], sample1[:latitude], sample1[:longitude])
	# new_observation = Observation.new(sample1[:station_id], sample1[:time], sample1[:temp], sample1[:dewpoint], sample1[:humidity], sample1[:conditions], sample1[:weather_primary_coded], sample1[:clouds_coded], sample1[:is_day], sample1[:wind_kph], sample1[:wind_direction])

	if params.empty?
		erb :index, :layout => :layout, :locals => { :matching_station => nil,
																								:locations_match => nil,
																								:station => nil }
	else

		station_id = params[:id]
		station_to_match = find_station_observation_new(station_id)
		byebug
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
# # this is making sure temp, dewpoint and weather conditions coded are present in the query station. can you find this out while querying the db?
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

				final_matches = matches_within_window.select do |ea|
					matches = match_ids.include?(ea[:station_id])
					matches
				end

# is there a way to save this particular record just by referring to the db id number (not the station id) in the observations table? then you could just save it and plug it in when you need it again, as it's a unique record.
				match_observations = final_matches.map do |ea|
					# maybe you can somehow run the match display inside this method?
					# you need to somehow save the score for and attach it to the station id
					observation = Observation.from_table(ea)
					temp = observation.temp_score(station_to_match_data.temp)
					dewpoint = observation.dewpoint_score(station_to_match_data.dewpoint)
					humidity = observation.humidity_score(station_to_match_data.humidity)
					wind_kph = observation.wind_kph_score(station_to_match_data.wind_kph)

					total_score = (temp + dewpoint + humidity + wind_kph)/80.0
					(total_score * 100).round(2)
					
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