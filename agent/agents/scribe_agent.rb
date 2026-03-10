# frozen_string_literal: true

require_relative 'base_agent'

module Agent
  module Agents
    # Writes runnable examples, step-by-step walkthroughs, and tutorials.
    # Output: examples/<n>.rb, examples/walkthrough_<n>.md, tutorials/NN_<n>.md
    class ScribeAgent < BaseAgent
      def write_documentation(resource_name, plan, implementation_result)
        tutorial_num = next_tutorial_number

        task = <<~TASK
          Write examples and documentation for the '#{resource_name}' resource.

          Implementation summary: #{implementation_result}
          Plan: #{JSON.pretty_generate(plan)}

          Steps:
          1. Read "examples/walkthrough_basic_chat.md" — use as walkthrough format template
          2. Read "lib/z/ai/resources/#{resource_name}.rb" — actual method signatures
          3. Write "examples/#{resource_name}.rb" — a runnable example script
          4. Run syntax_check on the example file; fix and rewrite if it fails
          5. Write "examples/walkthrough_#{resource_name}.md" — step-by-step walkthrough
          6. Write "tutorials/#{tutorial_num}_#{resource_name}.md" — learning tutorial

          Example file (examples/#{resource_name}.rb) requirements:
          - Start with: # frozen_string_literal: true
          - Require the SDK: require 'z/ai'
          - Use ENV['ZAI_API_KEY'] for credentials
          - Show all major methods with inline comments
          - Must pass ruby -c syntax check

          Walkthrough (examples/walkthrough_#{resource_name}.md) requirements:
          - Step-by-step guide with numbered sections
          - Include runnable code snippets with expected output
          - Add troubleshooting tips at the end

          Tutorial (tutorials/#{tutorial_num}_#{resource_name}.md) requirements:
          - Educational focus: explain *why*, not just *how*
          - Cover prerequisites, key concepts, practical examples
          - Include exercises for the reader
        TASK

        result = run(task: task)

        documentation = (@state.get(:documentation) || {})
        documentation[resource_name] = { status: 'complete', result: result }
        @state.update(:documentation, documentation)

        result
      end

      protected

      def system_prompt
        <<~PROMPT
          You are a technical writer specializing in Ruby SDK documentation.
          Write clear, educational content that helps developers understand and use the SDK.

          Always:
          - Write complete, runnable code (not pseudocode)
          - Comment every significant code block
          - Use ENV['ZAI_API_KEY'] — never hardcode credentials
          - Reference actual method names from the implementation
          - Keep walkthroughs practical and progressive
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
              name: 'syntax_check',
              description: 'Check Ruby syntax of a file',
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

      private

      def next_tutorial_number
        pattern = File.join(File.expand_path('../../tutorials', __dir__), '*.md')
        existing = Dir.glob(pattern)
        format('%02d', existing.length + 1)
      end
    end
  end
end
