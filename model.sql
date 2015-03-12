CREATE TABLE weather_data (
	station_id text PRIMARY KEY,
 	name text, 
 	region text, 
 	country text NOT NULL, 
 	latitude integer NOT NULL, 
 	longitude integer NOT NULL, 
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

CREATE TABLE stations (
	name text NOT NULL, 
	region text, 
	country text NOT NULL, 
	station_id text PRIMARY KEY
	);