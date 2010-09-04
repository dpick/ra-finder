require 'yaml'
require 'gcal4ruby'
require 'time'

class Google_cal
  def initialize
    config = YAML::load_file("config.yml")
    service = GCal4Ruby::Service.new
    service.authenticate(config['gcal_email'], config['gcal_password'])
    @cal = GCal4Ruby::Calendar.find(service, config['gcal_id'], {:scope => :first})
    @on_duty = GCal4Ruby::Calendar.find(service, config['on_duty_id'], {:scope => :first})
  end

  @@instance = Google_cal.new

  def self.instance
    @@instance
  end

  def on_duty
    @on_duty.events[0].title
  end

  def upcoming_events
    params = {:singleevents => true, :range => {:start => tomorrow8am, :end => one_month}}
    events = GCal4Ruby::Event.find(@cal, "", params)
    sort_events(events)[0, 5]
  end

  def todays_events
    params = {:singleevents => true, :range => {:start => Time.now, :end => tomorrow8am}}
    events = GCal4Ruby::Event.find(@cal, "", params)
    sort_events(events)
  end

  def all_events
    events = GCal4Ruby::Event.find(@cal, "", {:singleevents => true})
    sort_events(events)
  end

  def tomorrow8am
    Time.parse("8:00 am") + 86400
  end

  def one_month
    Time.now + 2629743
  end

  def end_of_year
    Time.parse("June 1st 2011")
  end

  def sort_events(events)
    events.sort! {|x, y| x.start <=> y.start }
  end
end
