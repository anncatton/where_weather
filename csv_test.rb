require "active_support/core_ext/object/to_query.rb"
require "json"
require "open-uri"
require "uri"
require "byebug"
require "haversine"
require "fileutils"
require "csv"

station_csv = CSV.read('./stations.csv', :encoding => 'windows-1251:utf-8', :headers => true)

station_names = station_csv.map do |ea|
	ea.to_hash
end

station_names.each do |ea|
	unless ea['icao_xref'].nil?
		puts "ICAO: #{ea['icao_xref']} for #{ea['city']}, #{ea['region']}, #{ea['country']}."
	end
end
