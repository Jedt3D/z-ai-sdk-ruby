# frozen_string_literal: true

require_relative 'base_agent'

module Agent
  module Agents
    # Writes resource + model files based on the architect's plan.
    # Verifies syntax after each write; retries once on syntax errors.
    # Output: lib/z/ai/resources/<n>.rb, lib/z/ai/models/<n>/response.rb
    class ImplementerAgent < BaseAgent
      def implement_resource(resource_name, plan)
        task = <<~TASK
          Implement the '#{resource_name}' resource in the Z.ai Ruby SDK.

          Implementation plan:
          #{JSON.pretty_generate(plan)}

          Steps:
          1. Read "lib/z/ai/resources/images.rb" — use as the exact template for structure
          2. Read "lib/z/ai/models/images/response.rb" — use as model template
          3. Write each file listed in plan["files"] using write_file
          4. After writing each file, call syntax_check on it
          5. If syntax errors exist, fix the content and rewrite the file
          6. Return a brief summary of files written

          Rules:
          - Start every file with: # frozen_string_literal: true
          - Resources inherit from Core::BaseAPI; include ENDPOINT constant
          - Models use Dry::Struct with a local Types module
          - Validate required params; raise Z::AI::ValidationError on bad input
          - Use proper require_relative paths (e.g. require_relative '../core/base_api')
          - Write complete, working code — NO placeholders or TODO comments
          - Do NOT modify lib/z/ai/client.rb (that is handled separately)
        TASK

        result = run(task: task)

        implementations = (@state.get(:implementations) || {})
        implementations[resource_name] = { status: 'complete', result: result }
        @state.update(:implementations, implementations)

        result
      end

      protected

      def system_prompt
        <<~PROMPT
          You are an expert Ruby developer implementing API client resources.
          Write clean, idiomatic Ruby that exactly follows the patterns in images.rb.

          Always:
          - Start with # frozen_string_literal: true
          - Use Dry::Struct for all response models
          - Add input validation with clear error messages (Z::AI::ValidationError)
          - Check syntax after writing each file; fix and rewrite if errors found
          - Write complete implementations — never use placeholder comments
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
              description: 'Write content to a file (only allowed paths)',
              parameters: {
                type: 'object',
                properties: {
                  path:    { type: 'string', description: 'Relative path from project root' },
                  content: { type: 'string', description: 'Full file content' }
                },
                required: ['path', 'content']
              }
            }
          },
          {
            type: 'function',
            function: {
              name: 'syntax_check',
              description: 'Run ruby -c on a file to verify syntax',
              parameters: {
                type: 'object',
                properties: { file_path: { type: 'string' } },
                required: ['file_path']
              }
            }
          },
          {
            type: 'function',
            function: {
              name: 'list_dir',
              description: 'List directory contents',
              parameters: {
                type: 'object',
                properties: { path: { type: 'string' } },
                required: ['path']
              }
            }
          }
        ]
      end
    end
  end
end
