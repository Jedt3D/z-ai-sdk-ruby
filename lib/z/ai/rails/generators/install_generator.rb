# frozen_string_literal: true

require 'rails/generators/base'

module Z
  module AI
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path('../templates', __FILE__)

        desc 'Creates a Z.ai configuration file at config/z_ai.yml'

        def create_config_file
          template 'z_ai.yml', 'config/z_ai.yml'
        end

        def create_initializer
          template 'z_ai_initializer.rb', 'config/initializers/z_ai.rb'
        end

        def add_console_helper
          inject_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do
            <<-RUBY

    # Z.ai SDK console helper
    console do
      zai_client = Z::AI::Client.new
      Rails.logger.info "Z.ai SDK loaded. Use zai_client to interact with the API."
    end
            RUBY
          end
        end

        def show_readme
          readme 'README' if behavior == :invoke
        end
      end
    end
  end
end
