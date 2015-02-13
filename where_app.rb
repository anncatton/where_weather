require "sinatra"
require "json"
# require "./models/stations.rb"
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

# canon pixma pro-100
# this populates the drop down with full location name using input from the user and matching with data from LOCATIONS
get '/location_search' do

  content_type :json
  query = params[:query]

  matches = LOCATIONS.select do |ea|
		next if ea[:city].nil?
		ea[:city].downcase.start_with?(query.downcase)
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
	# find nearby stations for locations that don't have a station id
	# still have some of the locations displaying funky characters
	# can't use enter to blur user input field
	# change search from start_with? to include? - do i want this, actually? i think that gives too many unnecessary results
	# make case-insensitive
	# be able to load main page without a query attached
	# 
# the data acquisition will happen independently of the web page
# find matches for those conditions
# list the matches, their conditions, and where they are in the world