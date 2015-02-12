require "sinatra"
require "json"
# require "./models/stations.rb"
require "./models/stations_practice.rb"
require "byebug"
require "./models/location_id_map.rb"

get '/where_weather' do

		station_id = params[:id]
		matching_station = find_station(station_id)
		locations_match = LOCATIONS.find do |ea|
			ea[:station] == station_id			
		end

		erb :index, :layout => :layout, :locals => { :matching_station => matching_station,
																								:locations_match => locations_match }

end

# canon pixma pro-100
# this displays the full location name using input from the user and matching with data from LOCATIONS
get '/location_search' do
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