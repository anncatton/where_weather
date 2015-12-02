require "../models/observation.rb"

describe Observation do

	test_station_one = Observation.new('CYYZ', '2015-04-01T18:00:00-04:00', 15, 13, nil, 'Mostly Cloudy', '::BK', 'BK', true, nil, nil)
	test_station_two = Observation.new('CYVR', '2015-04-01T18:00:00-04:00', 14, 13, nil, 'Mostly Sunny', '::FW', 'FW', true, 12, 'SSW')
	
  it "should work" do
    expect(10).to be > 8
  end
  it "should be right" do
  	expect(test_station_one.temp).to be == test_station_two.temp
  end
end
