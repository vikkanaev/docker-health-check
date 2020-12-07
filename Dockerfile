FROM ruby:2.7.0-buster

ENV APP_HOME=/app
ENV BUNDLER_GEMFILE=/app/Gemfile
ENV BUNDLE_PATH=/gems

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
ADD . $APP_HOME

RUN gem install bundler \
    && bundle config set deployment 'true' \
    && bundle config set with 'plugins' \
    && bundle install --jobs=3

# The health check will first run interval seconds after the container is started, and then again interval seconds after each previous check completes.
# If a single run of the check takes longer than timeout seconds then the check is considered to have failed.
# It takes retries consecutive failures of the health check for the container to be considered unhealthy.
# https://docs.docker.com/engine/reference/builder/#healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
  CMD ruby /app/app/healthcheck.rb

CMD ruby /app/app/code.rb
