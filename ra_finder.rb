require 'rubygems'
require 'twitter'
require 'sinatra'
require 'yaml'
require 'haml'

config = YAML::load_file("config.yml")
places = YAML::load_file("locations.yml")

oauth = Twitter::OAuth.new(config['consumer_token'], config['consumer_secret'])
oauth.authorize_from_access(config['access_token'], config['access_secret']) 

client = Twitter::Base.new(oauth)

get '/' do
  #get most text from most recent tweet
  place = client.user_timeline[0][:text]

  if places.keys.include?(place)
    latitude = places[place]['lat']
    longitude = places[place]['long']
    prefix = places[place]['prefix']
    label = places[place]['label']

    @nick_line = "Nick is #{prefix} #{label}"

    @url = "http://maps.google.com/maps/api/staticmap?center=#{latitude},#{longitude}\
            &zoom=18&size=400x400&sensor=false&maptype=satellite".gsub(/ /, "")

    @events = events

    haml :index
  else
    "<h1>Nick is #{prefix} #{place}<h1>Floor Events:</h1>" + events
  end
end

def events
  events = YAML::load_file("events.yml")

  events.inject([]) do |result, (event, data)|
    result << [data['label'], data['time'], data['month'], data['day']]
  end
end
