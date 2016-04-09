require "sinatra"
require "json"
require_relative "./models/stations.rb"
require_relative "./models/observation.rb"
require_relative "./models/match_result.rb"
require "byebug"
require "pg"
require "sequel"
require "logger"
# require "ruby-prof"

# RubyProf.start

GOOGLE_MAP_KEY = ENV['GOOGLE_MAP_WEATHER_KEY']
DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://anncatton:@localhost:5432/mydb')
# DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')
# DB = Sequel.connect('postgres://anncatton:@localhost:5432/heroku_weather')

# result = RubyProf.stop
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(STDOUT)

DB.loggers << Logger.new($stdout)

get '/' do
	redirect to('/where_weather')
end

get '/where_weather' do
	station_id = params[:id]

	if station_id.nil?
		erb :index, layout: :layout, locals: { google_map_key: GOOGLE_MAP_KEY,
																					query_station: nil,
																					query_observation: nil }

	else
		query_observation = Observation.match_in_timeframe(station_id)

		if query_observation.nil?

			station_record = DB[:stations].where(id: station_id.upcase).first

			query_station = Station.from_table(station_record) unless station_record.nil?

			erb :index, layout: :layout, locals: { google_map_key: GOOGLE_MAP_KEY,
																						query_station: query_station,
																						query_observation: nil }				

		else

			query_time = query_observation.time
			start_time = query_time - 3600
			end_time = query_time + 3600

			all_matches = query_observation.find_matches(start_time, end_time)

			unless all_matches.nil?
				matches_checked_for_distance = all_matches.reject do |ea|
					Station.from_table(ea).too_close?(query_observation.station)
				end

				matches_grouped_by_id = matches_checked_for_distance.group_by { |ea| ea[:station_id] }

				most_recent_matches = matches_grouped_by_id.map do |station_id, observations|
					most_recent = observations.max do |a, b|
						a[:time] <=> b[:time]
					end
					Observation.from_table(most_recent)

				end

				match_results = []

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

					match_results << MatchResult.new(ea.station, ea.conditions, ea.temp, ea.dewpoint, ea.humidity, ea.wind_kph, percentage_score)

				end
				
				sorted_matches = match_results.sort_by { |hash| hash.score }
				sorted_matches.reverse!

				erb :index, layout: :layout, locals: { google_map_key: GOOGLE_MAP_KEY,
																							query_observation: query_observation,
																							sorted_matches: sorted_matches }

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
  	erb :_no_result, layout: false
	else
		unique_matches = matches.all.uniq { |ea| ea[:name] && ea[:region] }
  	erb :_drop_down, layout: false, :locals => { matches: unique_matches }
	end

 { html: content }.to_json

end
