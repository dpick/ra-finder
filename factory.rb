require 'tzinfo'
require 'yaml'
require 'time'
require 'google'
require 'twitter_client'

class Ra_finder_factory
  def twitter
    Twitter_Client.instance
  end

  def timezone
    TZInfo::Timezone.get('America/Indiana/Indianapolis')
  end

  def google_cal
    Google_cal.instance
  end

  def url(lat, long)
    "http://maps.google.com/maps/api/staticmap?center=#{lat},#{long}\
     &zoom=18&size=400x400&sensor=false&maptype=satellite".gsub(/ /, "")
  end
end
