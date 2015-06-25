FROM redis
MAINTAINER Logan Garrett

RUN apt-get update
RUN apt-get install -y ruby ruby-dev
RUN gem install bundler

COPY app.rb /software/
COPY config.yaml /software/
COPY Gemfile /software/

WORKDIR /software/
RUN bundle install
RUN redis-server

EXPOSE 80

CMD ruby app.rb