# Bubba

A quick and simple RESTful API to control the sending of motion alerts for IP cameras. This program uses a leaky bucket alogrithim to reduce the noise from constant motion.

I wrote this as a solution to prevent my phone from exploding with alerts when I was mowing the yard. Dropcam uses a simple 30-minute cooldown on push alerts, but I wanted something that gave me a little more control over how alerts are sent.

## Configuration

First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell

| Config Item | Details |
|-------------|---------|
| pushover_app_key | The key for your pushover application. [Create app](https://pushover.net/apps/build). |
| pushover_user_key | Your pushover user key. [View key (requires login)](https://pushover.net/). |
| wunderground_key | Your wunderground API key. [Get an API key](http://www.wunderground.com/weather/api/d/login.html). |
| hikvision_username | Username for your Hikvision web interface. |
| hikvision_password | Username for your Hikvision web interface. |


## Leaky Bucket Credits
All cameras start with, and have a maximum of, 3 credits. Sending a push alert consumes one credit. Each camera gets 1 credit every 10 minutes. When a camera is out of credits it will not send push alerts until it receives more credits. All of these values can be configured in `config.yaml`

## Endpoints
* `GET /camera/:camera_name/motion` - triggers an alert if there is credit.
* `GET /camera/:camera_name/info` - Shows credits.
* `POST /camera/:camera_name/environment` - updates temperature and wind. Bubba automatically updates every 10 minutes otherwise.
