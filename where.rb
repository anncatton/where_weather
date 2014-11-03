require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"

# can you combine APIs? just to get a larger amount of data?

	# url = 'http://api.aerisapi.com/observations/seattle,wa,us?client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx'
	# buffer = open(url, "UserAgent" => "Ruby-Wget").read - don't need this, api access works either way. useragent is the browser right?
	# the "UserAgent" => "Ruby-Wget" - is this the kind of thing i can not worry about completely understanding, because it's just how
	# their api works and all i need to do is plug it into my code, and not get too caught up in the bits and pieces?
	# looks like it's calling .read on a kind of File.open - although this is a url. but is that the basic concept?
	# also, why did they call it buffer? probably cuz its the segue between json and ruby

	#convert JSON data into a hash
	# response = JSON.parse(buffer)
	# does the above line make the server response - which i think is in json - readable by Ruby?
	# yes. parse means to take apart and make sense, in whatever language you're using
	# so when you call parse on JSON you get a hash?

	# url = 'http://api.aerisapi.com/observations/94107?client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx'

# Performing a query against a numerical property is handled slightly differently than a string property in that it is an >= - <= operation. If only the first value is provided, then all results whose value for that property is greater than or equal to (>=) the specified value is returned. The following request would return all storm cells that have an 80% probability or higher of containing hail:
# /stormcells/closest?query=ob.hail.prob:80

# If both a minimum and maximum value are provided, then all results whose value for the property is equal to or in between the two values is returned. The following request would return all storm cells closest to the location whose probability of hail is >= 40% and <= 80%:
# /stormcells/closest?query=ob.hail.prob:40:80

my_uri = URI::HTTP.build(
	{
		:host => "api.aerisapi.com", 
		:path => "/observations/toronto,on,ca", 
		:query => {
			:client_id => "yotRMCnX8QTlcpwPx71pg", 
			:client_secret => "H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx"
		}.to_query
	}
)
my_uri = 'http://api.aerisapi.com/observations/search?&query=place.state:wa,ob.tempC:7:9&limit=10&client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx'

http://api.aerisapi.com/places/search?query=place.name:seattle,place.state:wa&client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx

http://api.aerisapi.com/observations/search?query=temp:4,dewpt:2,rh:87&client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx
# /observations/search?query=state:mn&sort=temp:-1
open(my_uri) do |f|

	json_string = f.read
	parsed_json = JSON.parse(json_string)

	#byebug

	weather = parsed_json['response']['ob']['weatherShort']
	city_name = parsed_json['response']['place']['name']
	tempC = parsed_json['response']['ob']['tempC']
	humidity = parsed_json['response']['ob']['humidity']
	dewpointC = parsed_json['response']['ob']['dewpointC']
	feelslikeC = parsed_json['response']['ob']['feelslikeC']
	# country = response['response']['place']['name']
	# print "The weather in " + city + " is " + weather + "."
	puts city_name.capitalize
	puts weather
	puts tempC.to_s + " C"
	puts humidity.to_s + " %"
	puts dewpointC.to_s + " C"

end

now, try to access values from just one of the hashes. they're all in json format, so you'll have to parse them into ruby.
can you parse a whole json file? or should i create a set of smaller hashes with the relevant data and just parse and access
those?
# so now, what do you need to do?

# 	- get data on several cities. when do you need to get the data? how many cities will you look for?
# 	- set up methods that compare values
# 	- can you search based on values, not locations? like, your request will ask, 'find me locations with the same temp.'
# 	- decide on tolerance level for comparison
# 	- try to do this with just one value first (like temp) to simplify

# first, get conditions for user location (and later on, any location the user specifies)
# enter those values into a hash

# query: ['response']['ob']['tempC'] = 7, ['limit'] = 50, radius (for now?)
# limit is a parameter for action

# ideas for the future:

# 	- compare to upcoming weather - 'tomorrow, your weather is more likely to be like Paris than London.'
# 	- compare to favourites or locations within a certain area
# 	- show differences between locations that are geographically quite close
# 	- compare with locations on same latitude
#   - gotta show you where this place is on the globe


