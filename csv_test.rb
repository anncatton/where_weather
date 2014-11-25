require "csv"

station_csv = CSV.read('./stations.csv', :encoding => 'windows-1251:utf-8', :headers => true)

station_names = station_csv.map do |ea|
	ea.to_hash
end

station_names.each do |ea|
	unless ea['icao'].nil?
		puts "The station code is #{ea['icao']} for #{ea['city']}, #{ea['region']}."
	end
end