require 'twitter'
require 'gcal4ruby'
require 'tzinfo'
require 'yaml'
require 'time'

class Ra_finder
  def twitter
    Twitter_Client.instance
  end

  def timezone
    TZInfo::Timezone.get('America/Indiana/Indianapolis')
  end

  def google_cal
    Google_cal.instance
  end
end

class Twitter_Client
  def initialize
    config = YAML::load_file("config.yml")
    oauth = Twitter::OAuth.new(config['consumer_key'], config['consumer_secret'])
    oauth.authorize_from_access(config['access_key'], config['access_secret']) 

    @client = Twitter::Base.new(oauth)
  end

  @@instance = Twitter_Client.new

  def self.instance
    @@instance
  end

  def most_recent_tweet
    @client.user_timeline[0][:text]
  end
end

class Google_cal
  def initialize
    config = YAML::load_file("config.yml")
    @service = GCal4Ruby::Service.new
    @service.authenticate(config['gcal_email'], config['gcal_password'])
    @id = config['gcal_id']
  end

  @@instance = Google_cal.new

  def self.instance
    @@instance
  end

  def events
    events(Time.now)
  end

  def upcoming_events
    tomorrow8am = Time.parse("8:00 am") + 86400
    events(tomorrow8am)
  end

  def events(start_time)
    events = GCal4Ruby::Event.find(@service, "", {:calendar => @id, 'start-min' => start_time.utc.xmlschema})
    events.sort! { |x, y| x.start_time <=> y.start_time }
  end

  def todays_events
    now = Time.now.utc.xmlschema
    tomorrow8am = (Time.parse("8:00 am") + 86400).utc.xmlschema

    events = GCal4Ruby::Event.find(@service, "", {:calendar => @id, 'start-min' => now, 'start-max' => tomorrow8am})
    events.sort! { |x, y| x.start_time <=> y.start_time }
  end
end
