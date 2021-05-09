FROM ruby:3.0.0
RUN apt-get update && apt-get install libsqlite3-dev
RUN gem update bundler
RUN mkdir /rails-flog
WORKDIR /rails-flog
COPY . /rails-flog
RUN bundle install
CMD ["bundle", "exec", "rake"]

