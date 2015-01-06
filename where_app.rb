require "sinatra"
require "json"
# require "./models/stations.rb" # - requiring this slows localhost down by almost 10s. it's the build_station_name_map method
require "byebug"
require "./models/station_name_map.rb"

get '/where_weather' do

	erb :index, :layout => :layout

end

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

# get '/location_search' do
post '/location_search' do

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

  { :html => content }.to_json # this is what is returned as 'data' in the jquery code. using .select, this will be an array
end