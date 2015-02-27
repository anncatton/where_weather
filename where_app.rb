require "sinatra"
require "json"
require "./models/stations_practice.rb"
require "byebug"
require "./models/edited_cities_map.rb"
require "time"

get '/' do
	redirect to('/where_weather')
end

get '/where_weather' do

	# hash of station hashes, main station keys (k) lowercase
	station_hash = parse_json_file("./weather_data/all_stations.json") 

	# makes an array of Station instances
	stations_to_compare = station_hash.map do |k, v|
		Station.from_json(v)
	end

	valid_stations = stations_to_compare.reject do |ea|
		ea.not_valid?
	end


	if params.empty? # this doesn't currently help when you load page without a query attached in the address bar. guess you'll have to
		# load it with an autoip query maybe? also _results_view has an if/else to handle matching_station being nil
		erb :index, :layout => :layout, :locals => { :matching_station => nil,
																								:locations_match => nil }
	else
		station_id = params[:id]
		matching_station = find_station(station_id)
		locations_match = LOCATIONS.find do |ea|
			ea[:station].downcase == station_id.downcase		
		end
		
		station = Station.from_json(matching_station)
		matches = valid_stations.select do |ea|
			ea != station && !station.too_close?(ea) && station.matches?(ea)
		end

		def find_pretty_match_station(station_to_match)
			match = LOCATIONS.find do |ea|
				match = ea[:station] == station_to_match.id
				match
			end

			match
		end

		erb :index, :layout => :layout, :locals => { :matching_station => matching_station,
																								:locations_match => locations_match,
																								:matches => matches }
	end

end

# this populates the drop down with full location name using input from the user and matching with data from LOCATIONS
get '/location_search' do

  content_type :json
  query = params[:query]

  matches = LOCATIONS.select do |ea|
		next if ea[:city].nil?
		ea[:city].downcase.start_with?(query.downcase)
  end

  content = if matches.empty?
  	erb :_no_result
	else
  	erb :_data_field, :layout => false, :locals => { :matches => matches }
	end

	first_city = if matches.empty?
		erb :_no_result
	else
		erb :_display_span, :layout => false, :locals => {:first_match => matches.first }
	end

  { :html => content, :first_match => first_city }.to_json

end