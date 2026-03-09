# frozen_string_literal: true

require_relative 'lib/z/ai/version'

Gem::Specification.new do |spec|
  spec.name          = 'zai-ruby-sdk'
  spec.version       = Z::AI::VERSION
  spec.authors       = ['Jedt']
  spec.email         = ['sjedt@3ddaily.com']

  spec.summary       = 'Ruby SDK for Z.ai API'
  spec.description   = 'A Ruby SDK for interacting with Z.ai AI services, providing ' \
                       'idiomatic Ruby bindings for chat completions, embeddings, ' \
                       'and other AI features'
  spec.homepage      = 'https://github.com/zai-org/z-ai-sdk-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2.8'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/}) ||
        f.match(%r{^\.}) ||
        f.match(%r{^(examples|docs)/})
    end
  end

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '~> 0.22'
  spec.add_dependency 'dry-struct', '~> 1.6'
  spec.add_dependency 'dry-validation', '~> 1.10'
  spec.add_dependency 'jwt', '~> 2.9'
  spec.add_dependency 'logger', '~> 1.6'

  spec.add_development_dependency 'bundler', '~> 2.5'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rspec-core', '~> 3.13'
  spec.add_development_dependency 'rspec-expectations', '~> 3.13'
  spec.add_development_dependency 'rspec-mocks', '~> 3.13'
  spec.add_development_dependency 'webmock', '~> 3.24'
  spec.add_development_dependency 'vcr', '~> 6.3'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'simplecov-json', '~> 0.2'
  spec.add_development_dependency 'factory_bot', '~> 6.5'
  spec.add_development_dependency 'benchmark-memory', '~> 0.2'
  spec.add_development_dependency 'rubocop', '~> 1.69'
  spec.add_development_dependency 'yard', '~> 0.9'
end
