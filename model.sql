-- ALTER TABLE stations ADD COLUMN location POINT;

-- UPDATE stations SET location = SELECT CAST((longitude, latitude) AS POINT);

DROP TABLE IF EXISTS weather_data;
DROP TABLE IF EXISTS stations;

CREATE TABLE stations (
	name text NOT NULL, 
	region text, 
	country text NOT NULL, 
	location point NOT NULL,
	id text PRIMARY KEY
	);

CREATE TABLE weather_data (
	id bigserial PRIMARY KEY, -- so that you can add each new set of observations to the growing database
	station_id text NOT NULL REFERENCES stations (id),
 	time text NOT NULL, 
 	temp integer, 
 	dewpoint integer, 
 	humidity integer, 
 	conditions text, 
 	weather_primary_coded text, 
 	clouds_coded text, 
 	is_day boolean, 
 	wind_kph integer, 
 	wind_direction text
 	);

-- the station_id in weather_data must be in stations in order to remain valid, but a station id (id) in stations does
-- not need to be in weather_data in order to be valid. so, weather_data is dependent on stations
-- this is why you have weather_data(station_id) REFERENCES stations(id)
-- more constraints: station ids must be 4 characters long
-- Many developers consider explicitly listing the columns better style than relying on the order implicitly. also, i'm
-- assuming you'll be creating methods to populate your tables, not typing each one in!

