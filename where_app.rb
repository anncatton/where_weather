require "sinatra"
require "json"
require "./models/stations_practice.rb"
require "byebug"
# require "./models/location_id_map.rb"
require "./models/edited_cities_map.rb"

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

# current issues:
	# will need to add other parameters for comparison - wind speed, gusts, maybe humidity, pressure, visibility. do you think you can
		# lower the minimum distance once you add in these other parameters? maybe not, you still don't want matches that are too nearby
	# i would like to have places with the same conditions but are either night or day show up as matches (which should be
		# happening already because all observations should be in utc), but i would put a note on the match saying its at night or
		# vice versa. i think it's interesting to have the same conditions but different times of day
	# can't really edit data coming from api because you'll be over writing it daily. you can only control what data you're storing
	# some sort of limit on matches from the same province/state. maybe even country if necessary.
	# maybe get rid of region display because i'm not sure how useful it is and most of the data is a bit...ugly looking. or prob
		# won't make sense to most users. although - at least with a lot of us/canada locations, there are lots of places with the same
		# name in the same country, you'd need the state info to differentiate them. you may have to go through the data yourself and check
		# for abbreviations that make sense. a lot of these countries i don't even understand how the provinces are organized
	# figure out what to do with data coming from LOCATIONS - like when [:region] is nil, or "-", and so on
	# which methods that you have running in where_app could be put in stations_practice.rb, to tidy this file up?
	# limit matches within a certain area (i.e., you don't want 5 from one state in the US)
	# are you going to have to check every station id - location against wunderground's? use lat/long coords?
	# still have some of the locations displaying funky characters. i think the "|" removal helped with a lot of that. run an edit that
		# checks for non-letter characters inside [:city]
	# still have location names that are exactly the same, but with different ids, coming from LOCATIONS. you're going to have to 
	# make some decisions about stations that are basically in the same city (like Dallas has 3 stations in the same general area, Denver has 4).
	# if you want to have minimal stations to start with, how do you decide which stations to use?
	# the csv file has a lot of names in the native language. i'd like to start out with the english names, but i also think i'll have to have
	# the native name for cities too if non-english speakers use this app. start with english, don't get ahead of yourself!
	# can't use enter to blur user input field
	# be able to access drop down results with arrow keys and enter
	# find nearby stations for locations that don't have a station id
	# change search from start_with? to include? - possibly gives too many results. not so
		# bad now that you've cleaned up LOCATIONS
	# be able to load main page without a query attached???
	# use lat/long to map locations on a globe graphic. you could plot all the matches on the same globe map to show comparisons. would you
		# want to do a mercator projection?
	# how to discover which stations are missing?
	# csv = 4588
	# json = 4624 (+36)
	# matches are links to info about those places. will it be just wikipedia stuff, or a google search? a google search is kinda lame...cuz
		# the user could type that in themselves if they wanted

	# the data acquisition will happen independently of the web page

	# play with tolerance between matches (result array)
	# if there are several matches within a certain radius (like, 500 km), return only 1 of them (most exact match), then chosen randomly after that, 	and also return matches that haven't been shown recently to increase variety
	# for those countries that don't show up on aeris, you could have a method that accesses data from wunderground, cuz
	# they seem to have a lot more locations, using the pws's. just because these places are ones that a user has likely never heard of or doesn't know much about! those are the ones you want to make sure you're including. don't worry about this too much right now