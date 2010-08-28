require 'rubygems'
require 'sinatra'
require 'yaml'
require 'haml'
require 'sass'
require 'factory'

places = YAML::load_file("locations.yml")

factory = Ra_finder_factory.new
twitter = factory.twitter
cal = factory.google_cal

get '/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/' do
  place = twitter.most_recent_tweet
  @events = factory.google_cal.upcoming_events
  @todays_events = factory.google_cal.todays_events
  @tz = factory.timezone

  if places.keys.include?(place)
    
    @nick_line = "Nick is #{places[place]['prefix']} #{places[place]['label']}"

    @url = factory.url(places[place]['lat'], places[place]['long'])

    haml :index
  else
    @nick_line = "Nick is in #{place}"

    haml :unkown_tweet
  end
end

get '/events' do
  @events = factory.google_cal.upcoming_events
  @todays_events = factory.google_cal.todays_events
  @tz = factory.timezone
  haml :events
end
