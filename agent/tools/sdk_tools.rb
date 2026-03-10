# frozen_string_literal: true

require_relative 'file_tools'

module Agent
  module Tools
    class SdkTools
      def initialize(executor, project_root)
        @executor = executor
        @project_root = project_root
        @file_tools = FileTools.new(executor)
      end

      def read_resource(resource_name)
        path = "lib/z/ai/resources/#{resource_name}.rb"
        @file_tools.read_file(path)
      end

      def read_spec(spec_name)
        paths = [
          "spec/resources/#{spec_name}_spec.rb",
          "spec/#{spec_name}_spec.rb"
        ]

        paths.each do |path|
          result = @file_tools.read_file(path)
          return result unless result[:error]
        end

        { error: "Spec not found for: #{spec_name}" }
      end

      def compare_coverage
        todo_result = @file_tools.read_file('TODO.md')

        existing_resources = Dir.glob(File.join(@project_root, 'lib/z/ai/resources/**/*.rb'))
          .map { |f| f.sub("#{@project_root}/lib/z/ai/resources/", '').sub('.rb', '') }
          .sort

        existing_specs = Dir.glob(File.join(@project_root, 'spec/resources/**/*_spec.rb'))
          .map { |f| f.sub("#{@project_root}/spec/resources/", '').sub('_spec.rb', '') }
          .sort

        {
          todo_content: todo_result[:content],
          existing_resources: existing_resources,
          existing_specs: existing_specs,
          coverage_percentage: calculate_coverage(existing_resources)
        }
      end

      # Append-only patch to client.rb: adds require line + accessor method
      def patch_client_rb(require_line, accessor_method)
        client_path = File.join(@project_root, 'lib/z/ai/client.rb')
        content = File.read(client_path)

        # Skip if already patched
        if content.include?(require_line)
          return { success: true, message: "client.rb already contains #{require_line}" }
        end

        # Insert require after the last existing require_relative line
        last_require_match = content.match(/(require_relative '[^']+'\n)(?!require_relative)/)
        if last_require_match
          insert_after = content.rindex(last_require_match[1])
          insert_pos = insert_after + last_require_match[1].length
          content = content[0...insert_pos] + "#{require_line}\n" + content[insert_pos..]
        end

        # Insert accessor before `private` keyword inside the Client class
        private_pos = content.index("\n      private\n")
        if private_pos && !content.include?(accessor_method.strip)
          content = content[0...private_pos] + "\n#{accessor_method}\n" + content[private_pos..]
        end

        File.write(client_path, content)
        { success: true, message: "Patched client.rb with #{require_line}" }
      rescue => e
        { error: "Failed to patch client.rb: #{e.message}" }
      end

      private

      def calculate_coverage(existing_resources)
        # Known total from TODO.md: 11 missing + ~4 existing core = 15
        total_expected = 15
        implemented = existing_resources.length
        ((implemented.to_f / total_expected) * 100).round
      end
    end
  end
end
