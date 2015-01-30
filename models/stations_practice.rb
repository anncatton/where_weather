require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"
# require "haversine"
require "fileutils"
# require "csv"
# require "./models/station_name_map.rb"

class Station

	attr_reader :id, :city, :state, :country

	def initialize(id, city, state, country)
		@id = id
		@city = city
		@state = state
		@country = country
	end

	def self.from_hash(hash)

		self.new(
		hash[:station],
		hash[:city],
		hash[:region],
		hash[:country]
		)

	end

# this writes the pretty name from LOCATIONS to 'Current Conditions for'
# maybe add an if_nil? option so you don't get the 'no method for nilClass'
	def self.find(station_id)
		match = LOCATIONS.find do |ea|
			station_id.downcase == ea[:station].downcase
		end

		self.from_hash(match)
	end

end

# this finds the station id in the json conditions file, 
# find matching key(id), return the conditions
def find_station(station_id)

	File.open("./weather_data/all_stations.json", "r") do |f| # this needs a relative path name to work, but where_app gets upset
		# when i run it with the relative path - when i call find_station in where_app, i need to use './' not '../'
		json_file = f.read
		parsed_file = JSON.parse(json_file)
		with_downcased_keys = {}
		parsed_file.each { |k,v| with_downcased_keys[k.downcase] = v}

		with_downcased_keys[station_id.downcase]
	end

end
