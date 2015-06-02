require "haversine"
require "byebug"

class Station # should station class reflect only the data that's stored in the stations table, that is basically permanent data about
	# each station? has nothing to do with the weather data, which will change constantly and be associated with a station id

	attr_reader :id, :city, :region, :country, :latitude, :longitude

	def initialize(id, city, region, country, latitude, longitude)
		@id = id
		@city = city
		@region = region
		@country = country
		@latitude = latitude
		@longitude = longitude
	end

	def self.from_table(hash)
		self.new(
			hash[:id],
			hash[:name],
			hash[:region],
			hash[:country],
			hash[:latitude],
			hash[:longitude]
			)
	end

def too_close?(query_station)
	distance = Haversine.distance(query_station.latitude, query_station.longitude, self.latitude, self.longitude)
	distance.to_km < 2000
end

end
