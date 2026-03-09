# Testing Guide for Z.ai Ruby SDK

This document provides comprehensive testing instructions for the Z.ai Ruby SDK across multiple Ruby environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Testing Options](#testing-options)
  - [Local Testing](#local-testing)
  - [Docker Testing](#docker-testing)
  - [Complete Test Suite](#complete-test-suite)
- [Test Environments](#test-environments)
  - [Ruby 3.2.8+](#ruby-328)
  - [JRuby 10.0.4.0+](#jruby-10040)
- [Troubleshooting](#troubleshooting)
- [CI/CD Integration](#cicd-integration)

## Prerequisites

### For Local Testing
- Ruby >= 3.2.8 or JRuby >= 10.0.4.0
- Bundler 2.5+
- Git

### For Docker Testing
- Docker 20.10+
- Docker Compose 2.0+

## Quick Start

### Option 1: Automated Multi-Environment Testing (Recommended)

```bash
# Run all tests across all environments
./test_all_environments.sh all

# Or run specific test suites
./test_all_environments.sh local   # Quick local tests
./test_all_environments.sh docker  # Docker-based tests
./test_all_environments.sh ruby    # Ruby 3.2.8 only
./test_all_environments.sh jruby   # JRuby 10.0.4.0 only
```

### Option 2: Manual Testing

```bash
# Install dependencies
bundle install

# Run RSpec tests
bundle exec rspec

# Run smoke test
ruby smoke_test.rb

# Run basic verification
ruby verify_sdk.rb
```

## Testing Options

### 1. Smoke Test (Quick Verification)

**Purpose**: Verifies project structure and syntax without dependencies

```bash
ruby smoke_test.rb
# or
ruby smoke_test_simple.rb
```

**What it checks**:
- ✓ All source files exist
- ✓ All directories present
- ✓ Ruby syntax valid for all files
- ✓ Examples available
- ✓ Documentation complete
- ✓ Version consistency

**Time**: ~2-3 seconds

### 2. Basic Verification

**Purpose**: Tests core SDK functionality

```bash
ruby verify_sdk.rb
```

**What it tests**:
- ✓ SDK loads without errors
- ✓ Version constant accessible
- ✓ Configuration works
- ✓ Client initialization
- ✓ All 4 API resources accessible
- ✓ Error classes functional
- ✓ JWT token generation
- ✓ Model instantiation

**Time**: ~5-10 seconds

### 3. RSpec Test Suite

**Purpose**: Comprehensive unit and integration tests

```bash
bundle install
bundle exec rspec

# With coverage
COVERAGE=true bundle exec rspec

# Specific test file
bundle exec rspec spec/resources/chat/completions_spec.rb

# With documentation format
bundle exec rspec --format documentation
```

**What it tests**:
- ✓ Configuration validation
- ✓ Authentication (JWT, API key)
- ✓ Chat API (completions, streaming)
- ✓ Embeddings API
- ✓ Images API
- ✓ Files API
- ✓ Error handling
- ✓ HTTP client retry logic
- ✓ Integration scenarios

**Time**: ~30-60 seconds

### 4. Docker Testing (Isolated Environments)

**Purpose**: Test in clean, reproducible environments

```bash
# Build Docker images
cd docker
docker-compose build

# Run Ruby 3.2.8 tests
docker-compose up ruby-test

# Run JRuby 10.0.4.0 tests
docker-compose up jruby-test

# Run both
docker-compose up ruby-test jruby-test

# Interactive Ruby shell
docker-compose run ruby-interactive
```

**Benefits**:
- ✅ Isolated environment
- ✅ No system dependencies
- ✅ Reproducible results
- ✅ Tests both Ruby and JRuby
- ✅ Clean slate every time

**Time**: ~2-5 minutes (first build: ~10 minutes)

## Test Environments

### Ruby 3.2.8+

**Docker Image**: `ruby:3.2.8-slim`

**What gets tested**:
- Core functionality
- Standard library compatibility
- Performance characteristics
- Ruby 3.2+ features (YJIT, etc.)

**Run tests**:
```bash
./test_all_environments.sh ruby
# or
docker-compose up ruby-test
```

### JRuby 10.0.4.0+

**Docker Image**: `jruby:10.0.4.0-jdk21`

**What gets tested**:
- JVM compatibility
- Thread safety
- Java integration
- Performance on JVM

**Run tests**:
```bash
./test_all_environments.sh jruby
# or
docker-compose up jruby-test
```

**JRuby-specific considerations**:
- Some C extensions not available
- Different threading model
- Longer startup time
- Better for long-running processes

## Complete Test Suite

Run everything:

```bash
./test_all_environments.sh all
```

This will:
1. ✓ Run smoke tests (structure verification)
2. ✓ Run basic verification (functionality)
3. ✓ Build Docker images (Ruby + JRuby)
4. ✓ Run Ruby 3.2.8 tests
5. ✓ Run JRuby 10.0.4.0 tests
6. ✓ Generate coverage reports
7. ✓ Clean up Docker resources

**Total time**: ~5-10 minutes (first run: ~15-20 minutes with Docker build)

## Test Coverage

### What We Test

| Component | Unit Tests | Integration Tests | Docker Tests |
|-----------|-----------|-------------------|--------------|
| Configuration | ✅ | ✅ | ✅ |
| Authentication | ✅ | ✅ | ✅ |
| Chat API | ✅ | ✅ | ✅ |
| Embeddings API | ✅ | ✅ | ✅ |
| Images API | ✅ | ✅ | ✅ |
| Files API | ✅ | ✅ | ✅ |
| HTTP Client | ✅ | ✅ | ✅ |
| Error Handling | ✅ | ✅ | ✅ |
| Streaming | ✅ | ✅ | ✅ |

### Coverage Goals

- **Unit Tests**: >90% code coverage
- **Integration Tests**: All major workflows
- **Docker Tests**: All APIs on both Ruby and JRuby

## Troubleshooting

### Issue: Bundler version mismatch

```bash
# Install specific Bundler version
gem install bundler:2.5.23
bundle _2.5.23_ install
```

### Issue: Permission errors during bundle install

```bash
# Install to local directory
bundle install --path vendor/bundle
```

### Issue: Docker daemon not running

```bash
# Start Docker (Linux)
sudo systemctl start docker

# Start Docker (macOS)
open -a Docker
```

### Issue: JRuby C extension errors

JRuby doesn't support all C extensions. The gemspec excludes C-based gems for JRuby:
- Uses `platform: :ruby` where needed
- Falls back to pure Ruby implementations

### Issue: Tests fail with missing dependencies

```bash
# Clean and reinstall
rm -rf vendor/bundle
rm Gemfile.lock
bundle install
```

### Issue: Coverage not generating

```bash
# Ensure SimpleCov is loaded
COVERAGE=true bundle exec rspec

# Check coverage directory
ls -la coverage/
```

## CI/CD Integration

### GitHub Actions

Our CI pipeline (`.github/workflows/ci.yml`) runs:
1. Smoke tests
2. Basic verification
3. RSpec tests on Ruby 3.2.8, 3.3.0, 3.4.0
4. RuboCop linting
5. Coverage reporting

### Local CI Simulation

```bash
# Run what CI runs
./test_all_environments.sh local
bundle exec rspec
bundle exec rubocop
```

### Pre-commit Hooks

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
./smoke_test.rb && bundle exec rspec --format progress
```

## Performance Benchmarks

Run performance tests:

```bash
# Basic benchmarks
ruby examples/performance_benchmark.rb

# Memory profiling
ruby examples/memory_profile.rb
```

## Test Data

Test fixtures are located in:
- `spec/fixtures/` - Test data files
- `spec/factories.rb` - FactoryBot definitions
- `spec/shared/` - Shared examples and contexts

## Writing New Tests

### Example RSpec Test

```ruby
require 'spec_helper'

RSpec.describe Z::AI::Resources::NewAPI do
  let(:client) { Z::AI::Client.new(api_key: 'test_key.12345') }
  let(:api) { described_class.new(client) }
  
  describe '#method' do
    before do
      stub_zai_request(:post, 'endpoint', { data: 'response' })
    end
    
    it 'returns expected result' do
      result = api.method(param: 'value')
      expect(result).to be_present
    end
  end
end
```

## Test Reports

After running tests:
- **Coverage**: `coverage/index.html`
- **RSpec Results**: `tmp/rspec_results.txt`
- **SimpleCov JSON**: `coverage/coverage.json`

## Summary

Choose your testing approach:

| Need | Command | Time |
|------|---------|------|
| Quick check | `ruby smoke_test.rb` | 2-3s |
| Basic verification | `ruby verify_sdk.rb` | 5-10s |
| Full unit tests | `bundle exec rspec` | 30-60s |
| Docker tests | `./test_all_environments.sh docker` | 2-5min |
| **Complete suite** | `./test_all_environments.sh all` | 5-10min |

## Next Steps

1. ✅ Run smoke tests: `ruby smoke_test.rb`
2. ✅ Install dependencies: `bundle install`
3. ✅ Run RSpec: `bundle exec rspec`
4. ✅ Test with Docker: `./test_all_environments.sh all`
5. ✅ Check coverage: Open `coverage/index.html`

---

For questions or issues, see:
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
- [README.md](README.md) - SDK documentation
- GitHub Issues - Bug reports and feature requests
