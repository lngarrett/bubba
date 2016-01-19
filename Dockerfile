FROM ruby:2.1-onbuild
ADD . .
CMD ["./main.rb"]
