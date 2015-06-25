FROM ubuntu:latest
MAINTAINER Logan Garrett

RUN apt-get update
RUN apt-get install -y ruby ruby-bundler git


WORKDIR /software/
RUN git clone https://github.com/lngarrett/camera-control.git

EXPOSE 80

CMD /usr/bin/ruby app.rb