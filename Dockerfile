FROM ruby:2.5-alpine

# Set local timezone
RUN apk add --update tzdata && \
    cp /usr/share/zoneinfo/Europe/Warsaw /etc/localtime && \
    echo "Europe/Warsaw" > /etc/timezone

# Install runtime dependencies
RUN apk add --update --virtual runtime-deps postgresql-client nodejs libffi-dev readline sqlite yarn

# Install build-time dependencies
RUN apk add --virtual build-deps build-base libressl-dev postgresql-dev libc-dev linux-headers libxml2-dev libxslt-dev readline-dev

# Bundle into temp directory
WORKDIR /tmp
ADD Gemfile* ./

RUN bundle install --jobs=2

# Remove build-time dependenies
RUN apk del build-deps

# Go to app dir
ENV APP_HOME /app
WORKDIR $APP_HOME

# Configure production environment variables
ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

# Install js packages
COPY package.json yarn.lock ./
RUN yarn install

# Copy app's code into the container
COPY . $APP_HOME

# Precompile assets
RUN SECRET_KEY_BASE=dummyshit bundle exec rails assets:precompile

# Expose port 3000
EXPOSE 3000

# Run puma server
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
