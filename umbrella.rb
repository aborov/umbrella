require "http"
require "json"

# get location from user
  puts "\nWelcome to Umbrella Advice"
  puts "Let's see if you need an umbrella today."
  puts "Tell us where you are located:"
  location = gets.chomp
  user_location = location.gsub(" ", "+")
  
# report on location  
  puts "Alright, let's check the weather at #{location}..."

# get coordinates
  gmaps_api_key = ENV.fetch("GMAPS_KEY")
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps_api_key}"
  gmaps_raw = HTTP.get(gmaps_url)
  gmaps_parsed = JSON.parse(gmaps_raw)
    if gmaps_parsed['status'] == 'OK'
      lat_lng = gmaps_parsed['results'][0]['geometry']['location']
      lat = lat_lng['lat']
      lng = lat_lng['lng']
      puts "Your coordinates are #{lat}, #{lng}"
    else
      puts "Sorry, we can't get your location coordinates at the moment. Try later."
      exit
    end
  
# get weather
  pirate_api_key = ENV.fetch("PIRATE_WEATHER_KEY")
  pirate_url = "https://api.pirateweather.net/forecast/#{pirate_api_key}/#{lat},#{lng}"
  pirate_raw = HTTP.get(pirate_url)
  pirate_parsed = JSON.parse(pirate_raw)
    if pirate_parsed.key?('hourly')
      hourly_forecast = pirate_parsed['hourly']['data']
    else
      puts "Sorry, we can't get the weather at your location right now. Try later."
      exit
    end

# give temperature
  current_temp = pirate_parsed['currently']['temperature']
  degree_sign = "\u00B0"
  puts "Right now, it's #{current_temp}#{degree_sign}F outside."
  
# give next hour
  summary = pirate_parsed['hourly']['summary']
  puts "In the next hour, it's going to be: #{summary}"

# give next 12 hours
  puts "Forecast for the next 12 hours:"
  current_time = Time.now
  current_hour_index = hourly_forecast.index { |hour_data| Time.at(hour_data['time']).hour == current_time.hour }
  forecast_12_hours = hourly_forecast[current_hour_index, 13]
  forecast_12_hours.shift
  forecast_12_hours.each_with_index do |hour_data, index|
    forecast_time = Time.at(hour_data['time'])
    hours_from_now = ((forecast_time - current_time) / 3600).round
    precipitation_probability = hour_data['precipProbability']
    if precipitation_probability > 0.1
      puts "In #{hours_from_now} hours, there is a #{(precipitation_probability * 100).round}% chance of precipitation."
    end
  end

# umbrella advice  
  if forecast_12_hours.any? { |hour_data| hour_data['precipProbability'] > 0.1 }
    puts "You might want to carry an umbrella!"
  else
    puts "You probably won’t need an umbrella today."
  end
