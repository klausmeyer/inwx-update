FROM ruby:2.6.4-alpine

MAINTAINER Klaus Meyer <spam@klaus-meyer.net>

RUN apk update && \
    apk add build-base zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev && \
    rm -rf /var/cache/apk/*

WORKDIR /usr/src

ADD Gemfile /usr/src
ADD Gemfile.lock /usr/src

RUN gem install bundler && \
    bundle install --without development test

RUN bundle install

ADD . /usr/src/
RUN adduser -S -h /usr/src/ deploy && chown -R deploy /usr/src/ && chown -R deploy /usr/local/bundle

USER deploy

CMD ["ruby", "/usr/src/script.rb"]
