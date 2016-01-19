#!/bin/bash
docker build -t bubba .
docker rm -f bubba
docker run \
  --name="bubba" \
  --publish=4567:4567 \
  --restart="always" \
  --detach=true \
  bubba
