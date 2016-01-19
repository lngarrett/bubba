require 'rest-client'
module Camera
  def self.pushover(title, message)
    uri = URI.encode('https://api.pushover.net/1/messages.json')
    app_key = $config['pushover_app_key']
    user_key = $config['pushover_user_key']
    begin
      response = RestClient.post uri, token: app_key, user: user_key, title: title, message: message
      $logger.info response.body
    rescue => e
      $logger.error e.response
      e.response
    end
  end
  class DS2CD2032
    @@array = Array.new
    attr_accessor :name, :hostname, :credits
    def initialize(h)
      h.each {|k,v| send("#{k}=",v)}
      @@array << self
    end

    def self.increment_all
      @@array.each do |camera|
        camera.increment
      end
    end

    def decrement
      @credits -= 1 unless @credits == 0
    end

    def increment
      @credits += 1 unless @credits == $config['credit_full']
    end

    def motion_alert
      if @credits > 0
        title = @name.sub('cam', '').capitalize + ' Camera'
        message = "Motion Detected"
        decrement
        message << " (Credit Exhausted)" unless @credits > 0
        Camera::pushover(title, message)
      else
        {message: 'No credits available. Alert not sent.'}.to_json
      end

    end
  end
end
