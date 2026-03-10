# frozen_string_literal: true

require_relative 'base_agent'
require 'json'
require 'fileutils'

module Agent
  module Agents
    # Reads the SDK codebase + TODO.md and produces a gap report JSON.
    # Output: agent/state/gap_report.json + state[:gap_report]
    class AnalystAgent < BaseAgent
      GAP_REPORT_PATH = File.join(__dir__, '..', 'state', 'gap_report.json').freeze

      def analyze_gaps
        task = <<~TASK
          Analyze the Z.ai Ruby SDK to identify gaps compared to the Python SDK.

          Steps:
          1. Call compare_coverage to get current resource and spec inventory
          2. Call read_file with path "TODO.md" to read the detailed gap analysis
          3. Call list_dir with path "lib/z/ai/resources" to confirm existing resources
          4. Call read_file with path "lib/z/ai/client.rb" to understand the client structure

          Based on this analysis, produce a comprehensive gap report as a JSON object.
          Output ONLY valid JSON (no markdown fences, no explanation text), structured as:
          {
            "missing_resources": ["video", "audio", "agents", "assistant", "moderations",
                                  "web_search", "web_reader", "file_parser", "ocr", "batch", "voice"],
            "coverage_percentage": 36,
            "priority": {
              "high": ["assistant", "audio", "video"],
              "medium": ["agents", "moderations", "batch"],
              "low": ["web_search", "web_reader", "file_parser", "ocr", "voice"]
            },
            "resource_details": {
              "video": {
                "python_class": "videos",
                "endpoints": ["videos/generations"],
                "description": "Text-to-video and image-to-video generation",
                "api_endpoint": "videos/generations"
              }
            }
          }
        TASK

        result  = run(task: task)
        report  = parse_json_response(result)

        @state.update(:gap_report, report)
        save_gap_report(report)

        report
      end

      protected

      def system_prompt
        <<~PROMPT
          You are an expert Ruby SDK analyst specializing in API coverage analysis.
          Compare the Z.ai Ruby SDK with the Python SDK reference (described in TODO.md) to identify gaps.

          Be systematic: read actual files before drawing conclusions.
          Your final output must be ONLY a valid JSON object — no prose, no markdown code fences.
        PROMPT
      end

      def tools
        [
          {
            type: 'function',
            function: {
              name: 'read_file',
              description: 'Read a file from the project by relative path',
              parameters: {
                type: 'object',
                properties: { path: { type: 'string', description: 'Relative path from project root' } },
                required: ['path']
              }
            }
          },
          {
            type: 'function',
            function: {
              name: 'list_dir',
              description: 'List the contents of a directory',
              parameters: {
                type: 'object',
                properties: { path: { type: 'string', description: 'Relative path to directory' } },
                required: ['path']
              }
            }
          },
          {
            type: 'function',
            function: {
              name: 'compare_coverage',
              description: 'Get current SDK coverage: existing resources, specs, and TODO gaps',
              parameters: {
                type: 'object',
                properties: {},
                required: []
              }
            }
          }
        ]
      end

      private

      def parse_json_response(text)
        # Try raw JSON first, then strip markdown fences
        JSON.parse(text.strip)
      rescue JSON::ParserError
        stripped = text.gsub(/```(?:json)?\s*/, '').gsub(/```\s*$/, '').strip
        JSON.parse(stripped)
      rescue JSON::ParserError => e
        { raw_response: text, parse_error: e.message }
      end

      def save_gap_report(report)
        FileUtils.mkdir_p(File.dirname(GAP_REPORT_PATH))
        File.write(GAP_REPORT_PATH, JSON.pretty_generate(report))
      end
    end
  end
end
