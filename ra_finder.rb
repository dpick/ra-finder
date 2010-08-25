require 'rubygems'
require 'sinatra'
require 'yaml'
require 'haml'
require 'sass'
require 'factory'

## LOAD CONFIG FILES

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
  @events = factory.google_cal.events
  @tz = factory.timezone
  @event_url = event_url
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

## CUSTOM METHODS
def event_url
  "http://feed2js.org//feed2js.php?src=http%3A%2F%2Fwww.google.com
  %2Fcalendar%2Ffeeds%2Fo9kv0en2oa8n13pfr1ehepm0d8%2540group.
  calendar.google.com%2Fpublic%2Fbasic&num=5&desc=1&utf=y".gsub(/ /, "")
end
