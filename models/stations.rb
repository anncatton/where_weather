require "byebug"

# have a script that gets the json data
# have a model file for Station class

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

	def self.from_stations_table(hash)
		self.new(
			hash[:id],
			hash[:name],
			hash[:region],
			hash[:country],
			hash[:latitude],
			hash[:longitude]
			)
	end

end
