require 'rubygems'
require 'twitter'
require 'sinatra'
require 'yaml'
require 'haml'

oauth = Twitter::OAuth.new('wPdV9dxIf8FG9JYB85gmQ', 'rdnDyDmIBMjIyp9Gf4q0uv2XgxJufEUCtUQYiBGJbM')
#consumer token, consumer secret
oauth.authorize_from_access('179202727-9UnILM65JaAEobvyXdJOlDB1AA0Bu8JXoxfNb85J', 'JLhDdvRyUVIVnrJRJdQy7qqw2RrVrihWLZnpProA')
#access token, access secret

client = Twitter::Base.new(oauth)
places = YAML::load_file("locations.yml")

get '/' do
  #get most text from most recent tweet
  place = client.user_timeline[0][:text]

  if places.keys.include?(place)
    latitude = places[place]['lat']
    longitude = places[place]['long']
    @nick_line = "Nick is in #{places[place]['label']}"

    @url = "http://maps.google.com/maps/api/staticmap?center=#{latitude},#{longitude}\
            &zoom=18&size=400x400&sensor=false&maptype=satellite".gsub(/ /, "")

    haml :index
  else
    "Nick is in #{place}"
  end
end
