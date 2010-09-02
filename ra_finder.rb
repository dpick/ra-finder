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

get '/fun' do
  place = twitter.most_recent_tweet
  @events = cal.upcoming_events
  @todays_events = cal.todays_events
  @tz = factory.timezone

  if places.keys.include?(place)
    
    @nick_line = "Nick is fucking a goat #{places[place]['prefix']} #{places[place]['label']}"

    @url = factory.url(places[place]['lat'], places[place]['long'])

    haml :index
  else
    @nick_line = "Nick is fucking a goat in #{place}"

    haml :unkown_tweet
  end
end

get '/' do
  begin
    place = twitter.most_recent_tweet
    @events = cal.upcoming_events
    @todays_events = cal.todays_events
    @tz = factory.timezone
  rescue
    @events = []
    @todays_events = []
    @tz = factory.timezone
    @nick_line = "We can't find Nick right now, try his cell phone 317-501-0434"
  end

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
  @events = cal.upcoming_events
  @todays_events = cal.todays_events
  @tz = factory.timezone
  haml :events
end
