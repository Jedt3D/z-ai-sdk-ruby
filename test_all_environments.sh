#!/bin/bash
# Comprehensive testing script for Z.ai Ruby SDK
# Tests both Ruby 3.2.8+ and JRuby 10.0.4.0+ environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root (script is in the project root directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Z.ai Ruby SDK - Multi-Environment Testing Suite         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        echo "Please install Docker to run tests in isolated environments"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}Error: Docker daemon is not running${NC}"
        echo "Please start Docker"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Docker is available${NC}"
}

# Function to check if Docker Compose is installed
check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        echo -e "${RED}Error: Docker Compose is not installed${NC}"
        echo "Please install Docker Compose"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Docker Compose is available${NC}"
}

# Function to build Docker images
build_images() {
    echo -e "${BLUE}Building Docker images...${NC}"
    
    echo "Building Ruby 3.2.8 test environment..."
    $COMPOSE_CMD -f docker/docker-compose.yml build ruby-test
    
    echo "Building JRuby 10.0.4.0 test environment..."
    $COMPOSE_CMD -f docker/docker-compose.yml build jruby-test
    
    echo -e "${GREEN}✓ Docker images built${NC}"
}

# Function to run Ruby tests
run_ruby_tests() {
    echo -e "${BLUE}Running tests with Ruby 3.2.8...${NC}"
    echo "----------------------------------------"
    
    $COMPOSE_CMD -f docker/docker-compose.yml up ruby-test
    
    # Get exit code
    local exit_code=$($COMPOSE_CMD -f docker/docker-compose.yml ps -q ruby-test | xargs docker inspect -f '{{.State.ExitCode}}')
    
    if [ "$exit_code" -eq 0 ]; then
        echo -e "${GREEN}✓ Ruby tests passed${NC}"
        return 0
    else
        echo -e "${RED}✗ Ruby tests failed${NC}"
        return 1
    fi
}

# Function to run JRuby tests
run_jruby_tests() {
    echo -e "${BLUE}Running tests with JRuby 10.0.4.0...${NC}"
    echo "----------------------------------------"
    
    $COMPOSE_CMD -f docker/docker-compose.yml up jruby-test
    
    # Get exit code
    local exit_code=$($COMPOSE_CMD -f docker/docker-compose.yml ps -q jruby-test | xargs docker inspect -f '{{.State.ExitCode}}')
    
    if [ "$exit_code" -eq 0 ]; then
        echo -e "${GREEN}✓ JRuby tests passed${NC}"
        return 0
    else
        echo -e "${RED}✗ JRuby tests failed${NC}"
        return 1
    fi
}

# Function to run smoke tests
run_smoke_tests() {
    echo -e "${BLUE}Running smoke tests...${NC}"
    echo "----------------------------------------"
    
    ruby smoke_test.rb
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Smoke tests passed${NC}"
        return 0
    else
        echo -e "${RED}✗ Smoke tests failed${NC}"
        return 1
    fi
}

# Function to run basic verification
run_basic_verification() {
    echo -e "${BLUE}Running basic verification...${NC}"
    echo "----------------------------------------"
    
    # Test if SDK loads
    ruby -e "require_relative 'lib/z/ai'; puts '✓ SDK loads'"
    
    # Test version
    ruby -e "require_relative 'lib/z/ai'; puts '✓ Version: ' + Z::AI::VERSION"
    
    # Test configuration
    ruby -e "require_relative 'lib/z/ai'; config = Z::AI::Configuration.new; config.api_key = 'test'; config.validate!; puts '✓ Configuration works'"
    
    # Test client initialization
    ruby -e "require_relative 'lib/z/ai'; client = Z::AI::Client.new(api_key: 'test.key'); puts '✓ Client initializes'"
    
    echo -e "${GREEN}✓ Basic verification passed${NC}"
}

# Function to generate coverage report
generate_coverage() {
    echo -e "${BLUE}Generating coverage report...${NC}"
    
    if [ -f "coverage/coverage.json" ]; then
        echo "Coverage report available at: coverage/index.html"
        echo -e "${GREEN}✓ Coverage report generated${NC}"
    else
        echo -e "${YELLOW}⚠ No coverage report found${NC}"
    fi
}

# Function to clean up Docker resources
cleanup() {
    echo -e "${BLUE}Cleaning up Docker resources...${NC}"
    
    $COMPOSE_CMD -f docker/docker-compose.yml down --volumes --remove-orphans
    
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Main test execution
main() {
    local test_type="${1:-all}"
    local cleanup_after="${2:-true}"
    
    case "$test_type" in
        "docker")
            echo -e "${BLUE}Running Docker-based tests only${NC}"
            check_docker
            check_docker_compose
            build_images
            
            ruby_result=0
            jruby_result=0
            
            run_ruby_tests || ruby_result=1
            echo ""
            run_jruby_tests || jruby_result=1
            echo ""
            
            generate_coverage
            
            if [ "$cleanup_after" = "true" ]; then
                cleanup
            fi
            
            if [ $ruby_result -eq 0 ] && [ $jruby_result -eq 0 ]; then
                echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${GREEN}║          ALL DOCKER TESTS PASSED! ✅                        ║${NC}"
                echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
                exit 0
            else
                echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${RED}║          SOME TESTS FAILED ❌                               ║${NC}"
                echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
                exit 1
            fi
            ;;
        
        "local")
            echo -e "${BLUE}Running local tests only${NC}"
            
            run_smoke_tests || exit 1
            echo ""
            run_basic_verification || exit 1
            echo ""
            
            echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║          LOCAL TESTS PASSED! ✅                             ║${NC}"
            echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
            exit 0
            ;;
        
        "ruby")
            echo -e "${BLUE}Running Ruby tests only${NC}"
            check_docker
            check_docker_compose
            build_images
            
            run_ruby_tests || exit 1
            
            if [ "$cleanup_after" = "true" ]; then
                cleanup
            fi
            
            exit 0
            ;;
        
        "jruby")
            echo -e "${BLUE}Running JRuby tests only${NC}"
            check_docker
            check_docker_compose
            build_images
            
            run_jruby_tests || exit 1
            
            if [ "$cleanup_after" = "true" ]; then
                cleanup
            fi
            
            exit 0
            ;;
        
        "all"|*)
            echo -e "${BLUE}Running all tests${NC}"
            
            run_smoke_tests || exit 1
            echo ""
            run_basic_verification || exit 1
            echo ""
            
            check_docker
            check_docker_compose
            build_images
            
            ruby_result=0
            jruby_result=0
            
            run_ruby_tests || ruby_result=1
            echo ""
            run_jruby_tests || jruby_result=1
            echo ""
            
            generate_coverage
            
            if [ "$cleanup_after" = "true" ]; then
                cleanup
            fi
            
            if [ $ruby_result -eq 0 ] && [ $jruby_result -eq 0 ]; then
                echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${GREEN}║          ALL TESTS PASSED! ✅                               ║${NC}"
                echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
                exit 0
            else
                echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${RED}║          SOME TESTS FAILED ❌                               ║${NC}"
                echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
                exit 1
            fi
            ;;
    esac
}

# Help message
show_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  all       Run all tests (smoke, basic, Docker Ruby & JRuby) - default"
    echo "  docker    Run Docker-based tests only (Ruby & JRuby)"
    echo "  local     Run local tests only (smoke & basic verification)"
    echo "  ruby      Run Docker Ruby tests only"
    echo "  jruby     Run Docker JRuby tests only"
    echo ""
    echo "Options:"
    echo "  nocleanup Don't clean up Docker containers after tests"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 docker             # Run Docker tests only"
    echo "  $0 local              # Run local tests only"
    echo "  $0 ruby nocleanup     # Run Ruby tests, keep containers"
    exit 0
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
fi

# Run main function
main "$@"
