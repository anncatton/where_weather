require 'json'
require 'byebug'

#byebug

# you could set the file name to be whatever was entered by the user in the command line
qc_file = './qc_edit.json'

open(qc_file) do |f|

	json_file = f.read
	parsed_file = JSON.parse(json_file)

	current = parsed_file['response'][0]['ob']
	tempC = current['tempC']


	puts tempC

end

# puts @current.inspect
# So solution is to use [0], or #first method, in the assignment:

# @current = @parse['data']['current_condition'].first
# this TypeError in ruby usually is caused by accessing an array via string instead of integer value.
# this is what parsed_file.inspect returns:

# {"response"=>[
# 		{"id"=>"CWIP",
# 		"loc"=>{"long"=>-66.433333333333, "lat"=>50.166666666667}, 
# 		"place"=>{"name"=>"pointe noires cs", "state"=>"qc", "country"=>"ca"}, 
# 		"obDateTime"=>"2014-11-01T16:00:00-04:00", 
# 		"ob"=>{"tempC"=>3, 
# 			"dewpointC"=>nil, 
# 			"humidity"=>nil, 
# 			"weatherShort"=>"Mostly Sunny"}
# 		}
# 	]
# }

# which means response is pointing to an array of hashes ??

# now, i don't know if this is screwing around with things i shouldn't, but if you take out the array that response points to, you can skip
# the [0] step when accessing values inside the keys in response. so instead of:

# open(qc_file) do |f|

# 	json_file = f.read
# 	parsed_file = JSON.parse(json_file)

# 	current = parsed_file['response']
# 	tempC = current[0]['ob']['tempC']

# 	puts tempC

# end

# you can put:

# open(qc_file) do |f|

# 	json_file = f.read
# 	parsed_file = JSON.parse(json_file)

# 	current = parsed_file['response']
# 	tempC = current['ob']['tempC']

# 	puts tempC

# end

# i'm just not sure if the array needs to be left there - i.e. when i'm accessing data from the api, it's going to return it in the array form
# so i should just leave the [0] code in there. because to get rid of it you have to mess around with the json files...