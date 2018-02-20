FROM ruby:2.5-alpine

# Set local timezone
RUN apk add --update tzdata && \
    cp /usr/share/zoneinfo/Europe/Warsaw /etc/localtime && \
    echo "Europe/Warsaw" > /etc/timezone

# Install runtime dependencies
RUN apk add --update --virtual runtime-deps postgresql-client nodejs libffi-dev readline sqlite

# Install build-time dependencies
RUN apk add --virtual build-deps build-base libressl-dev postgresql-dev libc-dev linux-headers libxml2-dev libxslt-dev readline-dev

# Bundle into temp directory
WORKDIR /tmp
ADD Gemfile* ./

RUN bundle install --jobs=2

# Remove build-time dependenies
RUN apk del build-deps

# Copy app's code into the container
ENV APP_HOME /app
COPY . $APP_HOME
WORKDIR $APP_HOME

# Configure production environment variables
ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

RUN apk add --virtual asscompile-deps yarn

RUN SECRET_KEY_BASE=dummyshit bundle exec rails assets:precompile

RUN apk del asscompile-deps

# Expose port 3000
EXPOSE 3000

# Run puma server
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
