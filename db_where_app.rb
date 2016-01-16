require "sinatra"
require "json"
require_relative "./models/stations.rb"
require_relative "./models/observation.rb"
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


# def find_most_recent_time(station_id)
# 	stations_and_observations_join = DB[:stations].join(DB[:weather_data], :station_id => :id)
# 	results = stations_and_observations_join.where(:station_id => station_id).all
# 	times = results.map do |ea|
# 		ea[:time]
# 	end

# 	latest_time = times.max
# 	byebug
# end

# start_time = find_most_recent_time(station_id) - 3600
# end_time = find_most_recent_time(station_id) + 3600

	if station_id.nil?
		erb :index, :layout => :layout, :locals => {:query_station => nil,
													:query_observation => nil}

	else

		query_observation = Observation.match_in_timeframe(station_id, '2016-01-16 00:50:00', '2016-01-16 02:50:00')

		if query_observation.nil?

			station_record = DB[:stations].where(:id=>station_id.upcase).first

			query_station = Station.from_table(station_record) unless station_record.nil?

			erb :index, :layout => :layout, :locals => {:query_station => query_station,
														:query_observation => nil}				

		else

				all_matches = query_observation.find_matches('2016-01-16 00:50:00', '2016-01-16 02:50:00')

				unless all_matches.nil?
					matches_checked_for_distance = all_matches.reject do |ea|
						Station.from_table(ea).too_close?(query_observation.station)
					end

					matches_grouped_by_id = matches_checked_for_distance.group_by { |ea| ea[:station_id]}

					most_recent_matches = matches_grouped_by_id.map do |station_id, observations|
						most_recent = observations.max do |a, b|
							a[:time] <=> b[:time]
						end
						Observation.from_table(most_recent)
					end

					scores_array = []

					most_recent_matches.map do |ea|

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
																:sorted_scores => sorted_scores}

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

