require 'rest-client'
module Weather
  def self.get (type, zip, state)
    location = "/q/#{state}/#{zip}.json"
    path = 'astronomy'
    path = 'geolookup/conditions' if type == :conditions
    path << location
    uri = URI.encode("http://api.wunderground.com/api/#{$config["wunderground_key"]}/#{path}")
    begin
      response = RestClient.get uri
      response.body
    rescue => e
      $logger.error e.response
      e.response
    end
  end
end


# sunrise = astronomy["sun_phase"]["sunrise"]["hour"] + astronomy["sun_phase"]["sunrise"]["minute"]
# sunset = astronomy["sun_phase"]["sunset"]["hour"] + astronomy["sun_phase"]["sunset"]["minute"]
# now = Time.now.hour.to_s + Time.now.min.to_s
