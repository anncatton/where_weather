require "haversine"
require "byebug"

class Station

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
