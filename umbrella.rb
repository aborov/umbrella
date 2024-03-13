require "http"
require "json"

  # get_location_from_user
    puts "\nWelcome to Umbrella Advice"
    puts "Let's see if you need an umbrella today."
    puts "Tell us where you are located:"
    user_location = gets.chomp.gsub(" ", "+")
  

  # get_coordinates
    gmaps_api_key = ENV.fetch("GMAPS_KEY")
    gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps_api_key}"
    gmaps_raw = HTTP.get(gmaps_url)
    gmaps_parsed = JSON.parse(gmaps_raw)
    lat_lng = gmaps_parsed['results'][0]['geometry']['location']
    lat = lat_lng['lat']
    lng = lat_lng['lng']
  
  # get_weather
    pirate_api_key = ENV.fetch("PIRATE_WEATHER_KEY")
    pirate_url = "https://api.pirateweather.net/forecast/#{pirate_api_key}/#{lat},#{lng}"
    pirate_raw = HTTP.get(pirate_url)
    pirate_parsed = JSON.parse(pirate_raw)

  # prep_temperature
    current_temp = pirate_parsed['currently']['temperature']
  
  pp current_temp
