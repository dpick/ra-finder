require 'yaml'
require 'gcal4ruby'
require 'time'

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

  def all_events
    sort_events(@cal.events)
  end

  def tomorrow8am
    Time.parse("8:00 am") + 86400
  end

  def sort_events(events)
    events.sort! {|x, y| x.start_time <=> y.start_time }
  end
end
