require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"

# can you combine APIs? just to get a larger amount of data?

	# url = 'http://api.aerisapi.com/observations/seattle,wa,us?client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx'
	# buffer = open(url, "UserAgent" => "Ruby-Wget").read
	# the "UserAgent" => "Ruby-Wget" - is this the kind of thing i can not worry about completely understanding, because it's just how
	# their api works and all i need to do is plug it into my code, and not get too caught up in the bits and pieces?
	# looks like it's calling .read on a kind of File.open - although this is a url. but is that the basic concept?
	# also, why did they call it buffer? probably cuz its the segue between json and ruby

	#convert JSON data into a hash
	# response = JSON.parse(buffer)
	# does the above line make the server response - which i think is in json - readable by Ruby?
	# so when you call parse on JSON you get a hash?
	# ob = response['response']['ob']
	# print "The current weather in Seattle is " + ob['weather'].downcase + ' with a temperature of ' + ob['tempC'].to_s() + "\n"

	# url = 'http://api.aerisapi.com/observations/94107?client_id=yotRMCnX8QTlcpwPx71pg&client_secret=H2Nx8mcIPgZtCBLCV2KRPnh4T6n8LiIXejDMGgQx'
	# buffer = open(url, "UserAgent" => "Ruby-Wget").read
	# response = JSON.parse(buffer)


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

puts my_uri

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

# from rubydocs:

# build(args)

# Create a new URI::HTTP object from components, with syntax checking.

# The components accepted are userinfo, host, port, path, query and fragment.

# The components should be provided either as an Array, or as a Hash with keys formed by preceding the component names with a colon.

# If an Array is used, the components must be passed in the order [userinfo, host, port, path, query, fragment].

# Example:

# newuri = URI::HTTP.build({:host => 'www.example.com',
#   :path => '/foo/bar'})

# newuri = URI::HTTP.build([nil, "www.example.com", nil, "/path",
#   "query", 'fragment'])
# uri = URI::HTTP.build(:host => "www.google.com", :query => { :q => "test" }.to_query)


	# so country is set to be the value of key 'place' inside key 'response'

	# is this again a hash within a hash? yes. is that just standard json data format? yes

	# so i guess their keys are in string form although they use a : in between key-value pairs? is that a shortened version of key => key-value
	# with symbols? yes. format is key: value

# this is the example response (on success) from aeris
# but why are they writing it as a string and symbol? as in, "state": "wa"
# because this is json, not ruby. json responses come in the form of strings

# how to get observations:

# url = http://api.aerisapi.com/observations/PLACE_ID

# 'response' is the main hash
# 	=> then 'ob'
# 		=> then 

# 		"ob": {
#     "timestamp": 1408643580,
#     "dateTimeISO": "2014-08-21T12:53:00-05:00",
#     "tempC": 28,
#     "tempF": 82,
#     "dewpointC": 22,
#     "dewpointF": 72,
#     "humidity": 70,
#     "pressureMB": 1007,
#     "pressureIN": 29.74,
#     "spressureMB": 977,
#     "spressureIN": 28.85,
#     "altimeterMB": 1008,
#     "altimeterIN": 29.77,
#     "windKTS": 7,
#     "windKPH": 13,
#     "windMPH": 8,
#     "windSpeedKTS": 7,
#     "windSpeedKPH": 13,
#     "windSpeedMPH": 8,
#     "windDirDEG": 140,
#     "windDir": "SE",
#     "windGustKTS": null,
#     "windGustKPH": null,
#     "windGustMPH": null,
#     "flightRule": "MVFR",
#     "visibilityKM": 16.09344,
#     "visibilityMI": 10,
#     "weather": "Mostly Cloudy",
#     "weatherShort": "Mostly Cloudy",
#     "weatherCoded": "::BK",
#     "weatherPrimary": "Mostly Cloudy",
#     "weatherPrimaryCoded": "::BK",
#     "cloudsCoded": "BK",
#     "icon": "mcloudy.png",
#     "heatindexC": 30,
#     "heatindexF": 86,
#     "windchillC": 28,
#     "windchillF": 82,
#     "feelslikeC": 30,
#     "feelslikeF": 86,
