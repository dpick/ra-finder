require 'twitter'
require 'gcal4ruby'
require 'tzinfo'
require 'yaml'
require 'time'

class Ra_finder
  def initialize
    @config = YAML::load_file("config.yml")
  end

  def twitter
    if defined? @@twitter_client
      @@twitter_client
    else
      @@twitter_client = Twitter_Client.new(@config['consumer_key'], @config['consumer_secret'], @config['access_key'], @config['access_secret'])
    end
  end

  def timezone
    TZInfo::Timezone.get('America/Indiana/Indianapolis')
  end

  def google_cal
    if defined? @@google_cal
      @@google_cal
    else
      @@google_cal = Google_cal.new(@config['gcal_email'], @config['gcal_password'], @config['gcal_id'])
    end
  end
end

class Twitter_Client
  def initialize(consumer_key, consumer_secret, access_key, access_secret)
    oauth = Twitter::OAuth.new(consumer_key, consumer_secret)
    oauth.authorize_from_access(access_key, access_secret) 

    @client = Twitter::Base.new(oauth)
  end

  def most_recent_tweet
    @client.user_timeline[0][:text]
  end
end

class Google_cal
  def initialize(email, pass, id)
    @service = GCal4Ruby::Service.new
    @service.authenticate(email, pass)
    @id = id
  end

  def events
    #all events from now on
    events(Time.now)
  end

  def upcoming_events
    #events occuring after today
    tomorrow8am = Time.parse("8:00 am")
    tomorrow8am = tomorrow8am + 86400
    events(tomorrow8am)
  end

  def events(start_time)
    events = GCal4Ruby::Event.find(@service, "", {:calendar => @id, 'start-min' => start_time.utc.xmlschema})
    events.sort! { |x, y| x.start_time <=> y.start_time }
  end

  def todays_events
    now = Time.now.utc.xmlschema
    midnight = (Time.parse("11:59 pm")).utc.xmlschema
    tomorrow8am = Time.parse("8:00 am")
    tomorrow8am = tomorrow8am + 86400
    tomorrow8am = tomorrow8am.utc.xmlschema

    events = GCal4Ruby::Event.find(@service, "", {:calendar => @id, 'start-min' => now, 'start-max' => tomorrow8am})
    events.sort! { |x, y| x.start_time <=> y.start_time }
  end
end
