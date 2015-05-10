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
	
	def find_station_observation(station_id)
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
		# this uses a db query to filter out observations that aren't recent enough
		if station_to_match.nil?
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
				all_matches = station_to_match_data.find_matches # an array of hashes from observations table. not yet Observation instances

				matches_within_window = all_matches.reject do |ea|
					time_to_compare = time_threshold
					Time.parse(ea[:time]) <= time_to_compare
				end

				all_matches_in_stations_table = matches_within_window.map do |ea| # all_matches_in_stations_table is data from stations
					stations_table.where(:id=>ea[:station_id].upcase).first
				end

		# this shouldn't be necessary if you add the foreign key reference back into weather_data
				valid_matches = all_matches_in_stations_table.reject do |ea|
					ea.nil?
				end

				match_stations_data = valid_matches.map do |ea|
					Station.from_table(ea)
				end
				
				matches_not_too_close = match_stations_data.reject do |ea|
					too_close?(ea, station)
				end

				# matches = all_matches.map do |ea| # only if you need to display the weather conditions of the matches
				# 	Observation.from_table(ea)
				# end

				erb :index, :layout => :layout, :locals => {:station_to_match_data => station_to_match_data,
																										:station => station,
																										:station_to_match => station_to_match,
																										:matches_to_display => matches_not_too_close }
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