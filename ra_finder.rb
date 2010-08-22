require 'rubygems'
require 'twitter'
require 'sinatra'
require 'yaml'
require 'haml'
require 'pp'

oauth = Twitter::OAuth.new('XCnumRZrZ1mOMCu0EeRR4Q', 'RvlV7hqpL7Japz94yoEBF4bfsu5IXr9kq07arAMMJc')
#consumer token, consumer secret
oauth.authorize_from_access('170965648-xoS36VNMRxILk8WURuENuJdLwJpQxcAXFuk5Dlj7', 'GAghkKqArkOYqwfjq1qYqBLy5F8rh25o5uECY44o')
#access token, access secret

client = Twitter::Base.new(oauth)
places = YAML::load_file("locations.yml")
$events = YAML::load_file("events.yml")

get '/' do
  #get most text from most recent tweet
  place = client.user_timeline[0][:text]

  if places.keys.include?(place)
    latitude = places[place]['lat']
    longitude = places[place]['long']
    prefix = places[place]['prefix']
    @nick_line = "Nick is #{prefix} #{places[place]['label']}"

    @url = "http://maps.google.com/maps/api/staticmap?center=#{latitude},#{longitude}\
            &zoom=18&size=400x400&sensor=false&maptype=satellite".gsub(/ /, "")

    @events = events

    haml :index
  else
    "<h1>Nick is #{prefix} #{place}<h1>Floor Events:</h1>" + events
  end
end

def events
  $events.inject([]) do |result, (event, data)|
    result << [data['label'], data['time'], data['month'], data['day']]
  end
end
