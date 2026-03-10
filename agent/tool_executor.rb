# frozen_string_literal: true

require_relative 'tools/file_tools'
require_relative 'tools/shell_tools'
require_relative 'tools/sdk_tools'

module Agent
  class ToolExecutor
    # Agents may write to these directories
    ALLOWED_WRITE_PATHS = %w[
      lib/z/ai/resources/
      lib/z/ai/models/
      spec/resources/
      examples/
      tutorials/
      agent/state/
    ].freeze

    # Agents may only append to these files
    APPEND_ONLY_PATHS = %w[
      spec/factories.rb
    ].freeze

    # No writes allowed (only patch_client_rb can touch client.rb)
    PROTECTED_PATHS = %w[
      lib/z/ai/core/
      lib/z/ai/auth/
      lib/z/ai/configuration.rb
      lib/z/ai/error.rb
      lib/z/ai/client.rb
    ].freeze

    attr_reader :project_root

    def initialize(project_root)
      @project_root = project_root
      @file_tools  = Tools::FileTools.new(self)
      @shell_tools = Tools::ShellTools.new(project_root)
      @sdk_tools   = Tools::SdkTools.new(self, project_root)
    end

    def execute(tool_name, tool_input)
      case tool_name
      when 'read_file'      then @file_tools.read_file(tool_input['path'])
      when 'write_file'     then @file_tools.write_file(tool_input['path'], tool_input['content'])
      when 'list_dir'       then @file_tools.list_dir(tool_input['path'])
      when 'run_tests'      then @shell_tools.run_tests(tool_input['spec_path'])
      when 'lint_file'      then @shell_tools.lint_file(tool_input['file_path'])
      when 'syntax_check'   then @shell_tools.syntax_check(tool_input['file_path'])
      when 'read_resource'  then @sdk_tools.read_resource(tool_input['resource_name'])
      when 'read_spec'      then @sdk_tools.read_spec(tool_input['spec_name'])
      when 'compare_coverage' then @sdk_tools.compare_coverage
      when 'patch_client_rb'
        @sdk_tools.patch_client_rb(
          tool_input['require_line'],
          tool_input['accessor_method']
        )
      else
        { error: "Unknown tool: #{tool_name}" }
      end
    rescue => e
      { error: "Tool execution failed (#{tool_name}): #{e.message}" }
    end

    # Called by FileTools before any write — enforces path whitelist
    def validate_write_path(path)
      relative = normalize_path(path)

      PROTECTED_PATHS.each do |protected_path|
        if relative.start_with?(protected_path) || relative == protected_path
          raise SecurityError, "Write denied to protected path: #{path}"
        end
      end

      allowed = ALLOWED_WRITE_PATHS.any? { |p| relative.start_with?(p) } ||
                APPEND_ONLY_PATHS.include?(relative)

      unless allowed
        raise SecurityError,
              "Write not allowed for: #{path}\nAllowed: #{ALLOWED_WRITE_PATHS.join(', ')}"
      end

      relative
    end

    private

    def normalize_path(path)
      path.sub("#{@project_root}/", '').sub(@project_root, '').sub(%r{^/}, '')
    end
  end
end
