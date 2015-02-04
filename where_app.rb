require "sinatra"
require "json"
# require "./models/stations.rb"
require "./models/stations_practice.rb"
require "byebug"
require "./models/station_name_map.rb"

# this takes an id as an address bar query and prints the conditions on the page, from all_stations.json
# currently only works with a valid id (also can't use just localhost:9393/where_weather)
get '/where_weather' do

	station_id = params[:id] # http://endpoint?id=bla. when you use params[:id] you have to use id= in your query
	station = Station.find(station_id)
	matching_station = find_station(station_id)

	erb :index, :layout => :layout, :locals => { :station => station, 
																							:matching_station => matching_station
																							}

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
  	erb :_data_field, :locals => { :matches => matches }
	end

	first_city = if matches.empty?
		erb :_no_result
	else
		erb :_display_span, :locals => {:first_match => matches.first }
	end

  { :html => content, :first_match => first_city }.to_json

end

# get '/conditions' do

#   content_type :json
#   query = params[:query]

#   matching_city = LOCATIONS.find do |ea| # don't need to specify matches.first cuz find returns the first that is true
# 		next if ea[:city].nil?
# 		ea[:city].start_with?(query)
#   end

# 	station_to_match = matching_city[:station].downcase # this gives you the station id as a lowercase string
# 	current_conditions_for_station = find_station(station_to_match) # this works but need to put in an if nil? statement

# 	conditions = erb :_display_conditions, :locals => { :current_conditions_for_station => current_conditions_for_station }
# 	{ :conditions => conditions }.to_json

# end

# takes city name input, finds it in LOCATIONS, returns the matching station id, then uses that id in the all_stations.json file
# to return the conditions
# locations = [ {city, region, country, station}, {city, region, country, station}, ... ]

# current issues:
	# delay in drop down display on keyup
	# can't use enter to escape user input field
	# also the keyup access from the station file is super slow. it's the js i think?
	# add units to current conditions
	# query with city name, not just station id

# you can either have it match to the station name you're typing into the address bar (which might be easier), or it will be
# (eventually, in any event) matched through the input field, which is city_name -> matched to station_id -> matched to conditions

# :layout => false  # don't seem to need this specified in this version of Sinatra

# where_app needs to access all_stations.json
# needs to look for a matching station id, then return the observation values
# this is a get, right? cuz you're not changing any values, you're just looking them up

# get the page to access state and country data that you've previously stored
# to display results for the user query somewhere on the page
# you get the city name, then match it to the station. is the station available in that same data you're using to get the pretty name?

# the data acquisition will happen independently of the web page
# now use the user input to look up a station id in the api
# create a ruby script that will generate a json file from the csv data. but you want it to come out in the below
# format so you can use your location_search code. and this is all the data you want for now.
# now i would like it to return observations from the api
# so what you'd need to have happen is the user puts in the name of a city. that name is sent to the server, and you'll now want it
# to match to a station id. then that id should be used to make a request to the api for the conditions for that city.
# the matching is also going to have to become a regex type search because no one's going to type in an exact match. but first start
# off once again with the preset location list
# so it goes: enter city -> city name is sent to server -> that name is used to locate the station id in the hash -> that id is
# returned as data to the method that creates the request for the api ("data") -> that request is sent to the api for the current
# conditions -> then you use the <%= %> thing to put that data into the html.

# find the station id closest to that name
# find the current conditions for that station
# find matches for those conditions
# list the matches, their conditions, and where they are in the world