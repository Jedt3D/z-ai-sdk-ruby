# Contributing to Z.ai Ruby SDK

Thank you for your interest in contributing to the Z.ai Ruby SDK! This document provides guidelines and instructions for contributing.

## Development Setup

### Prerequisites

- Ruby >= 3.2.8
- JRuby >= 10.0.4.0 (optional, for JRuby testing)
- Bundler

### Getting Started

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/z-ai-sdk-ruby.git
   cd z-ai-sdk-ruby
   ```

2. **Install Dependencies**
   ```bash
   bundle install
   ```

3. **Run Tests**
   ```bash
   bundle exec rspec
   ```

4. **Run Smoke Test**
   ```bash
   ruby smoke_test.rb
   ```

5. **Run Verification**
   ```bash
   ruby verify_sdk.rb
   ```

## Development Workflow

### Creating a New Feature

1. Create a feature branch from `develop`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following our code style guidelines

3. Write tests for your changes

4. Run the test suite:
   ```bash
   bundle exec rspec
   ```

5. Run RuboCop:
   ```bash
   bundle exec rubocop
   ```

6. Commit your changes with a clear message

7. Push to your fork and create a pull request

### Code Style Guidelines

- Follow Ruby community conventions
- Use frozen string literals (`# frozen_string_literal: true`)
- Write YARD documentation for public methods
- Keep methods small and focused (max 20 lines)
- Use meaningful variable and method names
- Write tests for all new functionality

### Testing Guidelines

- Use RSpec for all tests
- Write unit tests for individual methods
- Write integration tests for API interactions
- Use FactoryBot for test data
- Use VCR for recording HTTP interactions
- Aim for >90% code coverage

### Documentation Guidelines

- Update README.md for user-facing changes
- Update CHANGELOG.md for all changes
- Write YARD documentation for public APIs
- Include usage examples in documentation
- Update example scripts when adding new features

## Project Structure

```
z-ai-sdk-ruby/
├── lib/z/ai/              # Main library code
│   ├── core/              # HTTP client and base classes
│   ├── auth/              # Authentication modules
│   ├── resources/         # API resource classes
│   └── models/            # Data models
├── spec/                  # Test files
│   ├── core/              # Core tests
│   ├── auth/              # Auth tests
│   ├── resources/         # API tests
│   ├── models/            # Model tests
│   └── integration/       # Integration tests
├── examples/              # Usage examples
├── docs/                  # Documentation
└── openspec/              # OpenSpec specifications
```

## Adding a New API Resource

1. Create model in `lib/z/ai/models/`
2. Create resource in `lib/z/ai/resources/`
3. Add to client in `lib/z/ai/client.rb`
4. Create tests in `spec/resources/`
5. Create example in `examples/`
6. Update README.md
7. Update CHANGELOG.md

## Running Tests

```bash
# All tests
bundle exec rspec

# Specific test file
bundle exec rspec spec/resources/chat/completions_spec.rb

# With coverage
COVERAGE=true bundle exec rspec

# Unit tests only
bundle exec rake spec_unit

# Integration tests only
bundle exec rake spec_integration
```

## Debugging

Use `pry` for debugging:

```ruby
require 'pry'
binding.pry
```

For HTTP debugging, enable logging:

```ruby
Z::AI.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.log_level = :debug
end
```

## Release Process

1. Update VERSION in `lib/z/ai/version.rb`
2. Update CHANGELOG.md
3. Run full test suite
4. Build the gem: `gem build zai-ruby-sdk.gemspec`
5. Push to RubyGems: `gem push zai-ruby-sdk-VERSION.gem`
6. Create GitHub release

## Questions or Issues?

- Open a GitHub issue for bugs
- Use GitHub discussions for questions
- Email: sjedt@3ddaily.com

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
