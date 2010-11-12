require 'rubygems'
require 'sinatra'
require 'yaml'
require 'haml'
require 'sass'
require 'factory'
require 'weather'

places = YAML::load_file("locations.yml")

factory = Ra_finder_factory.new
twitter = factory.twitter
cal = factory.google_cal
weather = Weather.new

get '/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/' do
  begin
    place = twitter.most_recent_tweet
    @events = cal.upcoming_events
    @todays_events = cal.todays_events
    @tz = factory.timezone
    @on_duty = cal.on_duty.title
    @on_duty_phone = cal.on_duty.content
  rescue
    @events = []
    @todays_events = []
    @tz = factory.timezone
    @on_duty = "Check the whiteboard to see who is on duty"
    @on_duty_phone = ""
    @nick_line = "We can't find Nick right now, try his cell phone 317-501-0434"
  end
  @THTemp = weather.getTemp
  @THFeels = weather.getFeelsLike

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
