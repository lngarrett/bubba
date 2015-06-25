# camera-control

A quick and simple RESTful API to BIND, written in Ruby / Sinatra. Provides the ability to add/remove entries with an existing BIND DNS architecture.

A quick and simple RESTful API to control the sending of motion alerts for IP cameras. This program uses a leaky bucket alogrithim to reduce the noise from constant motion.

I wrote this as a solution to prevent my phone from exploding with alerts when I was mowing the yard. Dropcam uses a simple 30-minute cooldown on push alerts, but I wanted something that gave me a little more control over how alerts are sent.

##Leaky Bucket Credits
All cameras start with 3 credits. Sending a push alert consumes one credit. Each camera gets 1 credit every 10 minutes. When a camera is out of credits it will not send push alerts until it receives more credits. All of these values can be configured in `config.yaml`

## Instructions
    # docker-compose up
    
### Set Redis Secrets:
    # docker exec -it cameracontrol_redis_1 /bin/bash
    # redis-cli
    # set "config:pushover:app-key" "YOUR_APP_KEY"
    # set "config:pushover:user-key" "YOUR_USER_KEY"
### Endpoints (In Progress)
* `GET /` - Currently shows some debugging info
* `GET/:cameraName/motion` - triggers an alert if there is credit.
