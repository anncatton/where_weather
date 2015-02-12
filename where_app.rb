require "sinatra"
require "json"
# require "./models/stations.rb"
require "./models/stations_practice.rb"
require "byebug"
require "./models/location_id_map.rb"

# this takes an id as an address bar query and prints the conditions on the page, from all_stations.json
# currently only works with a valid id (also can't use just localhost:9393/where_weather)
get '/where_weather' do

	if params.empty?
		erb :index, :layout => :layout, :locals => {
			#:station => nil,
																								:matching_station => nil }
	else
		station_id = params[:id] # this variable contains the string entered into the web page for the 4-letter station id
		# station = Station.find(station_id) # this is creating a new instance of station
		matching_station = find_station(station_id) # this will find the corresponding station inside all_stations.json, so
		# matching_station will hold a hash containing city name and current conditions key value pairs

		erb :index, :layout => :layout, :locals => {
			#:station => station,
																							:matching_station => matching_station }
	end

end

# this displays the full location name using input from the user and matching with data from LOCATIONS in station_name_map file
get '/location_search' do # both get and post work. which should i use?
# '/location_search' is an endpoint, not a url. what's the difference?

  content_type :json
  query = params[:query]

  matches = LOCATIONS.select do |ea|
		next if ea[:city].nil?
		ea[:city].start_with?(query)
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
	# i think now you've broken it enough that conditions from the input station aren't displaying anymore
	# and you don't have the name of the selected city in the current conditions div
	# and because the drop down is not being populated by LOCATIONS, you can't select a link to put a station in params to query
	# can't use enter to blur user input field
	# you've got a lot of dud matches being created from that csv file. also you're not going to need 15 different
	# matches for big centers, just pick a main station id for those big cities (like toronto, or paris, or whatever). Eventually
	# you can worry about having more coverage within cities. right now you have about 4700 stations in the conditions file, and just
	# under 28000 in the LOCATIONS array
	# change search from start_with? to include? - do i want this, actually? i think that gives too many unnecessary results
	# make case-insensitive
	# be able to load main page without a query attached
	# 
# the data acquisition will happen independently of the web page
# find matches for those conditions
# list the matches, their conditions, and where they are in the world