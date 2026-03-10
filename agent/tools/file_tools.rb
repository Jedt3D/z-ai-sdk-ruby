# frozen_string_literal: true

require 'fileutils'

module Agent
  module Tools
    class FileTools
      def initialize(executor)
        @executor = executor
      end

      def read_file(path)
        full_path = resolve_path(path)
        unless File.exist?(full_path)
          return { error: "File not found: #{path}" }
        end

        { content: File.read(full_path), path: path }
      rescue => e
        { error: "Failed to read file: #{e.message}" }
      end

      def write_file(path, content)
        @executor.validate_write_path(path)
        full_path = resolve_path(path)

        FileUtils.mkdir_p(File.dirname(full_path))
        File.write(full_path, content)

        { success: true, path: path, bytes_written: content.bytesize }
      rescue SecurityError => e
        { error: e.message }
      rescue => e
        { error: "Failed to write file: #{e.message}" }
      end

      def list_dir(path)
        full_path = resolve_path(path)
        unless Dir.exist?(full_path)
          return { error: "Directory not found: #{path}" }
        end

        entries = Dir.entries(full_path)
          .reject { |e| e.start_with?('.') }
          .sort
          .map do |entry|
            full_entry = File.join(full_path, entry)
            {
              name: entry,
              type: File.directory?(full_entry) ? 'directory' : 'file',
              size: File.directory?(full_entry) ? nil : File.size(full_entry)
            }
          end

        { entries: entries, path: path }
      end

      private

      def resolve_path(path)
        if path.start_with?('/')
          path
        else
          File.join(@executor.project_root, path)
        end
      end
    end
  end
end
