require "sinatra"
require "json"
require "./models/stations.rb"
require "./models/api_request.rb"
require "byebug"
require "pg"
require "sequel"
require 'logger'

# DB = Sequel.sqlite '', :loggers => [Logger.new($stdout)]
# or
DB.loggers << Logger.new($stdout)

DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')
# DB.sql_log_level = :debug

get '/' do
	redirect to('/where_weather')
end

get '/where_weather' do

	stations = DB[:stations]
	observations = DB[:weather_data]

	# def find_station(id)
	# 	observation_hash = observations.all
	# 	observation_hash.find do |ea|
	# 		ea[:station_id] == id
	# 	end
	# end
	
	# is this better than the one above? if so, why? it is, because the one above queries for ALL the records in the weather_data table,
	# whereas this one below makes a more specific query - it looks for records with that station_id, limit 1 result
	def find_station(id)
		observations = DB[:weather_data]
		match = observations.where(:station_id=>id.upcase).first
		match
	end
	
	# should i change this to be a search for records that meet the match criteria?
	# for example WHERE temp =/- 1 AND WHERE humidity = +/- 5 AND etc... YES
	# sooo... you want to find the records that match the criteria BEFORE you turn them into Observation instances?
	# so don't do this just below! then you're creating hundreds of instances you don't even need
	stations_to_compare = DB[:weather_data].map do |ea|
		Observation.from_table(ea)
	end

	valid_stations = stations_to_compare.reject do |ea|
		ea.not_valid?
	end
# i've checked up to here
	if params.empty? # this doesn't currently help when you load page without a query attached in the address bar. guess you'll have to
		# load it with an autoip query maybe? also _results_view has an if/else to handle matching_station being nil
		erb :index, :layout => :layout, :locals => { :matching_station => nil,
																								:locations_match => nil }
	else
		station_id = params[:id]
		station_to_match = find_station(id)
		locations_match = stations.where(:id=>station_id.upcase).first

		station = Station.from_json(matching_station)
		matches = valid_stations.find_all do |ea|
			ea != station && station.matches?(ea)
		end

		def find_pretty_match_station(station_to_match)
			stations = DB[:stations]
			match = stations.where(:id=>station_to_match.id.upcase).first
			# match = station_list.find do |ea|
			# 	match = ea[:id] == station_to_match.id
			# 	match
			# end

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

  matches = stations.where(Sequel.ilike(:name, query+'%'))
  # matches = station_list.find_all do |ea|
  # 	next if ea[:name].nil? # do i need this anymore, now the database has a name for each location?
  # 	ea[:name].downcase.start_with?(query.downcase)
  # end

  content = if matches.empty?
  	erb :_no_result
	else
  	erb :_data_field, :layout => false, :locals => { :matches => matches }
	end

# what is this first_city section for?
	# first_city = if matches.empty?
	# 	erb :_no_result
	# else
	# 	erb :_display_span, :layout => false, :locals => {:first_match => matches.first }
	# end

 #  { :html => content, :first_match => first_city }.to_json

 { :html => content }.to_json

end