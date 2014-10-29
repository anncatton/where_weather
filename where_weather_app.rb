require "sinatra"
require "json"

get '/' do 

	erb :index
	
end

post '/update' do
	content_type :json

	
	# store data in database
	# amounts = DB[:amounts]

	# total = params["values"].inject(0){ | result, ea | result + ea.to_i }
	# { :total => total }.to_json
end

