require 'rest-client'
module Weather
  def self.get (zip)
    begin
      w_api = Wunderground.new
      w_api.conditions_for(zip)
    rescue => e
      $logger.error e.response
      false
    end
  end
end


# sunrise = astronomy["sun_phase"]["sunrise"]["hour"] + astronomy["sun_phase"]["sunrise"]["minute"]
# sunset = astronomy["sun_phase"]["sunset"]["hour"] + astronomy["sun_phase"]["sunset"]["minute"]
# now = Time.now.hour.to_s + Time.now.min.to_s
