# backup all of the stuff from sprintly projects to json

require 'httparty'
require 'json'

# read config file
# config format:
#	USER=youremail@domain.com
#	API_KEY=your_sprintly_api_key

# connecting to the sprintly API

File.readlines("sprintly-config").each do |line|
	
	# trim newlines
	line.strip!
	
	config = line.split('=')
	
	if config[0] == "USER"
		USER = config[1]
	elsif config[0] == "API_KEY"
		API_KEY = config[1]
	else
		puts "unrecognized config option!"
	end
	
end

# set up auth for making request
auth = {:username => USER, :password => API_KEY}

# getting the project list and backing it up
response = HTTParty.get("https://sprint.ly/api/products.json", :basic_auth => auth)
products = JSON.parse(response.body)

if File.directory?("./backup")

else
	Dir.mkdir("backup")
end

file = File.open("./backup/products.json","w")
file.write(products)
file.close

# create directories for the file formats
if File.directory?("./backup/csv")

else
	Dir.mkdir("./backup/csv")
end

if File.directory?("./backup/json")

else
	Dir.mkdir("./backup/json")
end

# write the CSV backup for each
products.each do |product|

	# CSV
	url = "https://sprint.ly/api/products/" + product['id'].to_s + "/items.csv?status=backlog,in-progress,completed,accepted&children=true"
	
	response = HTTParty.get(url, :basic_auth => auth)
	
	file_path = "./backup/csv/" + product['name'] + ".csv"
	
	file = File.open(file_path,"w")
	file.write(response.body)
	file.close

	# JSON
	url = "https://sprint.ly/api/products/" + product['id'].to_s + "/items.json?status=backlog,in-progress,completed,accepted&children=true"
	
	response = HTTParty.get(url, :basic_auth => auth)
	
	file_path = "./backup/json/" + product['name'] + ".json"
	
	file = File.open(file_path,"w")
	file.write(response.body)
	file.close
	
end