# frozen_string_literal: true

require_relative 'base_agent'

module Agent
  module Agents
    # Writes RSpec specs and runs them. On failure, attempts to diagnose and fix.
    # The orchestrator drives the outer retry loop (max 3 cycles).
    # Output: spec/resources/<n>_spec.rb
    class TesterAgent < BaseAgent
      def write_and_run_tests(resource_name, plan, implementation_result)
        task = <<~TASK
          Write comprehensive RSpec tests for the '#{resource_name}' resource, then run them.

          Implementation summary: #{implementation_result}
          Plan: #{JSON.pretty_generate(plan)}

          Steps:
          1. Read "spec/resources/chat/completions_spec.rb" — use as the exact spec template
          2. Read "spec/factories.rb" — to understand existing FactoryBot factories
          3. Read the implemented resource at "lib/z/ai/resources/#{resource_name}.rb"
          4. Write a complete spec to "spec/resources/#{resource_name}_spec.rb"
          5. Run the spec with run_tests and examine output
          6. If failures exist, diagnose root cause; fix the spec or implementation and re-run
          7. Return a summary including final test output

          The spec must include:
          - Success cases with stub_zai_request helper
          - API error cases: 401 (APIAuthenticationError), 400 (APIBadRequestError), 429 (APIRateLimitError)
          - Input validation tests (ValidationError on bad params)
          - Add a FactoryBot factory to spec/factories.rb for the response shape

          The test file header:
            # frozen_string_literal: true
            require 'spec_helper'
        TASK

        result = run(task: task)

        test_results = (@state.get(:test_results) || {})
        test_results[resource_name] = { status: 'ran', result: result }
        @state.update(:test_results, test_results)

        result
      end

      protected

      def system_prompt
        <<~PROMPT
          You are an expert RSpec developer for Ruby API client testing.
          Write comprehensive, well-structured specs following the completions_spec.rb pattern.

          Always:
          - Use stub_zai_request, a_request_to_zai, stub_zai_error helpers (defined in spec_helper)
          - Use FactoryBot (build(:factory_name)) for response fixtures
          - Group tests with context blocks: 'with successful response', 'with API errors', etc.
          - Test success, error, and validation paths
          - If tests fail, read the error output carefully and fix root cause
        PROMPT
      end

      def tools
        [
          {
            type: 'function',
            function: {
              name: 'read_file',
              description: 'Read a project file',
              parameters: {
                type: 'object',
                properties: { path: { type: 'string' } },
                required: ['path']
              }
            }
          },
          {
            type: 'function',
            function: {
              name: 'write_file',
              description: 'Write a file (allowed paths only)',
              parameters: {
                type: 'object',
                properties: {
                  path:    { type: 'string' },
                  content: { type: 'string' }
                },
                required: ['path', 'content']
              }
            }
          },
          {
            type: 'function',
            function: {
              name: 'run_tests',
              description: 'Run RSpec for a spec file or directory',
              parameters: {
                type: 'object',
                properties: { spec_path: { type: 'string', description: 'Path to spec file or directory' } },
                required: ['spec_path']
              }
            }
          },
          {
            type: 'function',
            function: {
              name: 'syntax_check',
              description: 'Check Ruby syntax of a file',
              parameters: {
                type: 'object',
                properties: { file_path: { type: 'string' } },
                required: ['file_path']
              }
            }
          }
        ]
      end
    end
  end
end
