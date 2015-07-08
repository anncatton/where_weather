require 'pg'
require 'sequel'
require 'byebug'
require 'json'
require './models/edited_cities_map.rb'

# ruby script to populate sql tables

DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')

stations = DB[:stations]
observations = DB[:weather_data]

# this inserts the values from LOCATIONS into the stations table
# table shouldn't be a parameter, it should be a variable inside the method because it will make it easier to modify the code to take a different data source in future, if necessary
def insert_into_stations(station, table)
	table.insert(:name => station[:city], :region => station[:region], :country => station[:country], :id => station[:station], :longitude => station[:longitude].round(2), :latitude => station[:latitude].round(2))
end

LOCATIONS.each do |ea|
	insert_into_stations(ea, stations)
end

# this was to take the lat/long numbers from the parsed json file and put them into the LOCATIONS array, because this is permanent data
# new_locations_array = LOCATIONS.each do |ea|

# 	match = STATION_KEYS[ea[:station].downcase]
# 	next if match.nil?
# 	ea[:latitude] = match["latitude"]
# 	ea[:longitude] = match["longitude"]

# end
                                              
# File.open('./models/edited_cities_map.rb', 'w') { |f| f.write(new_locations_array) }

# this parse json method is just old and needs to be removed!
def parse_json_file(filename)

	with_downcased_keys = {}

	File.open(filename, "r") do |f|
		json_file = f.read
		parsed_file = JSON.parse(json_file)

		parsed_file.each do |k,v| 
			with_downcased_keys[k.downcase] = v
		end
	end

	with_downcased_keys

end

# again, get table out as a parameter and set inside the method as a variable to make future modifications easier
def insert_into_weather_data(station, table)
		table.insert(:station_id=>station["id"], :time=>station["time"], :temp=>station["temp"], :dewpoint=>station["dewpoint"], :humidity=>station["humidity"], :conditions=>station["conditions"], :weather_primary_coded=>station["weather_primary_coded"], :clouds_coded=>station["clouds_coded"], :is_day=>station["is_day"], :wind_kph=>station["wind_kph"], :wind_direction=>station["wind_direction"])
end

# do a database query in station_list to check for that station id (that's coming from the json file), and if it's not there, skip it

# parsed_data = parse_json_file("./weather_data/all_stations.json")

# # so is this - ids - like a method that only runs once it's called?
# ids = station_list.map(:id)

# parsed_data.map do |ea|
# 	next if !(ids.include? ea[0].upcase)
# 	insert_into_weather_data(ea[1], observations)
# end