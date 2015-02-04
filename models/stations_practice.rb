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
		# if match.nil?
		# 	do something - what would be a good rescue here?
		# else
		# 	self.from_hash(match)
		# end
	end

end

# this finds a station id in the json conditions file, 
def find_station(station_id)

	File.open("./weather_data/all_stations.json", "r") do |f|
		json_file = f.read
		parsed_file = JSON.parse(json_file)
		with_downcased_keys = {}
		parsed_file.each do |k,v| 
			with_downcased_keys[k.downcase] = v
		end

		with_downcased_keys[station_id.downcase]
	end

end