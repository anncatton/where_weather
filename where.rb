require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"

# can you combine APIs? just to get a larger amount of data?

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
# my_uri = 'http://api.aerisapi.com/observations/pe,ca?client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx'

open(my_uri) do |f|

	json_string = f.read
	parsed_json = JSON.parse(json_string)

	weather = parsed_json['response']['ob']['weatherShort']
	city_name = parsed_json['response']['place']['name']
	tempC = parsed_json['response']['ob']['tempC']
	humidity = parsed_json['response']['ob']['humidity']
	dewpointC = parsed_json['response']['ob']['dewpointC']
	feelslikeC = parsed_json['response']['ob']['feelslikeC']

	puts city_name.capitalize
	puts weather
	puts tempC.to_s + " C"
	puts humidity.to_s + " %"
	puts dewpointC.to_s + " C"

end


# so now, what do you need to do?

# 	- get data on several cities. when do you need to get the data? how many cities will you look for?

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


