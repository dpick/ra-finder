require 'twitter'
require 'gcal4ruby'
require 'tzinfo'
require 'yaml'

class Ra_finder
  def initialize
    @config = YAML::load_file("config.yml")
  end

  def twitter
    Twitter_Client.new(@config['consumer_key'], @config['consumer_secret'], @config['access_key'], @config['access_secret'])
  end

  def timezone
    TZInfo::Timezone.get('America/Indiana/Indianapolis')
  end

  def google_cal
    Google_cal.new(@config['gcal_email'], @config['gcal_password'], @config['gcal_id'])
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

  def cal
    GCal4Ruby::Calendar.find(@service, {:id => @id})
  end

  def events
    cal.events.sort! {|x, y| x.start_time <=> y.start_time}
  end

  def todays_events
    now = Time.now.utc.xmlschema
    tomorrow = (Time.now + 86400).utc.xmlschema

    return GCal4Ruby::Event.find(@service, "", {:calendar => @id, 'start-min' => now, 'start-max' => tomorrow})
  end
end
