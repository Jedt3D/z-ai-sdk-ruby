# frozen_string_literal: true

require 'simplecov'
require 'simplecov-json'

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/examples/'
  add_filter '/vendor/'
  add_group 'Core', 'lib/z/ai/core'
  add_group 'Auth', 'lib/z/ai/auth'
  add_group 'Resources', 'lib/z/ai/resources'
  add_group 'Models', 'lib/z/ai/models'
  add_group 'Client', 'lib/z/ai/client.rb'
  minimum_coverage 80
end

require 'bundler/setup'
require 'webmock/rspec'
require 'vcr'
require 'factory_bot'
require 'fileutils'

require_relative '../lib/z/ai'

WebMock.disable_net_connect!(allow_localhost: true, allow: 'api.z.ai')

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<ZAI_API_KEY>') { ENV['ZAI_API_KEY'] }
  config.filter_sensitive_data('<JWT_TOKEN>') do |interaction|
    interaction.request.headers['Authorization']&.first&.gsub('Bearer ', '')
  end
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri, :body]
  }
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.max_formatted_output_length = nil
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed

  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    FactoryBot.find_definitions
    FileUtils.mkdir_p('tmp')
  end

  config.after(:each) do
    Z::AI.reset!
  end

  config.before(:each) do
    ENV['ZAI_API_KEY'] = 'test_api_key.12345'
    ENV['ZAI_BASE_URL'] = 'https://api.z.ai/api/paas/v4/'
  end

  config.after(:each) do
    ENV.delete('ZAI_API_KEY')
    ENV.delete('ZAI_BASE_URL')
  end
end

Dir[File.join(__dir__, 'shared', '**', '*.rb')].each { |f| require f }
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

module RSpec
  module Helpers
    def fixture_path(filename)
      File.join(File.dirname(__FILE__), 'fixtures', filename)
    end

    def load_fixture(filename)
      JSON.parse(File.read(fixture_path(filename)))
    end

    def a_request_to_zai(method, path)
      a_request(method, "https://api.z.ai/api/paas/v4/#{path}")
    end

    def stub_zai_request(method, path, response_body, status = 200, headers = {})
      stub_request(method, "https://api.z.ai/api/paas/v4/#{path}")
        .to_return(
          status: status,
          body: response_body.to_json,
          headers: { 'Content-Type' => 'application/json' }.merge(headers)
        )
    end

    def stub_zai_error(method, path, error_message, status, error_code = nil)
      body = { error: { message: error_message } }
      body[:error][:code] = error_code if error_code
      stub_zai_request(method, path, body, status)
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Helpers
end
