require 'sinatra'
require 'rest-client'
require 'redis'
require 'haml'
require 'thin'

set :server, 'thin'
$redis = Redis.new

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

get('/cameras') do
  @cameras = $redis.keys("*cameras*").map { |camera| JSON.parse($redis.get(camera))}
  haml :"cameras/index"
end

get('/cameras/new') do
  haml :"cameras/new"
end

post('/cameras') do
  index = $redis.incr("camera:index")
  name = params[:name]
  hostname = params[:hostname]

  camera = {name: name, id: index, hostname: hostname}
  $redis.set("cameras:#{index}", camera.to_json)
  redirect to ("/cameras")
end

get('/cameras/:id/edit') do
  id = params[:id]
  unparsed_db_camera=$redis.get("cameras:#{id}")
  @camera = JSON.parse(unparsed_db_camera)
  haml :"cameras/edit"
end

get('/cameras/:id/') do
  id = params[:id]
  unparsed_db_camera=$redis.get("cameras:#{id}")
  @camera = JSON.parse(unparsed_db_camera)
  haml :"cameras/view"
end

put('/cameras/:id') do
  index = params[:id]
  name = params[:name]
  hostname = params[:hostname]

  edited_camera = {name: name, id: index, hostname: hostname}
  $redis.set("cameras:#{index}", edited_camera.to_json)
  redirect to ("/cameras")
end