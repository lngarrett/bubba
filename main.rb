#!/usr/bin/env ruby
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'yaml'
require 'json'
require 'camera'
require 'weather'
require 'sinatra'
require 'thin'
require 'wunderground'


set :server, 'thin'
set :bind, '0.0.0.0'

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG

$sum = 0

$config  = YAML.load_file('config.yaml')['config']
$config['pushover_app_key']   = ENV['pushover_app_key']
$config['pushover_user_key']  = ENV['pushover_user_key']
$config['wunderground_key']   = ENV['wunderground_key']
$config['hikvision_username'] = ENV['hikvision_username']
$config['hikvision_password'] = ENV['hikvision_password']

$cameras = YAML.load_file('config.yaml')['cameras']

$cameras.map! { |camera|
  camera[:credits] = $config['credit_full']
  Camera::DS2CD2032.new(camera)
}

Thread.new do
  loop do
    $logger.debug "Waking to increment credits"
    Camera::DS2CD2032.increment_all
    $logger.debug "Incremented credits. Sleeping #{$config['credit_interval']}..."
    sleep $config['credit_interval']
  end
end

Thread.new do
  loop do
    $logger.debug "Waking to check weather."
    $cameras.each do |camera|
      unless camera.no_osd
        begin
          conditions = Weather::get(camera.zip)
        rescue => e
          $logger.error "Could not get conditions for #{camera.name}: #{e.message}"
        end
        temp_f        = conditions['current_observation']['temp_f']
        wind_mph      = conditions['current_observation']['wind_mph']
        wind_gust_mph = conditions['current_observation']['wind_gust_mph']
        message = "#{temp_f}°Wind #{wind_mph}/#{wind_gust_mph}MPH"
        begin
          camera.set_osd(message)
          $logger.debug "Updated OSD: #{message}"
        rescue => e
          $logger.error "Could not sed OSD on #{camera.name}: #{e.message}"
        end
      end
    end
    $logger.debug "Sleeping 10 minutes..."
    sleep 600
  end
end

get '/camera/:camera_name/motion' do
  $cameras.find {|s| s.name == params['camera_name']}.motion_alert
end

get '/camera/:camera_name/info' do
  camera = Camera.find(params['camera_name'])
  "Name: #{camera.name}, Credits: #{camera.credits} "
end

post '/camera/:camera_name/environment' do
  camera = Camera.find(params['camera_name'])
  conditions = JSON.parse(Weather::get(:conditions, camera.zip, camera.state))
  temp_f        = conditions['current_observation']['temp_c']
  wind_mph      = conditions['current_observation']['wind_mph']
  wind_gust_mph = conditions['current_observation']['wind_gust_mph']
  message = "#{temp_f}°Wind #{wind_mph}/#{wind_gust_mph}MPH"
  camera.set_osd(message)
end

get '/' do
  'bump'
end
