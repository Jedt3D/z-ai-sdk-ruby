# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Z::AI::Configuration do
  subject(:config) { described_class.new }

  describe '#initialize' do
    it 'sets default values' do
      expect(config.base_url).to eq('https://api.z.ai/api/paas/v4/')
      expect(config.timeout).to eq(30)
      expect(config.max_retries).to eq(3)
      expect(config.source_channel).to eq('ruby-sdk')
      expect(config.disable_token_cache).to be false
    end

    it 'reads api_key from environment' do
      ENV['ZAI_API_KEY'] = 'test_key'
      config = described_class.new
      expect(config.api_key).to eq('test_key')
    end

    it 'reads base_url from environment' do
      ENV['ZAI_BASE_URL'] = 'https://custom.z.ai/'
      config = described_class.new
      expect(config.base_url).to eq('https://custom.z.ai/')
    end
  end

  describe '#validate!' do
    context 'with valid configuration' do
      before { config.api_key = 'valid_key.12345' }

      it 'returns true' do
        expect(config.validate!).to be true
      end
    end

    context 'without api_key' do
      before { config.api_key = nil }

      it 'raises ConfigurationError' do
        expect { config.validate! }.to raise_error(Z::AI::ConfigurationError, /API key is required/)
      end
    end

    context 'with empty api_key' do
      before { config.api_key = '' }

      it 'raises ConfigurationError' do
        expect { config.validate! }.to raise_error(Z::AI::ConfigurationError, /API key is required/)
      end
    end

    context 'without base_url' do
      before do
        config.api_key = 'valid_key'
        config.base_url = nil
      end

      it 'raises ConfigurationError' do
        expect { config.validate! }.to raise_error(Z::AI::ConfigurationError, /Base URL is required/)
      end
    end
  end

  describe '#merge' do
    it 'merges two configurations' do
      config.api_key = 'key1'
      config.timeout = 30
      
      other = described_class.new
      other.api_key = 'key2'
      other.timeout = 60
      
      merged = config.merge(other)
      
      expect(merged.api_key).to eq('key2')
      expect(merged.timeout).to eq(60)
    end

    it 'preserves values not in other config' do
      config.api_key = 'key1'
      config.timeout = 30
      
      other = described_class.new
      other.api_key = nil
      
      merged = config.merge(other)
      
      expect(merged.api_key).to eq('key1')
      expect(merged.timeout).to eq(30)
    end
  end

  describe '#to_h' do
    before do
      config.api_key = 'test_key'
      config.timeout = 60
    end

    it 'returns configuration as hash' do
      hash = config.to_h
      
      expect(hash).to be_a(Hash)
      expect(hash[:api_key]).to eq('test_key')
      expect(hash[:timeout]).to eq(60)
      expect(hash[:max_retries]).to eq(3)
    end
  end
end
