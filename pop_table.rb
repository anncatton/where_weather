require 'pg'
require 'sequel'
require 'byebug'
require './models/edited_cities_map.rb'
require './weather_data/parsed_station_file.rb'

# ruby script to populate sql tables

DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')

station_list = DB[:stations]

# this inserts the values from LOCATIONS into the stations table
def insert_values(station, table)

	table.insert(:name => station[:city], :region => station[:region], :country => station[:country], :id => station[:station], :location => "(#{station[:longitude]}, #{station[:latitude]})")
end

LOCATIONS.each do |ea|
	insert_values(ea, station_list)
end

# this was to take the lat/long numbers from the parsed json file and put them into the LOCATIONS array, because this is permanent data
new_locations_array = LOCATIONS.each do |ea|

	match = STATION_KEYS[ea[:station].downcase]
	next if match.nil?
	ea[:latitude] = match["latitude"]
	ea[:longitude] = match["longitude"]

end

File.open('./models/edited_cities_map.rb', 'w') { |f| f.write(new_locations_array) }