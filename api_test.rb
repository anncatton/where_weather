require 'open-uri'
require 'json'

# this gets all this data with one request. now how would you design it so that it found several locations at once?

open('http://api.wunderground.com/api/905ae13579633139/geolookup/conditions/q/CA/San_Francisco.json') do |f|
  json_string = f.read
  # does this set parsed_json to be a instance fo JSON that you call parse on, with read value of f as the argument
  # or is this just a conventional way of writing something and i shouldn't think abotu it so hard?
  parsed_json = JSON.parse(json_string)
  # could you define all these variables with one line?
  location = parsed_json['location']['city']
  temp_f = parsed_json['current_observation']['temp_f']
  temp_c = parsed_json['current_observation']['temp_c']
  rel_humidity = parsed_json['current_observation']['relative_humidity']
  feelslike_c = parsed_json['current_observation']['feelslike_c']
  dewpoint_c = parsed_json['current_observation']['dewpoint_c']
  station_id = parsed_json['current_observation']['station_id']
  # here, 'full' is inside hash 'display_location', which is inside hash 'current_observation'
  display_city = parsed_json['current_observation']['display_location']['full']
  # so, we're getting the value of the key, 'full', inside a hash 'display_location'
# so are the above like writing current_observation.temp_f ? for example?
	puts "The location is #{display_city}"
  puts "This data comes from Station No. #{station_id}:"
  puts "Current temperature in #{location} is: #{temp_f}F, #{temp_c}C."
  puts "The relative humidity is #{rel_humidity}, and the dew point is #{dewpoint_c}."
  puts "So it feels like #{feelslike_c}."
end

# standard format:

# GET http://api.wunderground.com/api/Your_Key/features/settings/q/query.format

# what's the difference between open and get? when would i use them?


Note: This functionality is similar to the closest search but is faster as it does not include a distance or sorting.
/observations/within?p=45.25,-95.25&radius=50

this might involve too much data, but you could search each value separately, and then compare the places returned in 
those arrays and see which locations match. so, you could have an array for temp, dewpoint, conditions and humidity, then
compare the cities that match for those values.
- also, you could be really lazy and just use conditions(sunny, rainy, etc) and feels like temp, as i'm assuming that that measurement would
include temp + dewpoint/humidity. if you can, check how each weather site creates their feels like temp.

later on you can add wind speed and direction, as well as gusts