FROM ubuntu:latest
MAINTAINER Logan Garrett

RUN apt-get update
RUN apt-get install -y ruby ruby-bundler

COPY app.rb /software/
COPY config.yaml /software/

WORKDIR /software/
RUN bundle install

EXPOSE 80

CMD ruby app.rb