require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"
require "haversine"
require "fileutils"
require "csv"
require "./models/station_name_map.rb"

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
# so you want station_id to match to the same id in LOCATIONS
	# def self.find(station_id)
	# 	Station.from_hash(LOCATIONS.first)
	# end

	def self.find(station_id)
		# byebug
		match = LOCATIONS.find do |ea|
			station_id == ea[:station]
		end

		self.from_hash(match)
		#if station_id == Station[:station]
	end

end