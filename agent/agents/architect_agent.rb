# frozen_string_literal: true

require_relative 'base_agent'
require 'json'

module Agent
  module Agents
    # Plans implementation of a single resource: determines files, endpoints,
    # model shapes, and client.rb changes needed.
    # Output: state[:plans][resource_name]
    class ArchitectAgent < BaseAgent
      def plan_resource(resource_name, gap_details = {})
        camelized = camelize(resource_name)

        task = <<~TASK
          Create a detailed implementation plan for the '#{resource_name}' resource in the Z.ai Ruby SDK.

          Steps:
          1. Read "lib/z/ai/resources/images.rb" — canonical resource template
          2. Read "lib/z/ai/models/images/response.rb" — canonical model template
          3. Read "lib/z/ai/models/chat/completion.rb" — nested Dry::Struct model example
          4. Read "lib/z/ai/client.rb" — to understand how resources are wired in

          Gap information for this resource:
          #{JSON.pretty_generate(gap_details)}

          Output ONLY a valid JSON implementation plan (no markdown, no prose):
          {
            "resource_name": "#{resource_name}",
            "api_endpoint": "#{resource_name}/generations",
            "files": [
              {
                "path": "lib/z/ai/resources/#{resource_name}.rb",
                "description": "Resource class with ENDPOINT, validation, and main method",
                "methods": [
                  {"name": "create", "params": ["required_param:"], "description": "Main creation method"}
                ]
              },
              {
                "path": "lib/z/ai/models/#{resource_name}/response.rb",
                "description": "Dry::Struct response model",
                "attributes": [
                  {"name": "id", "type": "String", "required": true}
                ]
              }
            ],
            "client_changes": {
              "require_line": "require_relative 'resources/#{resource_name}'",
              "accessor_method": "      def #{resource_name}\\n        @#{resource_name} ||= Resources::#{camelized}.new(self)\\n      end"
            },
            "notes": "Any special implementation notes"
          }
        TASK

        result = run(task: task)
        plan   = parse_json_response(result)

        plans = (@state.get(:plans) || {})
        plans[resource_name] = { status: 'planned', plan: plan }
        @state.update(:plans, plans)

        plan
      end

      protected

      def system_prompt
        <<~PROMPT
          You are a senior Ruby SDK architect. Design clean, consistent API resource implementations
          that match the existing Z.ai Ruby SDK patterns exactly.

          Key conventions to follow:
          - Resources inherit from Core::BaseAPI with ENDPOINT constant
          - Models use Dry::Struct with explicit Types module
          - Validation raises Z::AI::ValidationError with descriptive messages
          - Constants for valid enum values (e.g. VALID_SIZES)
          - Main method + alias pattern (generate/create)
          - Keyword arguments with ** splat for optional params

          Output ONLY valid JSON — no markdown fences, no explanation.
        PROMPT
      end

      def tools
        [
          {
            type: 'function',
            function: {
              name: 'read_file',
              description: 'Read a project file by relative path',
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

      def camelize(str)
        str.split('_').map(&:capitalize).join
      end

      def parse_json_response(text)
        JSON.parse(text.strip)
      rescue JSON::ParserError
        stripped = text.gsub(/```(?:json)?\s*/, '').gsub(/```\s*$/, '').strip
        JSON.parse(stripped)
      rescue JSON::ParserError => e
        { raw_response: text, parse_error: e.message }
      end
    end
  end
end
