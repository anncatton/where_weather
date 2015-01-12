require "sinatra"
require "json"
# require ".models/stations.rb"
require "./models/stations_practice.rb"
require "byebug"
# require "./models/station_name_map.rb"

get '/where_weather' do

	station_id = params[:id] # http://endpoint?id=bla. when you use params[:id] you have to use id= in your query
	station = Station.find(station_id)

	erb :index, :layout => :layout, :locals => { :station => station } # if erb was a method, locals would be the parameters

end

# get '/location_search' do
# '/location_search' is an endpoint, not a url. what's the difference?
# post '/location_search' do

#   content_type :json
#   query = params[:query]

#   matches = LOCATIONS.select do |ea|
# 		next if ea[:city].nil?
# 		ea[:city].start_with?(query)
#   end

#   content = if matches.empty?
#   	erb :_no_result
# 	else
#   	erb :_data_field, :layout => false, :locals => { :matches => matches }
# 	end

# # if field is empty this still returns the first city in LOCATIONS, which is Adelaide. using matches.empty? doesn't help
# 	first_city = erb :_display_span, :layout => false, :locals => {:first_match => matches.first }

#   { :html => content, :first_match => first_city }.to_json # this is what is returned as 'data' in the jquery code. using .select, this will be an array

# end

# get the page to access state and country data that youve previously stored
# to display results for the user query somewhere on the page
# you get the city name, then match it to the station. is the station available in that same data you're using to get the pretty name?

# now need to get your site to access stored data to find observations for the user query. you can use old data for now.
# the data acquisition will happen independently of the web page
#	http://api.aerisapi.com/observations/halifax,ns,ca?client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx
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
