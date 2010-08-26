require 'rubygems'
require 'sinatra'
require 'yaml'
require 'haml'
require 'sass'
require 'factory'

places = YAML::load_file("locations.yml")

factory = Ra_finder.new
twitter = factory.twitter
rhittime = factory.timezone
cal = factory.google_cal

get '/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/' do
  place = twitter.most_recent_tweet
  @events = factory.google_cal.upcoming_events
  @tz = factory.timezone
  @todays_events = factory.google_cal.todays_events

  if places.keys.include?(place)
    
    @nick_line = "Nick is #{places[place]['prefix']} #{places[place]['label']}"

    @url = "http://maps.google.com/maps/api/staticmap?center=#{places[place]['lat']},#{places[place]['long']}\
            &zoom=18&size=400x400&sensor=false&maptype=satellite".gsub(/ /, "")

    haml :index
  else
    @nick_line = "Nick is in #{place}"

    haml :unkown_tweet
  end
end
