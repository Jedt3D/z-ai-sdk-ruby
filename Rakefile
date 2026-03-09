# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:spec_unit) do |task|
  task.pattern = 'spec/{core,auth,models}/**/*_spec.rb'
  task.rspec_opts = '--tag ~integration'
end

RSpec::Core::RakeTask.new(:spec_integration) do |task|
  task.pattern = 'spec/integration/**/*_spec.rb'
  task.rspec_opts = '--tag integration'
end

RuboCop::RakeTask.new

desc 'Run all tests with coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task[:spec].invoke
end

desc 'Run unit tests only'
task test: :spec_unit

desc 'Run integration tests'
task test_integration: :spec_integration

desc 'Generate YARD documentation'
task :docs do
  sh 'yard doc lib/**/*.rb'
end

desc 'Start an interactive console'
task :console do
  require 'irb'
  require 'irb/completion'
  require_relative 'lib/z/ai'
  
  ARGV.clear
  IRB.start
end

task default: :spec
