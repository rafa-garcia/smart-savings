FROM ruby:2.6-alpine

WORKDIR /usr/src/app
COPY . .

RUN apk add --update --no-cache build-base \
  && gem update --system \
  && gem install bundler -v 2.1.4 \
  && bundle install \
  && bundle clean --force \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
