require 'rubygems'
require 'twitter'
require 'sinatra'
require 'yaml'
require 'haml'
require 'sass'
require 'gcal4ruby'
require 'tzinfo'

## LOAD CONFIG FILES

places = YAML::load_file("locations.yml")
config = YAML::load_file("config.yml")

## Initialize Twitter

oauth = Twitter::OAuth.new(config['consumer_key'], config['consumer_secret'])
oauth.authorize_from_access(config['access_key'], config['access_secret']) 

client = Twitter::Base.new(oauth)

## Initialize Time Zone

rhittime = TZInfo::Timezone.get('America/Indiana/Indianapolis')

## Initialize Google Calendar

service = GCal4Ruby::Service.new
service.authenticate(config['gcal_email'], config['gcal_password'])

cal = GCal4Ruby::Calendar.find(service, {:id => config['gcal_id']})


@calendars = service.calendars

## ROUTES

get '/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/' do
  #get most text from most recent tweet
  place = client.user_timeline[0][:text]
  @events = cal.events
  @tz = rhittime
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

## CUSTOM METHODS

def event_url
  "http://feed2js.org//feed2js.php?src=http%3A%2F%2Fwww.google.com
  %2Fcalendar%2Ffeeds%2Fo9kv0en2oa8n13pfr1ehepm0d8%2540group.
  calendar.google.com%2Fpublic%2Fbasic&num=5&desc=1&utf=y".gsub(/ /, "")
end
