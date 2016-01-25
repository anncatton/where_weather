require "json"
require "open-uri"
require "uri"
require "active_support/core_ext/object/to_query.rb"
require "pg"
require "sequel"
# require "byebug"
require "./observation.rb"

DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')
DBHeroku = Sequel.connect('postgres://anncatton:@localhost:5432/heroku_weather')

def build_query(query)
	URI::HTTP.build(
		{
			:host => "api.aerisapi.com", 
			:path => "/observations/search", 
			:query => {
				:client_id => ENV['AERIS_CLIENT_ID'], 
				:client_secret => ENV['AERIS_CLIENT_SECRET'],
				:limit => 250,
				:query => query
			}.to_query
		}
	)
end

def uri_for_country(country)

	query = "country:" + country
	build_query(query)

end

def uri_for_state(state)

	query = "state:" + state
	build_query(query)

end

def get_all_data(countries, states)

	country_data = countries.map do |ea|
		processed_data_for_country(ea)
	end

	state_data = states.map do |ea|
		processed_data_for_state(ea)
	end

	processed_data = country_data.flatten + state_data.flatten

	processed_data.each do |ea|

		stations_table = DB[:stations]
		observations_table = DB[:weather_data]
	
		next if stations_table.where(:id=>ea[:id]).first.nil?

		if observations_table.where(:station_id=>ea[:id]).where(:time=>ea[:time]).where(:temp=>ea[:temp]).where(:dewpoint=>ea[:dewpoint]).where(:humidity=>ea[:humidity]).where(:conditions=>ea[:conditions]).where(:weather_primary_coded=>ea[:weather_primary_coded]).where(:clouds_coded=>ea[:clouds_coded]).where(:is_day=>ea[:is_day]).where(:wind_kph=>ea[:wind_kph]).where(:wind_direction=>ea[:wind_direction]).first.nil?

		insert_into_weather_data(ea)
		end
		
	end

end

def processed_data_for_country(country_name)
	raw_data = get_data_for_country(country_name)
	extract_station_data(raw_data)
end

def processed_data_for_state(state_name)
	raw_data = get_data_for_state(state_name)
	extract_station_data(raw_data)
end

def open_region_uri(uri)
	open(uri) do |io|

		json_string = io.read
		data_hash = JSON.parse(json_string)
		data_hash["response"]
	end
end

def get_data_for_country(country_name)
	country_uri = uri_for_country(country_name)
	open_region_uri(country_uri)
end

def get_data_for_state(state_name)
	state_uri = uri_for_state(state_name)
	open_region_uri(state_uri)
end

def extract_station_data(raw_data)
	all_stations = []

	raw_data.map do |ea|
		new_observation = Observation.from_json(ea)

		station = {}
		station[:id] = new_observation.station
		station[:time] = Time.parse(new_observation.time).utc
		station[:temp] = new_observation.temp
		station[:dewpoint] = new_observation.dewpoint
		station[:humidity] = new_observation.humidity
		station[:conditions] = new_observation.conditions
		station[:weather_primary_coded] = new_observation.weather_primary_coded
		station[:clouds_coded] = new_observation.clouds_coded
		station[:is_day] = new_observation.is_day
		station[:wind_kph] = new_observation.wind_kph
		station[:wind_direction] = new_observation.wind_direction

		all_stations << station
	end

	all_stations

end

# in this method, you could set it to write to both databases
def insert_into_weather_data(station)

	observations_table = DB[:weather_data]
	heroku_obs_table = DBHeroku[:weather_data]

# remember that you still need to erase the heroku weather_data before you write to it.
# use a sequel delete command first, then write to it
	heroku_obs_table.insert(
	:station_id=>station[:id],
	:time=>station[:time],
	:temp=>station[:temp], 
	:dewpoint=>station[:dewpoint],
	:humidity=>station[:humidity],
	:conditions=>station[:conditions], 
	:weather_primary_coded=>station[:weather_primary_coded],
	:clouds_coded=>station[:clouds_coded], 
	:is_day=>station[:is_day],
	:wind_kph=>station[:wind_kph],
	:wind_direction=>station[:wind_direction]
	)

	observations_table.insert(
		:station_id=>station[:id],
		:time=>station[:time],
		:temp=>station[:temp], 
		:dewpoint=>station[:dewpoint],
		:humidity=>station[:humidity],
		:conditions=>station[:conditions], 
		:weather_primary_coded=>station[:weather_primary_coded],
		:clouds_coded=>station[:clouds_coded], 
		:is_day=>station[:is_day],
		:wind_kph=>station[:wind_kph],
		:wind_direction=>station[:wind_direction]
		)

end

countries = ["ae", "af", "ag", "al", "am", "ao", "aq", "ar", "at", "au", "aw", "az", "ba", "bb", "bd", "be", 
	"bf", "bg", "bh", "bj", "bm", "bo", "br", "bs", "bt", "bw", "by", "bz", "cf", "cg", "ch", "ci", "cl", "cm", 
	"cn", "co", "cr", "cu", "cv", "cy", "cz", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "es", "et", 
	"fi", "fj", "fk", "fm",  "fr", "ga", "gb", "gd", "ge", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gt", 
	"gw", "gy", "hk", "hn", "hr", "hu", "id", "ie", "il", "in", "iq", "ir", "is", "it", "jm", "jo", "jp", "ke", 
	"kg", "kh", "km", "kn", "kr", "kw", "ky", "kz", "la", "lb", "lc", "lk", "lr", "lt", "lu", "lv", "ly", "ma", 
	"md", "mk", "ml", "mm", "mo", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "ne" , "ng", 
	"ni", "nl", "no", "np", "nz", "om", "pa", "pe", "pg", "ph", "pk", "pl", "pt", "py", "qa", "ro", "ru", "rw", 
	"sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sk", "sl", "sn", "sr", "st", "sv", "sy", "sz",  "td", "tg", 
	"th", "tj", "tm", "tn", "tr", "tt", "tw", "tz", "ua", "ug", "uy", "uz", "vc", "ve", "vi", "vn", "vu", "ws", 
	"ye", "za", "zm", "zw"]

us_and_canada = ["ab", "al", "ak", "az", "ar", "bc", "ca", "co", "ct", "de", "dc", "fl", "ga", "hi", "id", "il", 
	"in", "ia", "ks", "ky", "la", "mb", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt", "nb", "ne", "nv", "nh", "nj", 
	"nl", "nm", "ns", "nt", "nu", "ny", "nc", "nd", "oh", "ok", "on", "or", "pa", "pe", "qc", "ri", "sc", "sd", "sk", 
	"tn", "tx", "ut", "vt", "va", "wa", "wv", "wi", "wy", "yt"]

get_all_data(countries, us_and_canada)