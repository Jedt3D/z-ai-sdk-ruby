# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'time'

module Agent
  class State
    STATE_FILE = File.join(__dir__, 'state', 'agent_state.json').freeze

    SCHEMA = {
      version: '1.0',
      gap_report: {},
      plans: {},
      implementations: {},
      test_results: {},
      documentation: {},
      human_decisions: []
    }.freeze

    attr_reader :data

    def initialize
      @data = load_or_initialize
    end

    def load_or_initialize
      if File.exist?(STATE_FILE)
        JSON.parse(File.read(STATE_FILE), symbolize_names: true)
      else
        SCHEMA.dup
      end
    end

    def save
      FileUtils.mkdir_p(File.dirname(STATE_FILE))
      tmp_file = "#{STATE_FILE}.tmp"
      File.write(tmp_file, JSON.pretty_generate(@data))
      File.rename(tmp_file, STATE_FILE)
    end

    def update(key, value)
      @data[key.to_sym] = value
      save
    end

    def get(key)
      @data[key.to_sym]
    end

    def record_decision(decision)
      @data[:human_decisions] ||= []
      @data[:human_decisions] << { timestamp: Time.now.iso8601 }.merge(decision)
      save
    end

    def reset!
      FileUtils.rm_f(STATE_FILE)
      @data = SCHEMA.dup
    end

    def exists?
      File.exist?(STATE_FILE)
    end
  end
end
