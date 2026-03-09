# Dockerfile for testing with Ruby 3.2.8
FROM ruby:3.2.8-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy gem files and lib directory (needed for gemspec)
COPY Gemfile Gemfile.lock* ./
COPY zai-ruby-sdk.gemspec ./
COPY lib/ ./lib/

# Install bundler
RUN gem install bundler:2.5.23

# Install dependencies
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the application
COPY . .

# Create test script
RUN echo '#!/bin/bash' > /test.sh && \
    echo 'echo "Running tests with Ruby $(ruby -v)"' >> /test.sh && \
    echo 'bundle exec rspec --format documentation' >> /test.sh && \
    chmod +x /test.sh

CMD ["/test.sh"]
