class MatchResult

  attr_accessor :station, :conditions, :temp, :dewpoint, :humidity, :wind_kph, :score

  def initialize(station, conditions, temp, dewpoint, humidity, wind_kph, score)
    @station = station
    @conditions = conditions
    @temp = temp
    @dewpoint = dewpoint
    @humidity = humidity
    @wind_kph = wind_kph
    @score = score
  end

  def self.from_match(match)
    self.new(
      Station.new(match[:station_id],
        match[:name],
        match[:region],
        match[:country],
        match[:latitude],
        match[:longitude]
      ),
      match[:conditions],
      match[:temp],
      match[:dewpoint],
      match[:humidity],
      match[:wind_kph]
    )
  end

end