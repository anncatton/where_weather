require "sinatra"
require "json"
require "./models/stations_practice.rb"
require "byebug"
require "./models/location_id_map.rb"

get '/where_weather' do

	# hash of station hashes, main station keys (k) lowercase
	station_hash = parse_json_file("./weather_data/all_stations.json") 

	# makes an array of Station instances
	stations_to_compare = station_hash.map do |k, v|
		Station.from_json(v)
	end

	valid_stations = stations_to_compare.reject do |ea|
		ea.not_valid?
	end

	station_id = params[:id]
	matching_station = find_station(station_id)
	locations_match = LOCATIONS.find do |ea|
		ea[:station] == station_id			
	end
	
	station = Station.from_json(matching_station)
	matches = valid_stations.select do |ea|
		ea != station && !station.too_close?(ea) && station.matches?(ea)
	end

	def find_pretty_match_station(station_to_match)
		LOCATIONS.find do |ea|
			match = ea[:station] == station_to_match.id
			match
		end
	end

	if params.empty? # this doesn't currently help when you load page without a query attached in the address bar. guess you'll have to
		# load it with an autoip query maybe? also _results_view has an if/else to handle matching_station being nil
		erb :index, :layout => :layout, :locals => { :matching_station => nil,
																								:locations_match => nil }
	else
		erb :index, :layout => :layout, :locals => { :matching_station => matching_station,
																								:locations_match => locations_match,
																								:matches => matches }
	end

end

# this populates the drop down with full location name using input from the user and matching with data from LOCATIONS
get '/location_search' do

  content_type :json
  query = params[:query]

  matches = LOCATIONS.select do |ea|
		next if ea[:city].nil?
		ea[:city].downcase.include?(query.downcase)
  end

  content = if matches.empty?
  	erb :_no_result
	else
  	erb :_data_field, :layout => false, :locals => { :matches => matches }
	end

	first_city = if matches.empty?
		erb :_no_result
	else
		erb :_display_span, :layout => false, :locals => {:first_match => matches.first }
	end

  { :html => content, :first_match => first_city }.to_json

end

# current issues:
	# figure out what to do with data coming from LOCATIONS - like when [:region] is nil, or "-", and so on
	# which methods that you have running in where_app could be put in stations_practice.rb, to tidy this file up?
	# limit matches within a certain area (i.e., you don't want 5 from one state in the US)
	# are you going to have to check every station id - location against wunderground's? use lat/long coords?
	# be able to access drop down results with arrow keys and enter
	# find nearby stations for locations that don't have a station id
	# still have some of the locations displaying funky characters
	# still have location names that are exactly the same, but with different ids, coming from LOCATIONS
	# can't use enter to blur user input field
	# change search from start_with? to include? - possibly gives too many results. not so
		# bad now that you've cleaned up LOCATIONS
	# be able to load main page without a query attached???
	# use lat/long to map locations on a globe graphic
	# how to discover which stations are missing?
	# compare station ids and reject the ones that match. couldn't find any non-matches
	# csv = 4588
	# json = 4624 (+36)
# the data acquisition will happen independently of the web page
# list the matches, their conditions, and where they are in the world