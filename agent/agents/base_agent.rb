# frozen_string_literal: true

require 'dotenv/load'
require 'z/ai'
require 'json'

module Agent
  module Agents
    # Drives the Z.ai (OpenAI-compatible) tool-use loop:
    #   1. POST to GLM with messages + tool definitions
    #   2. finish_reason == "tool_calls" → execute tools, append results, loop
    #   3. finish_reason == "stop"       → extract final text, return
    #   4. Guard: max MAX_ITERATIONS to prevent runaway loops
    class BaseAgent
      MAX_ITERATIONS = 20
      DEFAULT_MODEL  = 'glm-4-plus'.freeze

      attr_reader :name, :last_response

      def initialize(tool_executor:, state:)
        @tool_executor = tool_executor
        @state         = state
        @client        = build_client
      end

      # Run the agent with a task description and optional context hash.
      # Returns the final text response from the LLM.
      def run(task:, context: {})
        messages = build_initial_messages(task, context)

        MAX_ITERATIONS.times do |iteration|
          response = call_llm(messages)
          choice   = response.choices.first
          finish   = choice.finish_reason
          message  = choice.message

          case finish
          when 'tool_calls'
            tool_calls = message.tool_calls || []

            # Execute each tool once; reuse result for logging and message history
            results = tool_calls.map { |tc| [tc, execute_tool_call(tc)] }

            results.each do |tc, result|
              parsed = JSON.parse(result)
              warn "[#{name}] iteration #{iteration + 1}: tool error — #{parsed['error']}" if parsed['error']
            rescue JSON::ParserError
              # Non-JSON tool results are acceptable
            end

            messages << { role: 'assistant', tool_calls: tool_calls.map { |tc| serialize_tool_call(tc) } }
            results.each do |tc, result|
              messages << { role: 'tool', tool_call_id: tc.id, content: result }
            end
          when 'stop'
            @last_response = message.content.to_s
            return @last_response
          else
            warn "[#{name}] Unexpected finish_reason '#{finish}' at iteration #{iteration}"
            break
          end
        end

        raise "#{name}: max iterations (#{MAX_ITERATIONS}) reached without stop"
      end

      protected

      # Subclasses must override to provide a system prompt
      def system_prompt
        raise NotImplementedError, "#{self.class} must implement #system_prompt"
      end

      # Subclasses override to declare tool definitions (OpenAI format)
      def tools
        []
      end

      def name
        self.class.name.split('::').last
      end

      private

      def build_client
        Z::AI::Client.new(api_key: ENV.fetch('ZAI_API_KEY'))
      end

      def call_llm(messages)
        params = {
          model:    DEFAULT_MODEL,
          messages: prepend_system(messages)
        }
        params[:tools] = tools unless tools.empty?

        @client.chat.completions.create(**params)
      end

      def prepend_system(messages)
        [{ role: 'system', content: system_prompt }] + messages
      end

      def build_initial_messages(task, context)
        content = task.dup
        content += "\n\nContext:\n#{JSON.pretty_generate(context)}" unless context.empty?
        [{ role: 'user', content: content }]
      end

      # Execute a single tool call object, return JSON string result
      def execute_tool_call(tool_call)
        fn   = tool_call.function
        name = fn.name
        args = JSON.parse(fn.arguments || '{}')
        @tool_executor.execute(name, args).to_json
      rescue JSON::ParserError => e
        { error: "Failed to parse tool arguments: #{e.message}" }.to_json
      end

      # Serialize a tool_call response object back to a plain hash for message history
      def serialize_tool_call(tc)
        {
          id:   tc.id,
          type: 'function',
          function: {
            name:      tc.function.name,
            arguments: tc.function.arguments
          }
        }
      end
    end
  end
end
