require "sinatra"
require "json"
require "./models/stations.rb"
require "./models/observation.rb"
require "byebug"
require "pg"
require "sequel"
require "logger"

DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')
DB.loggers << Logger.new($stdout)

get '/' do
	redirect to('/where_weather')
end

get '/where_weather' do

	station_id = params[:id]

	if station_id.nil?

		erb :index, :layout => :layout, :locals => {:query_observation => nil}

	else

		query_observation = Observation.match_in_timeframe(station_id, '2015-07-09 14:00:00', '2015-07-09 16:00:00')

		if query_observation.nil?

			station_record = DB[:stations].where(:id=>station_id.upcase).first

			if station_record.nil?
				erb :index, :layout => :layout, :locals => {:query_station => nil,
																										:query_observation => nil}
			else
				query_station = Station.from_table(station_record)

				erb :index, :layout => :layout, :locals => {:query_station => query_station,
																										:query_observation => nil}				
			end

		else
			# take a closer look at this section for value nils
			if query_observation.temp.nil? || query_observation.dewpoint.nil? || query_observation.weather_primary_coded.nil? ||
				query_observation.wind_kph.nil? || query_observation.wind_direction.nil?

				erb :index, :layout => :layout, :locals => {:query_observation => query_observation,
																										:query_observation_values => nil}
			else
				
				all_matches = query_observation.find_matches('2015-07-09 14:00:00', '2015-07-09 16:00:00')

				unless all_matches.nil?
					matches_checked_for_distance = all_matches.reject do |ea|
						Station.from_table(ea).too_close?(query_observation.station)
					end

					matching_observations = matches_checked_for_distance.map do |ea|
						Observation.from_table(ea)
					end

					scores_hash = {}

					matching_observations.map do |ea|

						temp = ea.temp_score(query_observation.temp)
						dewpoint = ea.dewpoint_score(query_observation.dewpoint)
						humidity = ea.humidity_score(query_observation.humidity)
						wind_kph = ea.wind_kph_score(query_observation.wind_kph)

						total_score = (temp + dewpoint + humidity + wind_kph)/80.0
						percentage_score = (total_score * 100).round(2)
						scores_hash[ea.station.id] = percentage_score

					end

					erb :index, :layout => :layout, :locals => {:query_observation => query_observation,
																											:matching_observations => matching_observations,
																											:scores_hash => scores_hash,
																											:query_observation_values => "you got some" }
				end
			end

		end

	end


end

get '/location_search' do

	stations_table = DB[:stations]

  content_type :json
  query = params[:query]

  matches = stations_table.where(Sequel.ilike(:name, query+'%'))

  content = if matches.empty?
  	erb :_no_result, :layout => false
	else
  	erb :_drop_down, :layout => false, :locals => { :matches => matches }
	end

 { :html => content }.to_json

end