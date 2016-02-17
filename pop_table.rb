require 'pg'
require 'sequel'
require 'byebug'
require './models/edited_cities_map.rb'

# DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')
DB = Sequel.connect('postgres://anncatton:@localhost:5432/heroku_weather')

stations_table = DB[:stations]

def insert_into_stations(station, table)

	table.insert(name: station[:city], 
		region: station[:region], 
		country: station[:country], 
		id: station[:station], 
		longitude: station[:longitude].round(2), 
		latitude: station[:latitude].round(2))

end

LOCATIONS.each do |ea|
	insert_into_stations(ea, stations_table)
end