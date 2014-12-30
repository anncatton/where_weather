require "sinatra"
require "json"
# require "./models/search.rb"
require "./models/stations.rb"

get '/where_weather' do

	erb :index, :layout => :layout

end

	LOCATIONS = [
		{:city => "Toronto", :region => "Ontario, Canada", :station => "CYYZ"},
		{:city => "Paris", :region => "France", :station => "LFPO" },
		{:city => "Calgary", :region => "Alberta, Canada", :station => "CYYC"},
		{:city => "Loon Lake", :region => "Saskatchewan, Canada", :station => "CYLJ"},
		{:city => "Dallas", :region => "Texas, United States", :station => "KDAL" },
		{:city => "Rome", :region => "Italy", :station => "LIRA"},
		{:city => "Istanbul", :region => "Turkey", :station => "LTBA"},
		{:city => "Copenhagen", :region => "Denmark", :station => "EKCH"},
		{:city => "Mexico City", :region => "Mexico", :station => "MMTO"},
		{:city => "Mumbai", :region => "India", :station => "VABB"},
		{:city => "Vancouver", :region => "British Columbia, Canada", :station => "CYVR"},
		{:city => "Kuala Lumpur", :region => "Malaysia", :station => "WMKK"},
		{:city => "Moscow", :region => "Russia", :station => "UUEE"},
		{:city => "Abu Dhabi", :region => "United Arab Emirates", :station => "OMAA"},
		{:city => "Tokyo", :region => "Japan", :station => "RJTT"},
		{:city => "Monrovia", :region => "Liberia", :station => "GLRB"},
		{:city => "Munich", :region => "Germany", :station => "EDDM"},
		{:city => "New York", :region => "New York, United States", :station => "KNYC"},
		{:city => "San Francisco", :region => "California, United States", :station => "KSFO"},
		{:city => "Brisbane", :region => "Queensland, Australia", :station => "YBAF"},
		{:city => "Halifax", :region => "Nova Scotia, Canada", :station => "CYHZ"},
		{:city => "McMurdo Station", :region => "Antarctica", :station => "AAXX"},
		{:city => "Tabarka", :region => "Tunisia", :station => "DTKA"},
		{:city => "Brasov", :region => "Romania", :station => "LRBG"},
		{:city => "Edinburgh", :region => "Scotland, United Kingdom", :station => "EGPH"},
		{:city => "London", :region => "England, United Kingdom", :station => "EGLL"},
		{:city => "Shanghai", :region => "China", :station => "ZSSS"},
		{:city => "Atalaya", :region => "Peru", :station => "SPAY"}
	]

# now i would like it to return observations from the api
# so what you'd need to have happen is the user puts in the name of a city. that name is sent to the server, and you'll now want it
# to match to a station id. then that id should be used to make a request to the api for the conditions for that city.
# the matching is also going to have to become a regex type search because no one's going to type in an exact match. but first start
# off once again with the preset location list
# so it goes: enter city -> city name is sent to server -> that name is used to locate the station id in the hash -> that id is
# returned as data to the method that creates the request for the api ("data") -> that request is sent to the api for the current
# conditions -> then you use the <%= %> thing to put that data into the html.

get '/location_search' do

  content_type :json
  query = params[:query]
  match = LOCATIONS.select do |ea|
  	ea[:city] == query
  end
  match.to_json # this is what is returned as 'data' in the jquery code
end

# what do you want to happen next? you want the user to put their city into the input (and it will be from a set list). then the
# app sends that input value to the server, which returns some sort of data associated with that value
# so first you want - i think - something on this page to be able to know what the value of the input it. or, is it your jquery
# that is going to see that? cuz you don't want to leave the page
# get '/weather/:city' do
	
# 	city = params[:city]
#   "You're looking for the weather in #{city}. Is this correct?"

# end

# get '/hello/you/?:greeting?/?:name?' do
#   "#{params[:greeting] ? params[:greeting] : "Hello"}, #{params[:name] ? params[:name] : 'world'}!"
# end

# get '/posts' do
#   # matches "GET /posts?title=foo&author=bar"
#   title = params[:title]
#   author = params[:author]
# # end

# get '/sample' do
# 	code = "<%= Time.now %>"
# 	erb code
# end


# params = {
# 	:name => "Ann",
# 	:greeting => "Hi"
# }