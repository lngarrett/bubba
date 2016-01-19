FROM ruby:2.1-onbuild
ADD . .
RUN gem install yaml json sinatra thin rest-client
CMD ["./main.rb"]
