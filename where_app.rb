require "sinatra"
require "json"

get '/where_weather' do

	erb :index, :layout => :layout

end