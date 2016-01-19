require 'rest-client'
module Camera
  def self.pushover(title, message)
    uri = URI.encode('https://api.pushover.net/1/messages.json')
    app_key = $config['pushover_app_key']
    user_key = $config['pushover_user_key']
    begin
      response = RestClient.post uri, token: app_key, user: user_key, title: title, message: message
      $logger.debug response.body
    rescue => e
      $logger.error e.response
      e.response
    end
  end
  def self.find(name)
    return $cameras.find {|s| s.name == name}
  end
  class DS2CD2032
    OVERLAY_PATH = '/Video/inputs/channels/1/overlays/text/1'
    SHUTTER_PATH = '/Image/channels/1/Shutter'
    @@array = Array.new
    attr_accessor :name, :hostname, :credits, :zip, :state, :no_osd
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

    def set_osd(message)
      xml = '<?xml version="1.0" encoding="UTF-8"?>' \
             '<TextOverlay version="1.0" xmlns="http://www.hikvision.com/ver10/XMLSchema">' \
             '<id>1</id>' \
             '<enabled>true</enabled>' \
             '<posX>16</posX>' \
             '<posY>0</posY>' \
             "<message>#{message}</message>" \
             '</TextOverlay>'
      endpoint = "http://#{@hostname}#{OVERLAY_PATH}"
      begin
        private_resource = RestClient::Resource.new endpoint, $config['hikvision_username'], $config['hikvision_password']
        private_resource.put xml, :content_type => 'application/xml'
      rescue => e
        $logger.error e.response
      end
    end
  end
end
