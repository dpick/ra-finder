require 'twitter'
require 'yaml'

class Twitter_Client
  @@instance = Twitter_Client.new

  def self.instance
    @@instance
  end

  def most_recent_tweet
    Twitter.timeline('predanfinder')[0].text =~ /#([A-Za-z0-9']*)/
    return $1
  end
end
