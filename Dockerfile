FROM ruby:2.5.1-alpine AS builder

# Set local timezone and install runtime packages
RUN apk --no-cache add tzdata postgresql-client nodejs && \
    cp /usr/share/zoneinfo/Europe/Warsaw /etc/localtime && \
    echo "Europe/Warsaw" > /etc/timezone

# Install build-time dependencies
RUN apk --no-cache add build-base libressl-dev postgresql-dev libc-dev linux-headers libxml2-dev libxslt-dev readline-dev git && \
    cd /tmp && \
    mkdir yarn && cd yarn && \
    wget -qO- https://github.com/yarnpkg/yarn/releases/download/v1.6.0/yarn-v1.6.0.tar.gz | tar xz --strip-components 1 && \
    cp bin/* /usr/bin/ && \
    cp lib/* /usr/lib/

# Go to app dir
ENV APP_HOME /app
WORKDIR $APP_HOME

# Bundle into app directory
ADD Gemfile* ./
RUN bundle install --no-cache --jobs=2

# Configure production environment variables for build
ENV RAILS_ENV=production \
    NODE_ENV=production

# Install js packages
COPY package.json yarn.lock ./
RUN yarn install

# Copy app's code into the container
COPY . $APP_HOME

# Precompile assets
RUN SECRET_KEY_BASE=dummyshit bundle exec rails assets:precompile

# Remove unneeded stuff in preparation for later copy
RUN rm -rf node_modules
RUN bundle clean --force
RUN rm -rf /usr/local/bundle/cache


# BUILD STAGE COMPLETE
# ------------------------------
# SLIM SERVER EXECUTION STAGE

FROM ruby:2.5.1-alpine

# Set local timezone and install runtime packages
RUN apk --no-cache add tzdata postgresql-client nodejs && \
    cp /usr/share/zoneinfo/Europe/Warsaw /etc/localtime && \
    echo "Europe/Warsaw" > /etc/timezone

# Go to app dir
ENV APP_HOME /app
WORKDIR $APP_HOME

# Copy app's code into the container
COPY . $APP_HOME

# Copy build artifacts
COPY --from=builder /app/public /app/public
# Copy installed gems
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Expose port 3000
EXPOSE 3000

# Configure production environment variables for runtime environment
ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

# run the server
CMD [ "bin/rails s -p 3000 -b 0.0.0.0" ]