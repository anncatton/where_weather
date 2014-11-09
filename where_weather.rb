require 'sinatra'
require 'byebug'
require	'json'
#require './models/stations.rb'

get '/' do

	erb :index

end


		# what do you need to include on a basic page?
		# - a field to put in your location (at some point it should just detect location automatically)
		# - shows the data for that location
		# - then below it will show the places that match, with their conditions
		# - eventually will show on a globe where these matches are, and links to find out more about them!