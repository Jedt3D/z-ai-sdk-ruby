#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'tty-prompt'
require 'json'
require 'fileutils'

# Extend load path so agents can require 'z/ai'
$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))

require_relative 'state'
require_relative 'tool_executor'
require_relative 'agents/analyst_agent'
require_relative 'agents/architect_agent'
require_relative 'agents/implementer_agent'
require_relative 'agents/tester_agent'
require_relative 'agents/scribe_agent'

module Agent
  class Orchestrator
    PROJECT_ROOT    = File.expand_path('..', __dir__).freeze
    MAX_TEST_CYCLES = 3

    def initialize
      @prompt   = TTY::Prompt.new
      @state    = State.new
      @executor = ToolExecutor.new(PROJECT_ROOT)
      setup_signal_handlers
    end

    # ─── Public entry point ──────────────────────────────────────────────────

    def run(options)
      if options[:resume]
        resume_run
      elsif options[:agent]
        run_single_agent(options[:agent])
      elsif options[:resource]
        run_single_resource(options[:resource])
      elsif options[:full_run]
        full_run
      else
        puts 'Usage: ruby agent/orchestrator.rb [--agent AGENT | --resource RESOURCE | --full-run | --resume]'
        exit 1
      end
    end

    private

    # ─── Single agent mode ────────────────────────────────────────────────────

    def run_single_agent(agent_name)
      case agent_name
      when 'analyst'
        log 'Running AnalystAgent...'
        analyst = Agents::AnalystAgent.new(tool_executor: @executor, state: @state)
        report  = analyst.analyze_gaps
        log "Gap report saved to agent/state/gap_report.json"
        puts JSON.pretty_generate(report)
      else
        puts "Unknown agent: #{agent_name}. Available: analyst"
        exit 1
      end
    end

    # ─── Single resource mode ─────────────────────────────────────────────────

    def run_single_resource(resource_name)
      log "Starting full pipeline for: #{resource_name}"
      gap_details = load_gap_details(resource_name)
      run_resource_pipeline(resource_name, gap_details)
    end

    # ─── Full run mode ────────────────────────────────────────────────────────

    def full_run
      log 'Starting full run...'

      # Step 1 — Analyze gaps
      log "\n[1/3] Analyzing SDK gaps..."
      analyst    = Agents::AnalystAgent.new(tool_executor: @executor, state: @state)
      gap_report = analyst.analyze_gaps
      missing    = gap_report['missing_resources'] || []
      log "Found #{missing.length} missing resources."

      # HITL Gate 1 — choose which gaps to tackle
      selected = gate_1_select_resources(gap_report)
      return log('Nothing selected. Exiting.') if selected.empty?

      @state.record_decision(gate: 1, selected_resources: selected)

      # Step 2 — Per-resource pipeline
      selected.each do |resource|
        gap_details = gap_report.dig('resource_details', resource) || {}
        run_resource_pipeline(resource, gap_details)
      end

      # Step 3 — Final coverage report
      log "\n[3/3] Generating final report..."
      final_analyst = Agents::AnalystAgent.new(tool_executor: @executor, state: @state)
      final_report  = final_analyst.analyze_gaps
      log "Final coverage: #{final_report['coverage_percentage']}%"
      log 'Done! State: agent/state/agent_state.json'
    end

    # ─── Resource pipeline (DAG nodes 2a–2d) ─────────────────────────────────

    def run_resource_pipeline(resource_name, gap_details = {})
      log "\n#{'─' * 50}"
      log "Pipeline: #{resource_name}"
      log '─' * 50

      # 2a — Architect
      log '[2a] ArchitectAgent: planning...'
      architect = Agents::ArchitectAgent.new(tool_executor: @executor, state: @state)
      plan      = architect.plan_resource(resource_name, gap_details)
      log "     Planned #{(plan['files'] || []).length} files."

      # HITL Gate 2 — review plan
      unless gate_2_review_plan(resource_name, plan)
        return log("Skipping #{resource_name} (plan rejected)")
      end

      @state.record_decision(gate: 2, resource: resource_name, decision: 'approved')

      # 2b — Implement
      log '[2b] ImplementerAgent: writing files...'
      implementer    = Agents::ImplementerAgent.new(tool_executor: @executor, state: @state)
      implementation = implementer.implement_resource(resource_name, plan)

      # HITL Gate 3 — diff review
      unless gate_3_review_implementation(resource_name, plan)
        return log("Skipping #{resource_name} (implementation rejected)")
      end

      # Patch client.rb
      patch_client(plan['client_changes']) if plan['client_changes']
      @state.record_decision(gate: 3, resource: resource_name, decision: 'approved')

      # 2c — Test (with retry loop)
      log '[2c] TesterAgent: writing + running tests...'
      run_tests_with_retry(resource_name, plan, implementation)

      # 2d — Document
      log '[2d] ScribeAgent: writing documentation...'
      scribe = Agents::ScribeAgent.new(tool_executor: @executor, state: @state)
      scribe.write_documentation(resource_name, plan, implementation)

      log "Pipeline complete: #{resource_name}"
    end

    # ─── Test retry loop ──────────────────────────────────────────────────────

    def run_tests_with_retry(resource_name, plan, implementation)
      MAX_TEST_CYCLES.times do |attempt|
        log "  Test attempt #{attempt + 1}/#{MAX_TEST_CYCLES}..."
        tester = Agents::TesterAgent.new(tool_executor: @executor, state: @state)
        result = tester.write_and_run_tests(resource_name, plan, implementation)

        if tests_passing?(result)
          log '  Tests passing!'
          test_results = (@state.get(:test_results) || {})
          test_results[resource_name] = { status: 'passing', run_count: attempt + 1 }
          @state.update(:test_results, test_results)
          return result
        end

        log "  Tests failed (attempt #{attempt + 1})."
      end

      # HITL Gate 4 — all attempts exhausted
      gate_4_test_failure(resource_name)
    end

    def tests_passing?(result)
      result.match?(/0 failures/) ||
        (result.match?(/passed/) && !result.match?(/failed/)) ||
        result.match?(/0 examples, 0 failures/)
    end

    # ─── HITL Gates ───────────────────────────────────────────────────────────

    # Gate 1: Multi-select which gaps to implement
    def gate_1_select_resources(gap_report)
      missing  = gap_report['missing_resources'] || []
      priority = gap_report['priority'] || {}

      puts "\n#{'=' * 60}"
      puts 'GATE 1: Which gaps should the agents implement?'
      puts '=' * 60

      return [] if missing.empty?

      choices = missing.map do |r|
        pri = priority.find { |_, v| Array(v).include?(r) }&.first || 'low'
        { name: "#{r} (#{pri} priority)", value: r }
      end

      @prompt.multi_select(
        'Select resources to implement (space to toggle, enter to confirm):',
        choices,
        per_page: 15,
        echo: true
      )
    end

    # Gate 2: Review implementation plan; continue / edit / skip
    def gate_2_review_plan(resource_name, plan)
      puts "\n#{'=' * 60}"
      puts "GATE 2: Review plan for '#{resource_name}'"
      puts '=' * 60
      display_plan(plan)

      choice = @prompt.select('What would you like to do?') do |menu|
        menu.choice 'Continue with this plan',  :continue
        menu.choice 'Edit plan in $EDITOR',      :edit
        menu.choice "Skip #{resource_name}",     :skip
      end

      case choice
      when :continue then true
      when :edit
        edit_plan_in_editor(resource_name, plan)
        true
      when :skip then false
      end
    end

    # Gate 3: Show newly created files; approve / edit manually / skip
    def gate_3_review_implementation(resource_name, plan)
      puts "\n#{'=' * 60}"
      puts "GATE 3: Review implementation for '#{resource_name}'"
      puts '=' * 60

      (plan['files'] || []).each do |file_spec|
        path = File.join(PROJECT_ROOT, file_spec['path'])
        next unless File.exist?(path)

        puts "\n--- #{file_spec['path']} (#{File.size(path)} bytes) ---"
        show_file_preview(path)
      end

      choice = @prompt.select('Approve implementation?') do |menu|
        menu.choice 'Approve and continue',          :approve
        menu.choice 'Edit manually then continue',   :edit
        menu.choice "Skip #{resource_name}",         :skip
      end

      case choice
      when :approve then true
      when :edit
        @prompt.say('Edit files, then press Enter to continue...')
        $stdin.gets
        true
      when :skip then false
      end
    end

    # Gate 4: Tests failed MAX_TEST_CYCLES times — escalate to human
    def gate_4_test_failure(resource_name)
      puts "\n#{'=' * 60}"
      puts "GATE 4: Tests failed #{MAX_TEST_CYCLES}× for '#{resource_name}'"
      puts '=' * 60

      choice = @prompt.select('How would you like to proceed?') do |menu|
        menu.choice 'Fix manually, then re-run tests',   :fix
        menu.choice "Skip #{resource_name}",             :skip
      end

      @state.record_decision(gate: 4, resource: resource_name, decision: choice.to_s)

      case choice
      when :fix
        @prompt.say("Fix the files manually. Press Enter when ready to re-run tests...")
        $stdin.gets
        tester = Agents::TesterAgent.new(tool_executor: @executor, state: @state)
        tester.write_and_run_tests(resource_name, {}, 'manual_fix')
      when :skip
        log "Skipping #{resource_name} after test failures."
        nil
      end
    end

    # ─── Helpers ──────────────────────────────────────────────────────────────

    def display_plan(plan)
      if plan.is_a?(Hash) && !plan['parse_error']
        puts "\nResource : #{plan['resource_name']}"
        puts "Endpoint : #{plan['api_endpoint']}"
        puts 'Files to create:'
        (plan['files'] || []).each do |f|
          puts "  • #{f['path']}"
          puts "    #{f['description']}"
        end
        puts "Notes    : #{plan['notes']}" if plan['notes']
      else
        puts JSON.pretty_generate(plan)
      end
    end

    def show_file_preview(path)
      lines   = File.readlines(path)
      preview = lines.first(40)
      preview.each { |l| print l }
      puts "\n... (#{lines.length} lines total)" if lines.length > 40
    end

    def edit_plan_in_editor(resource_name, plan)
      tmp    = "/tmp/#{resource_name}_plan.json"
      editor = ENV.fetch('EDITOR', 'vi')
      File.write(tmp, JSON.pretty_generate(plan))
      system("#{editor} #{tmp}")

      updated = JSON.parse(File.read(tmp))
      plans   = (@state.get(:plans) || {})
      plans[resource_name] = { status: 'edited', plan: updated }
      @state.update(:plans, plans)
      updated
    rescue => e
      log "Failed to open editor: #{e.message} — using original plan"
      plan
    end

    def patch_client(client_changes)
      require_line    = client_changes['require_line']
      accessor_method = client_changes['accessor_method']
      return unless require_line && accessor_method

      result = @executor.execute('patch_client_rb', {
        'require_line'    => require_line,
        'accessor_method' => accessor_method
      })

      if result[:success] || result['success']
        log "  Patched client.rb: #{require_line}"
      else
        log "  Warning: #{result[:error] || result['error']}"
      end
    end

    def load_gap_details(resource_name)
      gap_report = @state.get(:gap_report)
      return {} unless gap_report

      (gap_report['resource_details'] || {})[resource_name] || {}
    end

    def resume_run
      unless @state.exists?
        puts 'No saved state found. Start fresh without --resume.'
        exit 1
      end

      log 'Resuming from saved state...'
      plans           = @state.get(:plans) || {}
      implementations = @state.get(:implementations) || {}

      incomplete = plans.keys.reject do |r|
        implementations[r.to_s]&.fetch(:status, nil) == 'complete' ||
          implementations[r.to_sym]&.fetch(:status, nil) == 'complete'
      end

      if incomplete.empty?
        log 'All resources complete. Nothing to resume.'
        return
      end

      log "Resuming #{incomplete.length} resource(s): #{incomplete.join(', ')}"
      incomplete.each do |resource|
        plan = plans.dig(resource, :plan) || plans.dig(resource.to_sym, :plan) || {}
        run_resource_pipeline(resource.to_s, plan)
      end
    end

    def setup_signal_handlers
      Signal.trap('INT') do
        # Use puts inside trap (thread-safe)
        puts "\n\nInterrupted — saving state..."
        @state.save
        puts 'Saved. Resume with: ruby agent/orchestrator.rb --resume'
        exit 0
      end
    end

    def log(msg)
      puts "[#{Time.now.strftime('%H:%M:%S')}] #{msg}"
    end
  end
end

# ─── CLI entry point ─────────────────────────────────────────────────────────

options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby agent/orchestrator.rb [options]'
  opts.separator ''
  opts.separator 'Options:'

  opts.on('--agent AGENT',       'Run a single agent (e.g. analyst)')     { |v| options[:agent]    = v }
  opts.on('--resource RESOURCE', 'Run all agents for one resource')        { |v| options[:resource] = v }
  opts.on('--full-run',          'Run the full pipeline for all gaps')     {     options[:full_run]  = true }
  opts.on('--resume',            'Resume from last saved state')           {     options[:resume]    = true }
  opts.on('-h', '--help',        'Show this help')                         { puts opts; exit }
end.parse!

Agent::Orchestrator.new.run(options)
