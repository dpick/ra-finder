require 'twitter'
require 'yaml'

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
    @client.user_timeline[0][:text] =~ /#([A-Za-z0-9']*)/
    return $1
  end
end
