# GitHub Actions for Z AI SDK Ruby

This repository includes several GitHub Actions workflows to automate the development and release process for your Ruby gem.

## Workflows

### 1. CI Workflow (`.github/workflows/ci.yml`)
- **Triggers**: Push to main/develop branches, pull requests to main
- **Features**:
  - Tests on Ruby 2.7, 3.0, 3.1, 3.2
  - RuboCop code style checks
  - Code coverage analysis
  - Gem building and artifact upload
  - OpenSpec change detection

### 2. Release Workflow (`.github/workflows/release.yml`)
- **Triggers**: Git tags starting with `v*`
- **Features**:
  - Automatic GitHub Release creation
  - Changelog generation from git commits
  - Gem artifact upload to release
  - RubyGems publishing

### 3. OpenSpec Phase Tagging (`.github/workflows/openspec-phases.yml`)
- **Triggers**: 
  - Changes to `openspec/` directory
  - Manual workflow dispatch
- **Features**:
  - Automatic detection of completed OpenSpec phases
  - Phase-based tagging (e.g., `feature-name-v1.2.3`)
  - GitHub release creation for phase completion
  - Manual phase tagging option

### 4. Publish Workflow (`.github/workflows/publish.yml`)
- **Triggers**: Manual workflow dispatch or called from other workflows
- **Features**:
  - RubyGems version checking
  - Safe publishing (skips if version exists)
  - GitHub release creation
  - Gem building and validation

## Required Secrets

To use these workflows, add the following secrets to your GitHub repository:

1. **GITHUB_TOKEN**: Automatically provided by GitHub Actions
2. **RUBYGEMS_API_KEY**: Your RubyGems API key for publishing gems

## Usage

### Automated Releases
1. Complete your development work
2. Create and push a version tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. The release workflow will automatically:
   - Run all tests
   - Build the gem
   - Create a GitHub release
   - Publish to RubyGems

### Phase-based Development with OpenSpec
1. Create OpenSpec changes in the `openspec/changes/` directory
2. Complete all tasks in your change
3. Push to main branch
4. The OpenSpec Phase Tagging workflow will:
   - Detect completed changes
   - Create phase-specific tags
   - Create GitHub releases for each phase

### Manual Phase Tagging
1. Go to Actions tab in GitHub
2. Select "OpenSpec Phase Tagging" workflow
3. Click "Run workflow"
4. Enter phase name and optional version
5. The workflow will create a tag and release for your phase

### Manual Gem Publishing
1. Go to Actions tab in GitHub
2. Select "Publish Gem" workflow
3. Click "Run workflow"
4. The workflow will build and publish your gem if the version doesn't exist

## Tag Naming Convention

- **Version tags**: `v1.2.3` (triggers full release)
- **Phase tags**: `feature-name-v1.2.3` (triggers phase release)
- **Manual tags**: Use workflow dispatch for custom naming

## Integration with OpenSpec

The workflows are designed to work seamlessly with OpenSpec:

1. **Phase Detection**: Automatically detects when all tasks in a change are complete
2. **Change Documentation**: Includes OpenSpec proposal and task information in releases
3. **Archive Integration**: Works with the OpenSpec archive-change skill

## Local Development

To test workflows locally, you can use `act` (GitHub Actions runner):

```bash
# Install act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run workflow
act -j test
```

## Troubleshooting

- **RubyGems Publishing**: Ensure your `RUBYGEMS_API_KEY` is correct and has publish permissions
- **Tag Conflicts**: Make sure tag names are unique and follow the semver pattern
- **OpenSpec Detection**: Ensure changes are in the correct directory with completed tasks