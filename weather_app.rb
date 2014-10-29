class Location

	# attr_accessor :temperature, :humidity, :sky_condition

	# def initialize(temperature, humidity, sky_condition)
	# 	@temperature = temperature
	# 	@humidity = humidity
	# 	@sky_condition = sky_condition
	# end

	attr_accessor :name, :time

	def initialize(name, time)
		@name = name
		@time = time
	end

end


city1 = Location.new("Toronto", Time.now)

puts city1.name
puts city1.time


class Location

	# attr_accessor :temperature, :humidity, :sky_condition

	# def initialize(temperature, humidity, sky_condition)
	# 	@temperature = temperature
	# 	@humidity = humidity
	# 	@sky_condition = sky_condition
	# end

	attr_accessor :name

	def initialize(name)
		@name = name
	end

	@measurements = {:temp => temp,
									:sky_condition => skies,
									:humidity => humidity,
									:dew_point => dewpoint
	}

	@time = Time.now # how come this works as Location.time, without having it in attr_accessor


end


city1 = Location.new("Toronto")

puts city1.name
puts city1.time

# 905ae13579633139

# these are things i'm not sure about: when i create a class Location, what are the things
# that need to be defined on initialize? is it just the name? or is this where i should be
# putting stuff like the measurements?

because the name of a city doesn't change but the conditions will, would it only be name (and
	possibly latitude/longitude or whatever) that is set when an instance is created? or maybe you
	need to create an empty hash for each array too that will hold the 3-4 measurements you'll 
	need for comparison.