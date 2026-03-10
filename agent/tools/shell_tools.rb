# frozen_string_literal: true

require 'open3'

module Agent
  module Tools
    class ShellTools
      TIMEOUT = 30 # seconds

      def initialize(project_root)
        @project_root = project_root
      end

      def syntax_check(file_path)
        full_path = resolve_path(file_path)
        run_command("ruby -c #{full_path}")
      end

      def run_tests(spec_path)
        full_path = spec_path.start_with?('/') ? spec_path : resolve_path(spec_path)
        run_command("bundle exec rspec #{full_path} --format documentation", cwd: @project_root)
      end

      def lint_file(file_path)
        full_path = resolve_path(file_path)
        run_command("bundle exec rubocop --autocorrect-all #{full_path}", cwd: @project_root)
      end

      private

      def resolve_path(path)
        path.start_with?('/') ? path : File.join(@project_root, path)
      end

      def run_command(command, cwd: @project_root)
        stdout, stderr, status = Open3.capture3(command, chdir: cwd)

        {
          command: command,
          stdout: stdout,
          stderr: stderr,
          exit_code: status.exitstatus,
          success: status.success?
        }
      rescue Errno::ENOENT => e
        { error: "Command not found: #{e.message}", success: false }
      rescue => e
        { error: "Command failed: #{e.message}", success: false }
      end
    end
  end
end
