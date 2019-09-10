FROM ruby:2.6.1-alpine as ruby_builder
MAINTAINER Dennis-Florian Herr <deflo.herr@gmail.com>
RUN apk add --update --no-cache \
    ca-certificates \
    openssl \
    g++ \
    gcc \
    libc-dev \
    ncurses-dev \
    libxml2-dev \
    sqlite-dev \
    make \
    patch \
    postgresql-dev \
    git \
  && rm -rf /var/cache/apk/*

# setup basic rails gems in a seperate layer to speed up new gem installation
ADD rails-setup/Gemfile /rails-setup/Gemfile
ADD rails-setup//Gemfile.lock /rails-setup/Gemfile.lock

WORKDIR /rails-setup

RUN bundle install \
  && rm -rf /usr/local/bundle/cache/*

ADD api/Gemfile /api/Gemfile
ADD api/Gemfile.lock /api/Gemfile.lock

WORKDIR /api

RUN bundle install \
  && rm -rf /usr/local/bundle/cache/*

FROM ruby:2.6.1-alpine
RUN apk add --update --no-cache \
     ca-certificates \
     openssl \
     libstdc++ \
     postgresql-dev \
     sqlite-dev \
     tzdata \
     less \
     bash \
     curl \
  && rm -rf /var/cache/apk/*

ENV TZ Europe/Berlin

ADD docker-bin/start_server /usr/local/bin/start_server
RUN chmod 0755 /usr/local/bin/start_server

COPY --from=ruby_builder /usr/local/bundle /usr/local/bundle

WORKDIR /api

ADD api /api

EXPOSE 3000

CMD ["start_server"]
