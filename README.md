# Bubba

A quick and simple RESTful API to control the sending of motion alerts for IP cameras. This program uses a leaky bucket alogrithim to reduce the noise from constant motion.

I wrote this as a solution to prevent my phone from exploding with alerts when I was mowing the yard. Dropcam uses a simple 30-minute cooldown on push alerts, but I wanted something that gave me a little more control over how alerts are sent.

## Configuration

### Config.yaml

`Config.yaml` contains common configuration settings for customizing Bubba.

| config           |  Description  |
|------------------|---------------|
| *credit_full*      | The maximum number of alert credits a camera can hold. |
| credit_interval  | The number of seconds before a camera will gain credit. |
| credit_increment | The number of credits granted at the `credit_interval` |
| name             | Camera name. |
| hostname         | Camera hostname or IP. Used to make API calls. |
| zip              | Location of camera. Used for weather. |
| state            | Location of camera. Used for weather. |
| no_osd           | If this is `true` then Bubba will not try to update on-screen-display. Currently Bubba only supports OSD Hikvision cameras. Setting this to true will prevent issues when using a non Hikvision camera. |

### Environment Variables

The following environment variables need to be exported before starting Bubba.

| Config Item | Details |
|-------------|---------|
| pushover_app_key   | Pushover application key. [Create app](https://pushover.net/apps/build). |
| pushover_user_key  | Pushover user key. [View key (requires login)](https://pushover.net/). |
| wunderground_key   | Your wunderground API key. [Get an API key](http://www.wunderground.com/weather/api/d/login.html). |
| hikvision_username | Hikvision web interface. |
| hikvision_password | Hikvision web interface. |

### Run with Docker

Docker is the preferred method for deplying Bubba. 

```
#!/bin/bash
docker build -t bubba .
docker rm -f bubba
docker run \
  --name="bubba" \
  --publish=4567:4567 \
  --env pushover_app_key='bK2YEgZay8ThNGMUm57aQmNnYfx2y3' \
  --env pushover_user_key='CeRe3B7Gt75uTUJVvBfD8JZKSteafz' \
  --env wunderground_key='5335cf7b87ef8286' \
  --env hikvision_username='admin' \
  --env hikvision_password='password' \
  --restart="always" \
  --detach=true \
  bubba
```

## Leaky Bucket Credits
All cameras start with, and have a maximum of, 3 credits. Sending a push alert consumes one credit. Each camera gets 1 credit every 20 minutes. When a camera is out of credits it will not send push alerts until it receives more credits. All of these values can be configured in `config.yaml`

## Endpoints
* `GET /camera/:camera_name/motion` - triggers an alert if there is credit.
* `GET /camera/:camera_name/info` - Shows credits.
* `POST /camera/:camera_name/environment` - updates temperature and wind. Bubba automatically updates every 10 minutes otherwise.
