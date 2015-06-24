require 'sinatra'
require 'rest-client'
require 'redis' 
require 'yaml'
require 'json'
require 'thin'

set :server, 'thin'
$redis = Redis.new
$config = YAML.load_file('config.yaml')["config"]

$count = 0

Thread.new do # Background tasks
  #seedRedis
  #fullCredit
  while true do
    sleep $config["credit"]["interval"]
    #incrCredit
    $count += 1
  end
end

get '/' do
  "Testing background work thread: sum is #{$count}"
end

#get '/' do
#  $put = $redis.hget("cameras:frontcam", :name) + " " + $redis.hget("cameras:frontcam", :credit) + " " + $count.to_s + " " + $config["credit"]["interval"].to_s
#  "#{$put}"
#end

get '/:camera/motion' do
  camera = params[:camera]
  alertMotion(camera)
end

def pushover(message)
  uri = URI.encode("https://api.pushover.net/1/messages.json")
  appKey = $redis.get "config:pushover:app-key"
  userKey = $redis.get "config:pushover:user-key"
  RestClient.post uri, { :token => appKey, :user => userKey, :message => message }
end

def seedRedis
  cameras = YAML.load_file('config.yaml')["camera"]
  cameras.each do |camera|
    name = camera['name']
    hostname = camera['hostname']
    $redis.hsetnx("cameras:#{name}", :name, camera['name'])
    $redis.hsetnx("cameras:#{name}", :hostname, camera['hostname'])
  end
end

def fullCredit
  cameras = $redis.keys("*cameras*").map { |camera| $redis.hgetall(camera) }
  cameras.each do |camera|
    name = camera["name"]
    $redis.hset("cameras:#{name}", :credit, $config["credit"]["full"])
  end
end

def incrCredit
  cameras = $redis.keys("*cameras*").map { |camera| $redis.hgetall(camera) }
  cameras.each do |camera|
    name = camera["name"]
    credit = camera["credit"]
    $redis.hincrby("cameras:#{name}", :credit, $config["credit"]["increment"]) unless credit >= $config["credit"]["full"]
  end
end

def decrCredit(camera)
  credit = camera["credit"]
  $redis.hincrby("cameras:#{camera}", :credit, -1) unless credit == 0
end

def alertMotion(camera)
  credit = $redis.hget("cameras:#{camera}", :credit)
  if credit.to_i > 0 
    pushover("#{camera} alert #{credit}")
    decrCredit(camera)
  end
end
