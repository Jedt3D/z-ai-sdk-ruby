# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Z::AI::Resources::Images do
  let(:client) { Z::AI::Client.new(api_key: 'test_key.12345') }
  let(:images) { described_class.new(client) }

  describe '#generate' do
    let(:prompt) { 'A beautiful sunset over mountains' }
    let(:model) { 'cogview-3' }

    context 'with successful response' do
      let(:image_response) do
        {
          created: Time.now.to_i,
          data: [
            {
              url: 'https://example.com/image1.png'
            },
            {
              url: 'https://example.com/image2.png'
            }
          ]
        }
      end

      before do
        stub_zai_request(:post, 'images/generations', image_response)
      end

      it 'generates images' do
        result = images.generate(prompt: prompt, model: model)
        
        expect(result).to be_a(Z::AI::Models::Images::Response)
        expect(result.created).to be_a(Integer)
        expect(result.data).to be_present
      end

      it 'returns image URLs' do
        result = images.generate(prompt: prompt, model: model)
        
        expect(result.urls).to be_an(Array)
        expect(result.urls.length).to eq(2)
        expect(result.first_url).to eq('https://example.com/image1.png')
      end

      it 'accepts size parameter' do
        result = images.generate(
          prompt: prompt,
          model: model,
          size: '1024x1024'
        )
        
        expect(result).to be_a(Z::AI::Models::Images::Response)
      end

      it 'accepts multiple images' do
        result = images.generate(
          prompt: prompt,
          model: model,
          n: 2,
          size: '512x512'
        )
        
        expect(result).to be_a(Z::AI::Models::Images::Response)
      end

      it 'accepts response_format parameter' do
        result = images.generate(
          prompt: prompt,
          model: model,
          response_format: 'url'
        )
        
        expect(result).to be_a(Z::AI::Models::Images::Response)
      end
    end

    context 'with base64 response' do
      let(:base64_response) do
        {
          created: Time.now.to_i,
          data: [
            {
              b64_json: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
            }
          ]
        }
      end

      before do
        stub_zai_request(:post, 'images/generations', base64_response)
      end

      it 'returns base64 images' do
        result = images.generate(
          prompt: prompt,
          model: model,
          response_format: 'b64_json'
        )
        
        expect(result.base64_images).to be_an(Array)
        expect(result.base64_images.first).to be_a(String)
      end
    end

    context 'with validation errors' do
      it 'raises ValidationError for invalid size' do
        expect { images.generate(prompt: prompt, model: model, size: 'invalid') }
          .to raise_error(Z::AI::ValidationError, /Invalid size/)
      end

      it 'raises ValidationError for invalid format' do
        expect { images.generate(prompt: prompt, model: model, response_format: 'invalid') }
          .to raise_error(Z::AI::ValidationError, /Invalid format/)
      end
    end

    context 'with API errors' do
      it 'raises APIAuthenticationError for 401' do
        stub_zai_error(:post, 'images/generations', 'Invalid API key', 401)
        
        expect { images.generate(prompt: prompt, model: model) }
          .to raise_error(Z::AI::APIAuthenticationError)
      end

      it 'raises APIBadRequestError for 400' do
        stub_zai_error(:post, 'images/generations', 'Bad request', 400)
        
        expect { images.generate(prompt: prompt, model: model) }
          .to raise_error(Z::AI::APIBadRequestError)
      end
    end
  end

  describe '#create' do
    it 'is an alias for generate' do
      image_response = {
        created: Time.now.to_i,
        data: [{ url: 'https://example.com/image.png' }]
      }
      stub_zai_request(:post, 'images/generations', image_response)
      
      result = images.create(prompt: 'Test', model: 'cogview-3')
      
      expect(result).to be_a(Z::AI::Models::Images::Response)
    end
  end

  describe 'Response methods' do
    before do
      image_response = {
        created: Time.now.to_i,
        data: [
          { url: 'https://example.com/image1.png' },
          { url: 'https://example.com/image2.png' }
        ]
      }
      stub_zai_request(:post, 'images/generations', image_response)
    end

    it 'returns all URLs' do
      result = images.generate(prompt: 'Test', model: 'cogview-3')
      
      expect(result.urls.length).to eq(2)
    end

    it 'returns first URL' do
      result = images.generate(prompt: 'Test', model: 'cogview-3')
      
      expect(result.first_url).to eq('https://example.com/image1.png')
    end
  end
end
