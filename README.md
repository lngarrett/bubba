# Bubba

A quick and simple RESTful API to control the sending of motion alerts for IP cameras. This program uses a leaky bucket alogrithim to reduce the noise from constant motion.

I wrote this as a solution to prevent my phone from exploding with alerts when I was mowing the yard. Dropcam uses a simple 30-minute cooldown on push alerts, but I wanted something that gave me a little more control over how alerts are sent.

##Leaky Bucket Credits
All cameras start with, and have a maximum of, 3 credits. Sending a push alert consumes one credit. Each camera gets 1 credit every 10 minutes. When a camera is out of credits it will not send push alerts until it receives more credits. All of these values can be configured in `config.yaml`

### Endpoints (In Progress)
* `GET /` - Currently shows some debugging info
* `GET /camera/:camera_name/motion` - triggers an alert if there is credit.
