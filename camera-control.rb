require 'sinatra'
require 'rest-client'
require 'redis'

@redis = Redis.new

def pushover(message)
  uri = URI.encode("https://api.pushover.net/1/messages.json")
  appKey = @redis.get "config:pushover:app-key"
  userKey = @redis.get "config:pushover:user-key"
  RestClient.post uri, { :token => appKey, :user => userKey, :message => message }
end

def alert(camera, alertType)
  key = camera + ":alerts:" + alertType
  score = Time.now.to_i
  data = score
  @redis.zadd(key, data, score)
end

def countPastAlerts(camera, alertType, minutes)
  key = camera + ":alerts:" + alertType
  now = Time.now.to_i
  past = Time.now.to_i - (minutes * 60)
  puts @redis.zcount(key, past, now)
end

def checkCoolDown
  key = camera + ":alerts:" + alertType + ":cooldown"
    
end

get '/' do
  "Hello, World"
end

$i = 0
$num = 5

while $i < $num  do
   puts("Inside the loop i = #$i" )
   $i +=1
end 