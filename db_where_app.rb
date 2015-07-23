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

		query_observation = Observation.match_in_timeframe(station_id, '2015-07-17 00:30:00', '2015-07-17 02:30:00')

		if query_observation.nil?

			station_record = DB[:stations].where(:id=>station_id.upcase).first

			query_station = Station.from_table(station_record) unless station_record.nil?

			erb :index, :layout => :layout, :locals => {:query_station => query_station,
																									:query_observation => nil}				

		else
			# take a closer look at this section for how you're handling nil values. i think i have repeats here?
			if query_observation.temp.nil? || query_observation.dewpoint.nil? || query_observation.weather_primary_coded.nil? ||
				query_observation.wind_kph.nil? || query_observation.wind_direction.nil?

				erb :index, :layout => :layout, :locals => {:query_observation => query_observation,
																										:query_observation_values => nil}
			else
				
				all_matches = query_observation.find_matches('2015-07-17 00:30:00', '2015-07-17 02:30:00')

				unless all_matches.nil?
					matches_checked_for_distance = all_matches.reject do |ea|
						Station.from_table(ea).too_close?(query_observation.station)
					end

					matching_observations = matches_checked_for_distance.map do |ea|
						Observation.from_table(ea)
					end

					matches_sorted_by_time = matching_observations.sort_by { |ea| ea.time }
					matches_sorted_by_time.reverse!.uniq! { |ea| ea.station.id }

					scores_array = []

					matches_sorted_by_time.map do |ea|

						location_hash = {}

						temp = ea.temp_score(query_observation.temp)
						dewpoint = ea.dewpoint_score(query_observation.dewpoint)
						humidity = ea.humidity_score(query_observation.humidity)
						wind_kph = ea.wind_kph_score(query_observation.wind_kph)

						total_score = (temp + dewpoint + humidity + wind_kph)/80.0
						percentage_score = (total_score * 100).round(2)
						
						location_hash[:score] = percentage_score
						location_hash[:location] = ea.station
						scores_array << location_hash

					end

					sorted_scores = scores_array.sort_by { |hash| hash[:score] }
					sorted_scores.reverse!

					erb :index, :layout => :layout, :locals => {:query_observation => query_observation,
																											:sorted_scores => sorted_scores,
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