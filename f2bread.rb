#/usr/bin/env ruby

# coding: utf-8

=begin

Description
===========
"f2bread" is a ruby script that I use to gather some basic info from 'fail2ban.log'. Any ideas, comments or complaints are more than welcome. 
Just drop a mail :-)

License
=======
The MIT License (MIT)
Copyright (c) 2012 Panagiotis Atmatzidis <atma[at]convalesco.org>
For more read: https://github.com/atmosx/f2bread/blob/master/LICENSE.md

Notes
=====
Note that this is an 'alpha' release which was meant mostly for personal usage. It certainly contains bugs. I'll try to improve the code and add 
functionalities when time permits. For now, "works".

In order to get a quick offline IP refference, I used MaxMind's free GeoIP database which comes under "Attribution-ShareAlike 3.0" license. 
You should install this database manually since I'm not sure if I can "ship" it or put it on GitHub along with the script.
Here is the package: http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz which you need to place 
at "/usr/share/local/" or elsewhere if you change the $GeoIP path.

Gem Installation
================
$ gem install optparse geoip time_diff

Examples
========
Show general info about specific fail2ban
$ ruby19 f2bread.rb -l /path/to/fail2ban.log -i

Show the top 10 entries per IP frequency
$ ruby19 f2bread.rb -l /path/to/fail2ban.log -s ip -n 10 

Show the top 5 banned countries, assume path /var/log/fail2ban.log
$ ruby19 f2bread.rb -s country -n 5

=end

require 'optparse'
require 'geoip'
#require 'socket'
require 'time_diff'

# Global vars
$version = "0.0.1-alpha 2012"
$banner = "#{__FILE__} #{$version} - Panagiotis Atmatzidis 2012\n--------------------------------------------------------\n"
$GeoIP = "/usr/share/local/GeoIP.dat"


# class starts here
class F2bread
	attr_accessor :log
	def initialize(log)
		# check if Fail2ban.log exists and then check if it's valid!
		raise ArgumentError, "No fail2ban.log found!!!" if File.exists?(log) == FALSE # <-- this is not needed right now!

		@data_table = []
		@log = log

		# grep lines that containt the keyword 'Ban' from log file
		lines = File.readlines(log).select {|line| line.match /Ban/}

		# Available internet country codes
		cdc = {
			"AD" => "Andorra",
			"AE" => "United_Arab_Emirates",
			"AF" => "Afghanistan",
			"AG" => "Antigua_and_Barbuda",
			"AI" => "Anguilla",
			"AL" => "Albania",
			"AM" => "Armenia",
			"AN" => "Netherlands_Antilles",
			"AO" => "Angola",
			"AQ" => "Antarctica",
			"AR" => "Argentina",
			"ARPA" => "Old_style_Arpanet",
			"AS" => "American Samoa",
			"AT" => "Austria",
			"AU" => "Australia",
			"AW" => "Aruba",
			"AZ" => "Azerbaijan",
			"BA" => "Bosnia_and_Herzegovina",
			"BB" => "Barbados",
			"BD" => "Bangladesh",
			"BE" => "Belgium",
			"BF" => "Burkina_Faso",
			"BG" => "Bulgaria",
			"BH" => "Bahrain",
			"BI" => "Burundi",
			"BJ" => "Benin",
			"BM" => "Bermuda",
			"BN" => "Brunei_Darussalam",
			"BO" => "Bolivia",
			"BR" => "Brazil",
			"BS" => "Bahamas",
			"BT" => "Bhutan",
			"BV" => "Bouvet_Island",
			"BW" => "Botswana",
			"BY" => "Belarus",
			"BZ" => "Belize",
			"CA" => "Canada",
			"CC" => "Cocos_Islands",
			"CF" => "Central_African_Republic",
			"CG" => "Congo",
			"CH" => "Switzerland",
			"CI" => "Ivory_Coast",
			"CK" => "Cook_Islands",
			"CL" => "Chile",
			"CM" => "Cameroon",
			"CN" => "China",
			"CO" => "Colombia",
			"COM" => "US_Commercial(USA)",
			"CR" => "Costa Rica",
			"CS" => "Czechoslovakia(former)",
			"CU" => "Cuba",
			"CV" => "Cape Verde",
			"CX" => "Christmas_Island",
			"CY" => "Cyprus",
			"CZ" => "Czech_Republic",
			"DE" => "Germany",
			"DJ" => "Djibouti",
			"DK" => "Denmark",
			"DM" => "Dominica",
			"DO" => "Dominican_Republic",
			"DZ" => "Algeria",
			"EC" => "Ecuador",
			"EDU" => "US_Educational(USA)",
			"EE" => "Estonia",
			"EG" => "Egypt",
			"EH" => "Western_Sahara",
			"ER" => "Eritrea",
			"ES" => "Spain",
			"ET" => "Ethiopia",
			"FI" => "Finland",
			"FJ" => "Fiji",
			"FK" => "Falkland_Islands",
			"FM" => "Micronesia",
			"FO" => "Faroe_Islands",
			"FR" => "France_(Francie)",
			"FX" => "France_Metropolitan",
			"GA" => "Gabon",
			"GB" => "Great_Britain(UK)",
			"GD" => "Grenada",
			"GE" => "Georgia",
			"GF" => "French_Guiana",
			"GH" => "Ghana",
			"GI" => "Gibraltar",
			"GL" => "Greenland(Island)",
			"GM" => "Gambia",
			"GN" => "Guinea",
			"GOV" => "US_Government(USA)",
			"GP" => "Guadeloupe",
			"GQ" => "Equatorial_Guinea",
			"GR" => "Greece",
			"GS" => "S.Georgia_and_S.Sandwich_Isls.",
			"GT" => "Guatemala",
			"GU" => "Guam",
			"GW" => "Guinea-Bissau",
			"GY" => "Guyana",
			"HK" => "Hong Kong",
			"HM" => "Heard_and_McDonald_Islands",
			"HN" => "Honduras",
			"HR" => "Croatia",
			"HT" => "Haiti",
			"HU" => "Hungary",
			"ID" => "Indonesia",
			"IE" => "Ireland",
			"IL" => "Israel",
			"IN" => "India",
			"INT" => "International",
			"IO" => "British_Indian_Ocean_Territory",
			"IQ" => "Iraq",
			"IR" => "Iran",
			"IS" => "Iceland(Island)",
			"IT" => "Italy",
			"JM" => "Jamaica",
			"JO" => "Jordan",
			"JP" => "Japan",
			"KE" => "Kenya",
			"KG" => "Kyrgyzstan",
			"KH" => "Cambodia",
			"KI" => "Kiribati",
			"KM" => "Comoros",
			"KN" => "Saint_Kitts_and_Nevis",
			"KP" => "Korea(North)",
			"KR" => "Korea(South)",
			"KW" => "Kuwait",
			"KY" => "Cayman_Islands",
			"KZ" => "Kazakhstan",
			"LA" => "Laos",
			"LB" => "Lebanon",
			"LC" => "Saint_Lucia",
			"LI" => "Liechtenstein",
			"LK" => "Sri_Lanka",
			"LR" => "Liberia",
			"LS" => "Lesotho",
			"LT" => "Lithuania",
			"LU" => "Luxembourg",
			"LV" => "Latvia",
			"LY" => "Libya",
			"MA" => "Morocco",
			"MC" => "Monaco",
			"MD" => "Moldova",
			"MG" => "Madagascar",
			"MH" => "Marshall_Islands",
			"MIL" => "US_Military",
			"MK" => "Macedonia",
			"ML" => "Mali",
			"MM" => "Myanmar",
			"MN" => "Mongolia",
			"MO" => "Macau",
			"MP" => "Northern_Mariana_Islands",
			"MQ" => "Martinique",
			"MR" => "Mauritania",
			"MS" => "Montserrat",
			"MT" => "Malta",
			"MU" => "Mauritius",
			"MV" => "Maldives",
			"MW" => "Malawi",
			"MX" => "Mexico",
			"MY" => "Malaysia",
			"MZ" => "Mozambique",
			"NA" => "Namibia",
			"NATO" => "Nato_field",
			"NC" => "New_Caledonia",
			"NE" => "Niger",
			"NET" => "Network",
			"NF" => "Norfolk_Island",
			"NG" => "Nigeria",
			"NI" => "Nicaragua",
			"NL" => "Netherlands",
			"NO" => "Norway",
			"NP" => "Nepal",
			"NR" => "Nauru",
			"NT" => "Neutral_Zone",
			"NU" => "Niue",
			"NZ" => "New_Zealand",
			"OM" => "Oman",
			"ORG" => "US-Non-Profit_Organization(USA)",
			"PA" => "Panama",
			"PE" => "Peru",
			"PF" => "French_Polynesia",
			"PG" => "Papua_New_Guinea",
			"PH" => "Philippines",
			"PK" => "Pakistan",
			"PL" => "Poland",
			"PM" => "St.Pierre_and_Miquelon",
			"PN" => "Pitcairn",
			"PR" => "Puerto_Rico",
			"PT" => "Portugal",
			"PW" => "Palau",
			"PY" => "Paraguay",
			"QA" => "Qatar",
			"RE" => "Reunion",
			"RO" => "Romania",
			"RU" => "Russian_Federation",
			"RW" => "Rwanda",
			"SA" => "Saudi_Arabia",
			"SC" => "Seychelles",
			"SD" => "Sudan",
			"SE" => "Sweden",
			"SG" => "Singapore",
			"SH" => "St.Helena",
			"SI" => "Slovenia",
			"SJ" => "Svalbard_and_Jan_Mayen_Islands",
			"SK" => "SlovakRepublic",
			"SL" => "SierraLeone",
			"SM" => "SanMarino",
			"SN" => "Senegal",
			"SO" => "Somalia",
			"SR" => "Suriname",
			"ST" => "Sao_Tome_and_Principe",
			"SU" => "USSR(former)",
			"SV" => "ElSalvador",
			"SY" => "Syria",
			"SZ" => "Swaziland",
			"Sb" => "SolomonIslands",
			"TC" => "Turks_and_Caicos_Islands",
			"TD" => "Chad",
			"TF" => "French_Southern_Territories",
			"TG" => "Togo",
			"TH" => "Thailand",
			"TJ" => "Tajikistan",
			"TK" => "Tokelau",
			"TM" => "Turkmenistan",
			"TN" => "Tunisia",
			"TO" => "Tonga",
			"TP" => "East_Timor",
			"TR" => "Turkey",
			"TT" => "Trinidad_and_Tobago",
			"TV" => "Tuvalu",
			"TW" => "Taiwan",
			"TZ" => "Tanzania",
			"UA" => "Ukraine",
			"UG" => "Uganda",
			"UK" => "United_Kingdom",
			"UM" => "USMinor_Outlying_Islands",
			"US" => "United_States (USA)",
			"UY" => "Uruguay",
			"UZ" => "Uzbekistan",
			"VA" => "Vatican City State",
			"VC" => "Saint Vincent and the Grenadines",
			"VE" => "Venezuela",
			"VG" => "Virgin_Islands(British)",
			"VI" => "Virgin_Islands(U.S.)",
			"VN" => "Vietnam",
			"VU" => "Vanuatu",
			"WF" => "Wallis_and_FutunaIslands",
			"WS" => "Samoa",
			"YE" => "Yemen",
			"YT" => "Mayotte",
			"YU" => "Yugoslavia",
			"ZA" => "South_Africa",
			"ZM" => "Zambia",
			"ZR" => "Zaire",
			"ZW" => "Zimbabwe",
		}

		lines.each do |line|
			kwords = line.split(' ')
			time = kwords[1].split(',')
			ip = kwords[6] # the IP string
			c = GeoIP.new($GeoIP).country(ip) # <= resolv country by IP using the GeoIP database
			country = cdc[c.country_code2] # <= retrieve country from cdc hash table
			@data_table << "#{kwords[0]} #{time[0]} #{kwords[4]} #{ip} #{c.country_code2} #{country}"
		end
	end

	# print all data considered 'important' here
	def info
		entries = @data_table.size
		f2blog = File.expand_path(@log)
		fdate = "#{@data_table[0].split(' ')[0]} #{@data_table[0].split(' ')[1]}" #Firt entry date
		ldate = "#{@data_table[entries-1].split(' ')[0]} #{@data_table[entries-1].split(' ')[1]} " #Last entry date
		tdiff = Time.diff(fdate, ldate) #time diference
		ucl = [] # unique country list
		upl = [] # unique protocol list
		@data_table.each { |line| c = line.split(' ')[5]; ucl << c if ucl.include?(c) == false} # create the ucl list
		@data_table.each { |line| c = line.split(' ')[2]; upl << c if upl.include?(c) == false} # create the ucl list
		upl.size > 1 ? upl_print = upl.size.join(', ') : upl_print = upl[0]
		ban_avg = entries.to_f/((tdiff[:year] * 365) + (tdiff[:month] * 30) + (tdiff[:week] * 7) + tdiff[:day]).to_f
		sbanner = "Log file: '#{f2blog}'"
		puts "=" * sbanner.length
		puts sbanner
		puts ""
		printf("First entry: %s\n", fdate)
		printf("Last  entry: %s\n", ldate)
		printf("Time frame:\t%s\n", tdiff[:diff])
		printf("Banned IPs:\t%i\n", entries)
		printf("Countries:\t%i\n", ucl.size)
		printf("Protocol(s):\t%s\n", upl_print)
		printf("Bans per day:\t%0.2f\n\n", ban_avg)
		puts "Most banned IP(s) by fail2ban: "
		puts "-------------------------"
		puts "IP address    -   Attacks"
		puts "-------------------------"
		top_ips
		puts ""
		puts "Most hostile Countries:"
		puts "--------------------------"
		sort_by_country(5)
	end


	def top_ips
		count = Hash.new(0)
		for entry in @data_table
			count[entry.split(' ')[3]] += 1
		end
		sorted = count.sort_by {|data, no| no }.reverse
		$top_list = []
		best_count = sorted[0][1]
		ready = sorted.select { |data,no| no == best_count }
		ready.each {|line| printf("%s\t\t%s\n", line[0], line[1])}
	end

	# sort banned hosts by country
	def sort_by_country(a)
		count = Hash.new(0)
		elog = []
		@data_table.each do |x| 
			elog << "#{x.split(' ')[3]} #{x.split(' ')[5]}"
		end
		for entry in elog
			count[entry.split(' ')[1]] += 1
		end
		sorted = count.sort_by { |country, no| no }.reverse
		x = a.to_i
		if x.to_i > 0
			sorted.take(x).each {|line| puts "Country: #{line[0]} - IP(s): #{line[1]}"}
		else
			sorted.each {|line| puts "Country: #{line[0]} - IP(s): #{line[1]}"}
		end
	end

	# sort banned hosts by IP (if more than one!)
	def sort_by_ip(a)
		count = Hash.new(0)
		for entry in @data_table
			count[entry.split(' ')[3]] += 1
		end
		sorted = count.sort_by {|data, no| no }.reverse   
		a.to_i > 0 ? sorted.take(a).each{|line| puts "Received #{line[1]} attacks from #{line[0]}"} : sorted.each{|line| puts "Received #{line[1]} attacks from #{line[0]}"} 
	end

	# sort by date
	def sort_by_date(a)
		if a.to_i > 0
			@data_table.take(a).each {|line| puts line}
		else
			@data_table.each {|line| puts line}
		end
	end
end


#optparse options
options = {:no => 0}                         

optparse = OptionParser.new do |opts|

	opts.banner = "Usage: f2bread -l /path/to/fail2ban.log -s country -n 5\n"

	opts.on('-l', '--log FILE', 'Define the location of fail2ban.log. Default is /var/log/fail2ban.log') do |log|
		options[:log] = log
	end

	opts.on('-n', '--no N', Integer, 'Number of top entries to be displayed. By default all entries are displayed.') do |no|
		if no > 0
			options[:no] = no
		else
			warn "Negative value is not accepted. Using default '0'"
		end
	end

	# next version
	# opts.on('-r', '--resolv', 'Resolv hostnames on IP addresses') do |resolv|
	# options[:resolv] = resolv
	# end

	opts.on('-i', '--info', 'Display fail2ban.log summary') do |info|
		options[:info] = info
	end

	# http://ruby.about.com/od/advancedruby/a/optionparser2.htm
	options[:sort] = :yes
	opts.on('-s', '--sort OPT', [:date, :country, :ip], 'Sorts by [date, country, ip (ip frequency)]') do |sort|
		options[:sort] = sort
	end

	opts.on('-v', '--version', 'Display version') do
		puts $banner
		exit
	end

	opts.on('-h', '--help', 'Display help menu') do
		puts opts
		exit
	end
end

optparse.parse!

# adjust $logfile and $no 
if options[:log]  
	$logfile = options[:log] 
	$f2b = F2bread.new($logfile)
else	
	if File.exists?('/var/log/fail2ban.log')
		$logfile = '/var/log/fail2ban.log'
		$f2b = F2bread.new($logfile)
	else
		puts $banner
		puts "No fail2ban.log found!"
		puts "Type '#{__FILE__} -h' for help"
		exit
	end
end

if options[:no] 
	begin
		$no = Integer(options[:no])
	rescue ArgumentError
		puts "#{$no} is not an Integer!"
	else
		true
	end	
else
	$no = 0
end

# exec starts here
if options[:info]
	$f2b.info
elsif options[:sort]
	if options[:sort] == :date
		$f2b.sort_by_date($no)
	elsif options[:sort] == :country
		$f2b.sort_by_country($no)
	elsif options[:sort] == :ip
		$f2b.sort_by_ip($no)
	else
		puts "Option not recognized for '--sort', please read '--help'"
	end
else
	puts "Option not recognized. Type '#{__FILE__} -h' "
end
