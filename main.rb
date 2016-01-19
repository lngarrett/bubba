#!/usr/bin/env ruby
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'yaml'
require 'camera'
require 'sinatra'
require 'thin'

set :server, 'thin'
set :bind, '0.0.0.0'

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG

$config  = YAML.load_file('config.yaml')['config']
$config['pushover_app_key']  = ENV['pushover_app_key']
$config['pushover_user_key'] = ENV['pushover_user_key']

$cameras = YAML.load_file('config.yaml')['cameras']

$cameras.map! { |camera|
  camera[:credits] = $config['credit_full']
  Camera::DS2CD2032.new(camera)
}

get '/camera/:camera_name' do
  $cameras.find {|s| s.name == params['camera_name']}.motion_alert
end

Thread.new do
  loop do
    Camera::DS2CD2032.increment_all
    sleep $config['credit_interval']
  end
end
