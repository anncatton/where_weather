require 'pg'
require 'sequel'
require 'byebug'
require 'json'
require './models/edited_cities_map.rb'

# ruby script to populate sql tables

DB = Sequel.connect('postgres://anncatton:@localhost:5432/mydb')

stations = DB[:stations]
weather_data = DB[:weather_data]

# this inserts the values from LOCATIONS into the stations table
# def insert_into_stations(station, table)

# 	table.insert(:name => station[:city], :region => station[:region], :country => station[:country], :id => station[:station], :location => "(#{station[:longitude]}, #{station[:latitude]})")
# end

def insert_into_stations(station, table)
	table.insert(:name => station[:city], :region => station[:region], :country => station[:country], :id => station[:station], :longitude => station[:longitude].round(2), :latitude => station[:latitude].round(2))
end

LOCATIONS.each do |ea|
	insert_into_stations(ea, stations)
end

# # this was to take the lat/long numbers from the parsed json file and put them into the LOCATIONS array, because this is permanent data
# new_locations_array = LOCATIONS.each do |ea|

# 	match = STATION_KEYS[ea[:station].downcase]
# 	next if match.nil?
# 	ea[:latitude] = match["latitude"]
# 	ea[:longitude] = match["longitude"]

# end
                                              
# File.open('./models/edited_cities_map.rb', 'w') { |f| f.write(new_locations_array) }

def parse_json_file(filename)

	with_downcased_keys = {}

	File.open(filename, "r") do |f|
		json_file = f.read
		parsed_file = JSON.parse(json_file)

		parsed_file.each do |k,v| 
			with_downcased_keys[k.downcase] = v
		end
	end

	with_downcased_keys

end

# id | station_id | time | temp | dewpoint | humidity | conditions | weather_primary_coded | clouds_coded | is_day | wind_kph | wind_direction
def insert_into_weather_data(station, table)
	table.insert(:station_id=>station["id"], :time=>station["time"], :temp=>station["temp"], :dewpoint=>station["dewpoint"], :humidity=>station["humidity"], :conditions=>station["conditions"], :weather_primary_coded=>station["weather_primary_coded"], :clouds_coded=>station["clouds_coded"], :is_day=>station["is_day"], :wind_kph=>station["wind_kph"], :wind_direction=>station["wind_direction"])
end

# do a database query in station_list to check for that station id (that's coming from the json file), and if it's not there, skip it

# parsed_data = parse_json_file("./weather_data/all_stations.json")

# # so is this - ids - like a method that only runs once it's called?
# ids = station_list.map(:id)

# parsed_data.map do |ea|
# 	next if !(ids.include? ea[0].upcase)
# 	insert_into_weather_data(ea[1], weather_data)
# end

# * station was offline, nothing under 'change station' -> check again
# ++ id only on gladstone, not WU
# I think you should also note that some of these stations show up at certain times of day, and other times are offline and so don't
# show up or show a different referencing station on WU
# a lot of K*** stations I think are us military bases so they show up as 'unknown, unknown' US locations
# KQCL - doesn't show up on wu or gladstone, on aeris as military installation in Afghanistan - Fob Clark
# LBGO - Gorna Orechovista, Bulgaria
# SLCO - Cobija, Bolivia
# SLCP - Concepcion, Bolivia
# SLJO - San Joaquin, Bolivia
# SLJE - San Jose De Chiquitos, Bolivia
# SLRY - Reyes, Bolivia
# SLMG - Magdalena, Bolivia
# SLRQ - Rurrenabaque, Bolivia
# SBEK - Jacareacanga, Brazil *
# SBLB - Plataforma P-25 Airport, Brazil (prob an oil platform)
# SBJF - Juiz De Fora, Brazil *
# SBCC - Cachimbo, Brazil *
# SBPN - Porto Nacional Aeroporto, Brazil *
# SBCI - Carolina, Brazil *
# SBCB - Cabo Frio, Brazil ++
# SBLE - Chapada Diamantina Airport, Brazil ++
# SBFS - São Tomé Campos Dos Goitacazes Heliport, RJ, Brazil ++ (on WU as SBCP)
# SBLP - Bom Jesus Da Lapa, Brazil
# SBTU - Tucurui, Brazil *
# SBBQ - Barbacena, Brazil
# SBGW - Guaratingueta, Brazil * (wu - SBSJ)
# SBIC - Itacoatiara Airport, Brazil *
# SBST - Santos Aeroporto , Brazil * (wu - SBGR)
# SBUF - Paulo Afonso, Brazil 
# SBUG - Uruguaiana Aeroporto , Brazil * (wu - SARL)
# SBPP - Ponta Pora International, Brazil
# SBBG - Bage Airport, Brazil
# SBMY - Manicore, Brazil
# SBPC - Pocos De Caldas, Brazil
# SBES - S. P. Aldeia Aerodrome , Brazil * (wu - SBME)
# SBBW - Barra Do Garcas, Brazil
# SBTC - Una Hotel Transa, Brazil / Hotel Transamérica Airport, Brazil * (wu - SBIL)
# SBAX - Araxa, Brazil *
# SBIP - Usiminas-Paraiso, Brazil *
# SBFN - Fernando De Noronha, Brazil
# SBMS - Mocoro - 17 Rosado, Brazil
# SBCJ - Carajas - Maraba, Brazil 
# SCPQ - Mocopulli, Chile
# SCNT - TTE. Julio Gallardo Airpo, Chile *
# SCRM - Teniente R Marsh Martin, Antarctica
# SCJO - Cañal Bajo Carlos - Hott Siebert Airport, Chile * (wu - SCTE)
# SKPC - Puerto Carreno, Colombia
# SKUI - Quibdo / El Carano, Colombia
# SKIB - Ibague, Colombia
# SKMZ - Manizales / La Nubia, Colombia *
# SKMD - Medellin, Colombia
# SKPS - Pasto, Colombia
# SKIP - Ipiales, Colombia
# KQQY - no data
# EDJA - Memmingen Allgau * (wu - ETSA or ETHA)
# HDAM - Djibouti, Djibouti (Ambouli)
# MDAB - Arroyo Barril, Dominican Republic
# SEQM - Mariscal Sucre International, Ecuador
# HETR - El Tor, Egypt * (wu - HESH)
# LEGR - Granada, Spain
# LELC - Murcia / San Javier, Spain * (wu - LEAL)
# LEAS - Asturias / Aviles, Spain
# LERS - Reus, Spain
# HAAB - Addis Ababa, Ethiopia
# LFRT - Saint-Brieuc, France
# LFVP - Saint-Pierre, Saint Pierre and Miquelon
# EGAC - Belfast Harbour, United Kingdom
# EGHI - Southampton, United Kingdom
# EGNV - Teesside, United Kingdom * check the name on this one
# EGCN - Doncaster Sheffield, United Kingdom
# SYGO - Ogle Airport, Guyana
# KQTI - Iraq (aeris)
# OISF - Fasa, Iran (from gladstone), this code not on wu but Fasa is, wasn't available on aeris at the time
# LIPB - Bolzano, Italy
# LIMP - Parma, Italy * (wu - LIMS)
# LIRZ - Perugia, Italy * (wu - LIVF)
# LICB - Comiso, Italy (Sicily)
# LICD - Lampedusa, Italy
# LICR - Reggio Calabria, Italy
# RJOS - Tokushima Air Base, Japan
# RJTC - Tachikawa Air Base, Japan * (wu - RJTY)
# RJTR - Zama, Japan (wu - only pws shows up but searching under this code still finds it)
# RJDM - Metabaru Air Base, Japan * (wu - only pws shows up but searching under this code still finds it)
# HKMB - Marsabit, Kenya
# KQLP - not on wu or gladstone, aeris says Laikapia Air base, Kenya
# HKNW - Nairobi Wilson, Kenya
# KQEL - Gapyeong, South Korea (only in aeris)
# KQFA - Camp Stanley, South Korea (only in aeris). Camp Stanley-H-207 on wu * as RKSS (Kimpo)
# VCRI - Mattala Rajapaksa International Airport, Sri Lanka
# GMMH - Dakhla, Western Sahara
# GMMI - Essaouira, Morocco
# GAKY - Kayes, Mali
# TRPG - Gerald's, Montserrat
# MMCT - Chichen Itza, Mexico
# MMPG - Piedras Negras, Mexico
# DNKN - Kano, Nigeria
# ENRM - Rorvik, Norway (also called Ryum - the airport is called Rorvik but the town of Rorvik is 6km away??)
# ENBV - Berlevag, Norway * (wu - ENBS)
# ENBL - Forde - Bringeland, Norway * (wu - ENFL)
# ENSD - Sandane, Norway
# ENOV - Orsta-Volda, Norway
# ENNK - Narvik (iii), Norway (not sure i want the 'iii' in there)
# KQTH - Thumrait, Oman * (wu - OOSA)
# SPLO - Ilo, Peru *
# SPGM - Tingo Maria, Peru
# SPJI - Juanjui, Peru
# SPZA - Nazca, Peru (Maria Reiche Neuman, Peru) * 
# SPYL - Talara, Peru
# AYWK - Wewak, Papua New Guinea
# AYGN - Alotau, Papua New Guinea
# LPHR - Horta Castelo Branco, Azores
# OEAO - Al Ula, Saudi Arabia (Prince Abdulmajeed Bin Abdulaz Airport, Saudi Arabia)
# LTCN - Kahramanmaras, Turkey * (wu - LTAJ)
# SUDU - Durazno, Uruguay
# SUAA - Melilla, Uruguay
# SUCA - Colonia, Uruguay
# SVPC - Puerto Cabello, Venezuela
# SVJC - Paraguana, Venezuela * (wu - SVCR)
# TISX - Christiansted, Virgin Islands * (wu - TJNR)
# TQPF - Clayton J. Lloyd International Airport - close to The Valley, Anguilla, which is the capital. * (wu - Wallblake Airport)
# 		- the only station on this island, you could just call it Anguilla
# FAUT - Umtata, South Africa
# FLSK - Ndola, Zambia
# CXEC - Edmonton Municipal, Canada * (wu - CYEG or CYED). obviously you don't need an extra edmonton station
# CZZJ - Edson (Climate), Canada * (wu - CYET)
# CZMU - Mundare AGDM, Canada
# CXMM - Fort McMurray, Alberta * (wu - CYMM)
# KHEY - Newton/Ozark, Alabama, US
# K0J4 - Lockhart, AL, US
# KEUF - Eufaula, AL, US
# PADG - Red Dog Mine Airport, AK * (wu - PAVL, which is Kivalina) PADG wasn't showing up on aeris when i checked this
# PAEL - Elfin Cove, AK, US
# PAFR - Fort Richardson, AK
# PAIM - Indian Mountain Air Force Station - 15miles from Hughes, AK, US
# KCMR - Williams, AZ
# CWGW - Sparwood BC, Canada * (wu - CWSW, but CWGW shows up under one of the 'auto' stations)
# CWPR - Princeton, BC, CAN * (wu - also under CYDC)
# CWJU - Langara Island, BC, CAN - looks like it's north of Queen Charlotte
# CYIN - Bleibler Ranch, British Columbia
# KLPC - Lompoc, CA, US
# KAUN - Auburn, CA, US
# KFTG - Bennett, CO (Front Range Airport), US - its between Bennett and Watkins CO
# KSHM - Schriever AFB, Colorado Springs, CO, US * (wu - KAFF)
# KTDR - Panama City, FL
# K1J0 - Bonifay, FL (Tri County Airport)
# K1II - Nineveh, IN
# K5M9 - Marion, KY
# KCEY - Murrey, KY
# KSCF - South Marsh 268, LA (looks like its in the middle of the Gulf, maybe skip it)
# KXPY - Port Fourchon Terminal, LA
# CYBV - Berens River, Canada * (wu - CWCF)
# CWGX - Gillam, MB * (wu - also under CYGX)
# K40B - Clayton Lake, ME * (wu - KPQI)
# KDRM - Drummond Island, MI
# K9MN - Rochester, MN
# KUOX - Oxford, MS
# KJVW - Raymond, MS
# KMHL - Marshall, MO
# K05U - Eureka, NV
# CYAY - St. Anthony, NL
# CWHO - Hopedale, Newfoundland
# KM63 - McGregor Range Base Camp, NM
# CXLL - Lindberg Landing, NT
# CYFR - Fort Resolution, NT, Canada (wasnt showing on wu)
# CYWY - Wrigley, Northwest Territories (found on wu but wouldnt show station)
# CYUT - Repulse Bay, NU
# CYXN - Whale Cove, Nunavut * (wu - CYRT)
# CWGZ - Grise Fiord, Nunavut (not on wu with id)
# CYXP - Pangnirtung, NT
# CYLT
# CYCS
# CWJC
# K2C8
# KS25
# KY19
# KHZE
# KBAC
# KVES
# KILN
# CYSP
# CXHA
# CXKI
# CWGD
# CWNZ
# CYIK
# CYTQ
# CYKG
# CYLU
# CYKQ
# CYAS
# CYZG
# CYLA
# CWGR
# CWNH
# CWPK
# CWBY
# KOQU
# KMNI
# KBKX
# CWOY
# CYMJ
# KGVT
# KLZZ
# KWAL
# KCLM
# K1YT
# KNOW
# KDGW
# KAJL
# CZFA
# CYXQ
# CYOC