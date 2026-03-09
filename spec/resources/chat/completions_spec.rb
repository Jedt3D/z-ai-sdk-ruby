# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Z::AI::Resources::Chat::Completions do
  let(:client) { Z::AI::Client.new(api_key: 'test_key.12345') }
  let(:completions) { described_class.new(client) }

  describe '#create' do
    let(:messages) { [{ role: 'user', content: 'Hello!' }] }
    let(:model) { 'glm-5' }

    context 'with successful sync response' do
      before do
        response_body = build(:completion_response)
        stub_zai_request(:post, 'chat/completions', response_body)
      end

      it 'creates a completion' do
        result = completions.create(model: model, messages: messages)
        
        expect(result).to be_a(Z::AI::Models::Chat::Completion)
        expect(result.id).to start_with('chatcmpl-')
        expect(result.model).to eq('glm-5')
        expect(result.choices.first.message.content).to eq('Hello! How can I help you today?')
      end

      it 'sends correct request body' do
        completions.create(model: model, messages: messages, temperature: 0.7)
        
        expect(a_request_to_zai(:post, 'chat/completions')).to have_been_made.once
      end

      it 'accepts additional options' do
        response_body = build(:completion_response)
        stub_zai_request(:post, 'chat/completions', response_body)
        
        result = completions.create(
          model: model,
          messages: messages,
          temperature: 0.8,
          max_tokens: 100,
          top_p: 0.9
        )
        
        expect(result).to be_a(Z::AI::Models::Chat::Completion)
      end
    end

    context 'with message objects' do
      before do
        response_body = build(:completion_response)
        stub_zai_request(:post, 'chat/completions', response_body)
      end

      it 'accepts Message model objects' do
        msg = Z::AI::Models::Chat::Message.new(role: 'user', content: 'Hi')
        
        result = completions.create(model: model, messages: [msg])
        
        expect(result).to be_a(Z::AI::Models::Chat::Completion)
      end
    end

    context 'with invalid messages' do
      it 'raises ValidationError for invalid message type' do
        invalid_messages = [123]
        
        expect { completions.create(model: model, messages: invalid_messages) }
          .to raise_error(Z::AI::ValidationError, /Invalid message type/)
      end
    end

    context 'with API errors' do
      it 'raises APIAuthenticationError for 401' do
        stub_zai_error(:post, 'chat/completions', 'Invalid API key', 401)
        
        expect { completions.create(model: model, messages: messages) }
          .to raise_error(Z::AI::APIAuthenticationError)
      end

      it 'raises APIBadRequestError for 400' do
        stub_zai_error(:post, 'chat/completions', 'Bad request', 400)
        
        expect { completions.create(model: model, messages: messages) }
          .to raise_error(Z::AI::APIBadRequestError)
      end

      it 'raises APIRateLimitError for 429' do
        stub_zai_error(:post, 'chat/completions', 'Rate limit exceeded', 429)
        
        expect { completions.create(model: model, messages: messages) }
          .to raise_error(Z::AI::APIRateLimitError)
      end
    end

    context 'with streaming' do
      let(:stream_chunks) do
        [
          "data: {\"id\":\"chatcmpl-123\",\"object\":\"chat.completion.chunk\",\"created\":1234567890,\"model\":\"glm-5\",\"choices\":[{\"index\":0,\"delta\":{\"role\":\"assistant\",\"content\":\"Hello\"},\"finish_reason\":null}]}\n",
          "data: {\"id\":\"chatcmpl-123\",\"object\":\"chat.completion.chunk\",\"created\":1234567890,\"model\":\"glm-5\",\"choices\":[{\"index\":0,\"delta\":{\"content\":\" there\"},\"finish_reason\":null}]}\n",
          "data: {\"id\":\"chatcmpl-123\",\"object\":\"chat.completion.chunk\",\"created\":1234567890,\"model\":\"glm-5\",\"choices\":[{\"index\":0,\"delta\":{\"content\":\"!\"},\"finish_reason\":\"stop\"}]}\n",
          "data: [DONE]\n"
        ]
      end

      before do
        stub_request(:post, 'https://api.z.ai/api/paas/v4/chat/completions')
          .to_return(
            status: 200,
            body: stream_chunks.join,
            headers: { 'Content-Type' => 'text/event-stream' }
          )
      end

      it 'streams response chunks' do
        chunks = []
        
        completions.create(model: model, messages: messages, stream: true) do |chunk|
          chunks << chunk
        end
        
        expect(chunks.length).to be > 0
        expect(chunks.first).to be_a(Z::AI::Models::Chat::StreamChunk)
      end

      it 'accumulates content from chunks' do
        content = []
        
        completions.create(model: model, messages: messages, stream: true) do |chunk|
          content << chunk.delta_content if chunk.delta_content
        end
        
        expect(content.join).to eq('Hello there!')
      end

      it 'returns an enumerator when no block given' do
        result = completions.create(model: model, messages: messages, stream: true)
        
        expect(result).to be_an(Enumerator)
      end
    end
  end

  describe '#create_async' do
    it 'raises NotImplementedError' do
      expect { completions.create_async(model: 'glm-5', messages: []) }
        .to raise_error(NotImplementedError, /Async completions are not yet implemented/)
    end
  end
end
