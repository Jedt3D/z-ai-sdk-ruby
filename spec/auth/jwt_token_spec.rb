# frozen_string_literal: true

require 'spec_helper'
require 'jwt'

RSpec.describe Z::AI::Auth::JWTToken do
  let(:valid_api_key) { 'id123.secret456' }
  let(:invalid_api_key) { 'invalid_key' }

  before { described_class.clear_cache }

  describe '.generate_token' do
    context 'with valid API key' do
      it 'generates a JWT token' do
        token = described_class.generate_token(valid_api_key)
        
        expect(token).to be_a(String)
        expect(token.split('.').length).to eq(3)
      end

      it 'includes correct payload' do
        token = described_class.generate_token(valid_api_key)
        decoded = JWT.decode(token, 'secret456', true, algorithm: 'HS256')
        
        payload = decoded.first
        expect(payload['api_key']).to eq('id123')
        expect(payload['exp']).to be > Time.now.to_i
      end

      it 'caches the token' do
        token1 = described_class.generate_token(valid_api_key)
        token2 = described_class.generate_token(valid_api_key)
        
        expect(token1).to eq(token2)
        
        stats = described_class.cache_stats
        expect(stats[:size]).to eq(1)
      end
    end

    context 'with invalid API key' do
      it 'raises JWTGenerationError for nil key' do
        expect { described_class.generate_token(nil) }
          .to raise_error(Z::AI::JWTGenerationError, /API key is required/)
      end

      it 'raises JWTGenerationError for empty key' do
        expect { described_class.generate_token('') }
          .to raise_error(Z::AI::JWTGenerationError, /API key is required/)
      end

      it 'raises JWTGenerationError for malformed key' do
        expect { described_class.generate_token(invalid_api_key) }
          .to raise_error(Z::AI::JWTGenerationError, /Invalid API key format/)
      end
    end
  end

  describe '.clear_cache' do
    it 'clears all cached tokens' do
      described_class.generate_token(valid_api_key)
      
      expect(described_class.cache_stats[:size]).to eq(1)
      
      described_class.clear_cache
      
      expect(described_class.cache_stats[:size]).to eq(0)
    end
  end

  describe '.cache_stats' do
    it 'returns cache statistics' do
      described_class.generate_token(valid_api_key)
      
      stats = described_class.cache_stats
      
      expect(stats).to be_a(Hash)
      expect(stats[:size]).to eq(1)
      expect(stats[:keys]).to be_an(Array)
      expect(stats[:keys].length).to eq(1)
    end
  end

  describe 'token expiry' do
    it 'generates new token after expiry' do
      token1 = described_class.generate_token(valid_api_key)
      
      cache_key = described_class.send(:cache_key_for, valid_api_key)
      Z::AI::Auth::JWTToken.class_variable_get(:@@token_cache)[cache_key][:expires_at] = Time.now - 1
      
      token2 = described_class.generate_token(valid_api_key)
      
      expect(token1).not_to eq(token2)
    end
  end
end
