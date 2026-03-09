# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Integration Tests', :integration do
  let(:client) { Z::AI::Client.new(api_key: ENV['ZAI_API_KEY'] || 'test_key.12345') }

  describe 'End-to-End Chat Completion' do
    it 'creates a chat completion' do
      VCR.use_cassette('chat_completion') do
        response = client.chat.completions.create(
          model: 'glm-5',
          messages: [
            { role: 'user', content: 'Say hello' }
          ]
        )

        expect(response).to be_a(Z::AI::Models::Chat::Completion)
        expect(response.id).to be_present
        expect(response.choices).to be_present
        expect(response.content).to be_present
      end
    end

    it 'streams a chat completion' do
      VCR.use_cassette('chat_stream') do
        chunks = []
        
        client.chat.completions.create(
          model: 'glm-5',
          messages: [{ role: 'user', content: 'Count to 3' }],
          stream: true
        ) do |chunk|
          chunks << chunk
        end

        expect(chunks).not_to be_empty
        expect(chunks.first).to be_a(Z::AI::Models::Chat::StreamChunk)
      end
    end
  end

  describe 'Configuration' do
    it 'configures globally' do
      Z::AI.configure do |config|
        config.api_key = 'test_key.12345'
        config.timeout = 60
      end

      expect(Z::AI.configuration.api_key).to eq('test_key.12345')
      expect(Z::AI.configuration.timeout).to eq(60)
    end

    it 'creates client with custom config' do
      custom_client = Z::AI::Client.new(
        api_key: 'custom_key',
        timeout: 45,
        max_retries: 5
      )

      expect(custom_client.config.api_key).to eq('custom_key')
      expect(custom_client.config.timeout).to eq(45)
      expect(custom_client.config.max_retries).to eq(5)
    end
  end

  describe 'Error Scenarios' do
    it 'handles authentication errors' do
      VCR.use_cassette('auth_error') do
        invalid_client = Z::AI::Client.new(api_key: 'invalid_key')
        
        expect {
          invalid_client.chat.completions.create(
            model: 'glm-5',
            messages: [{ role: 'user', content: 'test' }]
          )
        }.to raise_error(Z::AI::APIAuthenticationError)
      end
    end
  end
end
