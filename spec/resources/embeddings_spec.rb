# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Z::AI::Resources::Embeddings do
  let(:client) { Z::AI::Client.new(api_key: 'test_key.12345') }
  let(:embeddings) { described_class.new(client) }

  describe '#create' do
    let(:model) { 'embedding-3' }

    context 'with successful response' do
      before do
        response_body = build(:embedding_response)
        stub_zai_request(:post, 'embeddings', response_body)
      end

      it 'creates embeddings' do
        result = embeddings.create(
          input: 'Hello, world!',
          model: model
        )
        
        expect(result).to be_a(Z::AI::Models::Embeddings::Response)
        expect(result.model).to eq('embedding-3')
        expect(result.data).to be_present
        expect(result.first_embedding).to be_an(Array)
      end

      it 'accepts string input' do
        result = embeddings.create(
          input: 'Test string',
          model: model
        )
        
        expect(result).to be_a(Z::AI::Models::Embeddings::Response)
      end

      it 'accepts array input' do
        result = embeddings.create(
          input: ['Hello', 'World'],
          model: model
        )
        
        expect(result).to be_a(Z::AI::Models::Embeddings::Response)
      end

      it 'accepts additional options' do
        response_body = build(:embedding_response)
        stub_zai_request(:post, 'embeddings', response_body)
        
        result = embeddings.create(
          input: 'Test',
          model: model,
          encoding_format: 'float'
        )
        
        expect(result).to be_a(Z::AI::Models::Embeddings::Response)
      end
    end

    context 'with invalid input' do
      it 'raises ValidationError for invalid input type' do
        expect { embeddings.create(input: 123, model: model) }
          .to raise_error(Z::AI::ValidationError, /Input must be a string or array/)
      end
    end

    context 'with API errors' do
      it 'raises APIAuthenticationError for 401' do
        stub_zai_error(:post, 'embeddings', 'Invalid API key', 401)
        
        expect { embeddings.create(input: 'Test', model: model) }
          .to raise_error(Z::AI::APIAuthenticationError)
      end

      it 'raises APIBadRequestError for 400' do
        stub_zai_error(:post, 'embeddings', 'Bad request', 400)
        
        expect { embeddings.create(input: 'Test', model: model) }
          .to raise_error(Z::AI::APIBadRequestError)
      end
    end
  end

  describe 'Response methods' do
    before do
      response_body = build(:embedding_response)
      stub_zai_request(:post, 'embeddings', response_body)
    end

    it 'returns embeddings array' do
      result = embeddings.create(input: 'Test', model: 'embedding-3')
      
      expect(result.embeddings).to be_an(Array)
      expect(result.embeddings.first).to be_an(Array)
    end

    it 'returns first embedding' do
      result = embeddings.create(input: 'Test', model: 'embedding-3')
      
      expect(result.first_embedding).to be_an(Array)
    end

    it 'returns usage information' do
      result = embeddings.create(input: 'Test', model: 'embedding-3')
      
      expect(result.usage.prompt_tokens).to be_a(Integer)
      expect(result.usage.total_tokens).to be_a(Integer)
    end
  end
end
