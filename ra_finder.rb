require 'rubygems'
require 'twitter'
require 'sinatra'
require 'yaml'
require 'haml'

places = YAML::load_file("locations.yml")
config = YAML::load_file("config.yml")

oauth = Twitter::OAuth.new(config['consumer_key'], config['consumer_secret'])
oauth.authorize_from_access(config['access_key'], config['access_secret']) 

client = Twitter::Base.new(oauth)

get '/' do
  #get most text from most recent tweet
  place = client.user_timeline[0][:text]

  if places.keys.include?(place)

    @nick_line = "Nick is #{places[place]['prefix']} #{places[place]['label']}"

    @url = "http://maps.google.com/maps/api/staticmap?center=#{places[place]['lat']},#{places[place]['long']}\
            &zoom=18&size=400x400&sensor=false&maptype=satellite".gsub(/ /, "")

    @event_url = event_url

    haml :index
  else
    @nick_line = "Nick is in #{place}"
    @event_url = event_url

    haml :unkown_tweet
  end
end

def event_url
  "http://www.google.com/calendar/embed?height=600&amp;wkst=1&amp;bgcolor=%23FFFFFF&amp;src=o9kv0en2oa8n13pfr1ehepm0d8%40\
   group.calendar.google.com&amp;color=%238C500B&amp;ctz=America%2FNew_York".gsub(/ /, "")
end
