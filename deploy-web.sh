#!/bin/bash
docker-compose build web
docker-compose up --no-deps -d web
