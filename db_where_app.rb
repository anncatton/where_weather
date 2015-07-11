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

		erb :index, :layout => :layout, :locals => {:matching_observation => nil}

	else

		matching_observation = Observation.match_in_timeframe(station_id, '2015-07-09 14:00:00', '2015-07-09 16:00:00')

		if matching_observation.nil?

			station_record = DB[:stations].where(:id=>station_id.upcase).first

			if station_record.nil?
				erb :index, :layout => :layout, :locals => {:station => nil,
																										:matching_observation => nil}
			else
				station = Station.from_table(station_record)

				erb :index, :layout => :layout, :locals => {:station => station,
																										:matching_observation => nil}				
			end

		else
			
			if matching_observation.temp.nil? || matching_observation.dewpoint.nil? || matching_observation.weather_primary_coded.nil? ||
				matching_observation.wind_kph.nil? || matching_observation.wind_direction.nil?

				erb :index, :layout => :layout, :locals => {:matching_observation => matching_observation,
																										:observation_values => nil,
																										:station => station}
			else
				
				all_matches = matching_observation.find_matches('2015-07-09 14:00:00', '2015-07-09 16:00:00')

				unless all_matches.nil?
					checked_for_distance = all_matches.reject do |ea|
						station_to_check = Station.from_table(ea)
						station_to_check.too_close?(matching_observation.station)
					end
					
					matched_observations_to_display = checked_for_distance.map do |ea|
						Observation.from_table(ea)
					end

					scores_hash = {}

					matched_observations_to_display.map do |ea|

						temp = ea.temp_score(matching_observation.temp)
						dewpoint = ea.dewpoint_score(matching_observation.dewpoint)
						humidity = ea.humidity_score(matching_observation.humidity)
						wind_kph = ea.wind_kph_score(matching_observation.wind_kph)

						total_score = (temp + dewpoint + humidity + wind_kph)/80.0
						percentage = (total_score * 100).round(2)
						scores_hash[ea] = percentage

					end

					sorted_scores = scores_hash.sort_by { |k, v| v }
					sorted_scores_hash = sorted_scores.reverse!.to_h

					erb :index, :layout => :layout, :locals => {:matching_observation => matching_observation,
																											#:matched_observations_to_display => matched_observations_to_display,
																											:sorted_scores_hash => sorted_scores_hash,
																											:observation_values => "you got some" }
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
  	erb :_data_field, :layout => false, :locals => { :matches => matches }
	end

 { :html => content }.to_json

end