DROP TABLE IF EXISTS weather_data;
DROP TABLE IF EXISTS stations;

CREATE TABLE stations (
	name text NOT NULL, 
	region text, 
	country text NOT NULL, 
	latitude integer NOT NULL, 
 	longitude integer NOT NULL, 
	id text PRIMARY KEY
	);

CREATE TABLE weather_data (
	id bigserial PRIMARY KEY,
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