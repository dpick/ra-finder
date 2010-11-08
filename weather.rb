require 'yaml'
require 'rubygems'
require 'r_weather'

class Weather
  def initialize
    config = YAML::load_file("config.yml")
    RWeather.partner_id = config['weather_partner_id']
    RWeather.key = config['weather_key']
    @locations = RWeather.search(config['location']) # that's where I'm from :)
    getWeather
  end
  
  def getWeather
    unless @locations.empty?
      @cc = RWeather.current_conditions(@locations.first.id)
    end
  end
  
  def getTemp
    begin
      return getWeather.tmp
    rescue
      return "N/A"
    end
  end
  
  def getFeelsLike
    begin
      return getWeather.flik
    rescue
      return "N/A"
    end
  end
end