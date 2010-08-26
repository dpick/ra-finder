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
    @cal = GCal4Ruby::Calendar.find(@service, {:id => config['gcal_id']})
  end

  @@instance = Google_cal.new

  def self.instance
    @@instance
  end

  def upcoming_events
    events = @cal.events.select { |event| event.start_time > tomorrow8am }
    sort_events(events)
  end

  def todays_events
    events = @cal.events.select {|event| event.start_time > Time.now and event.start_time < tomorrow8am}
    sort_events(events)
  end

  def tomorrow8am
    Time.parse("8:00 am") + 86400
  end

  def sort_events(events)
    events.sort! {|x, y| x.start_time <=> y.start_time }
  end
end
