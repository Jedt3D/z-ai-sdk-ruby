# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in zai-ruby-sdk.gemspec
gemspec

group :development, :test do
  gem 'pry', '~> 0.14'
  gem 'pry-byebug', '~> 3.10' unless RUBY_PLATFORM == 'java'
end

group :test do
  gem 'rspec', '~> 3.13'
  gem 'rspec-core', '~> 3.13'
  gem 'rspec-expectations', '~> 3.13'
  gem 'rspec-mocks', '~> 3.13'
  gem 'webmock', '~> 3.24'
  gem 'vcr', '~> 6.3'
  gem 'simplecov', '~> 0.22'
  gem 'simplecov-json', '~> 0.2'
  gem 'factory_bot', '~> 6.5'
end
