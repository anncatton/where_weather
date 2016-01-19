require 'pg'
require 'sequel'
require 'byebug'
require './models/edited_cities_map.rb'

# DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')
# DB = Sequel.connect('postgres://anncatton:@localhost:5432/heroku_weather')

stations_table = DB[:stations]

def insert_into_stations(station, table)

	table.insert(:name => station[:city], 
		:region => station[:region], 
		:country => station[:country], 
		:id => station[:station], 
		:longitude => station[:longitude].round(2), 
		:latitude => station[:latitude].round(2))

end

LOCATIONS.each do |ea|
	insert_into_stations(ea, stations_table)
end

def insert_into_weather_data(station)

	observations_table = DB[:weather_data]

	observations_table.insert(:station_id=>station["id"],
	 :time=>station["time"], :temp=>station["temp"],
	 :dewpoint=>station["dewpoint"],
	 :humidity=>station["humidity"],
	 :conditions=>station["conditions"], 
	 :weather_primary_coded=>station["weather_primary_coded"], 
	 :clouds_coded=>station["clouds_coded"], 
	 :is_day=>station["is_day"], 
	 :wind_kph=>station["wind_kph"], 
	 :wind_direction=>station["wind_direction"])

end