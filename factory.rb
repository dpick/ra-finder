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
    events = sort_events(events)
    
    goodevents = Array.new
    # We want all events today
    events.each do |event|
      goodevents << Good_Event.new(event.title, event.content, event.where, event.start_time, event.end_time)
    end
    goodevents
  end
  
  def all_events
    events = @cal.events
    sort_events(events)
  end
  
  def recurring_events(start_time, end_time)
    events = Array.new
    sort_events(@cal.events).each do |event|
      if event.recurrence && event.start_time < start_time && event.end_time > end_time
        events << event
      end
    end
    events
  end
  
  def tomorrow8am
    Time.parse("8:00 am") + 86400
  end

  def sort_events(events)
    events.sort! {|x, y| x.start_time <=> y.start_time }
  end
end

class Good_Event
  attr_accessor :title, :content, :where, :start, :end, :length
  
  def initialize(title, content, where, start_time, end_time)
    @title = title
    @content = content
    @where = where
    @start_time = start_time
    @end_time = end_time
  end
  
  def title
    @title
  end
  def title=(title)
    @title = title
  end
  
  def start
    @start_time
  end
  def start=(start_time)
    @start_time = start_time
  end
  
  def end
    @end_time
  end
  def end=(end_time)
    @end_time = end_time
  end

  def length
    event_length = (@end_time - @start_time)/3600
    if event_length.to_i == event_length
      if event_length.to_i == 1
        event_length.to_i.to_s + " hour"
      else
        event_length.to_i.to_s + " hours"
      end
    else
      event_length.to_s + " hours"
    end
  end
  
  def content
    @content
  end
  def content=(content)
    @content = content
  end
  
  def where
    @where
  end
  def where=(where)
    @where = where
  end
end
