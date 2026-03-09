# frozen_string_literal: true

FactoryBot.define do
  factory :completion_response, class: Hash do
    id { "chatcmpl-#{SecureRandom.hex(8)}" }
    object { 'chat.completion' }
    created { Time.now.to_i }
    model { 'glm-5' }
    choices do
      [
        {
          index: 0,
          message: {
            role: 'assistant',
            content: 'Hello! How can I help you today?'
          },
          finish_reason: 'stop'
        }
      ]
    end
    usage do
      {
        prompt_tokens: 10,
        completion_tokens: 20,
        total_tokens: 30
      }
    end

    initialize_with { attributes }
  end

  factory :stream_chunk, class: Hash do
    id { "chatcmpl-#{SecureRandom.hex(8)}" }
    object { 'chat.completion.chunk' }
    created { Time.now.to_i }
    model { 'glm-5' }
    choices do
      [
        {
          index: 0,
          delta: {
            role: 'assistant',
            content: 'Hello'
          },
          finish_reason: nil
        }
      ]
    end

    initialize_with { attributes }
  end

  factory :embedding_response, class: Hash do
    object { 'list' }
    data do
      [
        {
          object: 'embedding',
          index: 0,
          embedding: Array.new(1536) { rand(-1.0..1.0) }
        }
      ]
    end
    model { 'embedding-3' }
    usage do
      {
        prompt_tokens: 5,
        total_tokens: 5
      }
    end

    initialize_with { attributes }
  end

  factory :message, class: Hash do
    role { 'user' }
    content { 'Hello, Z.ai!' }

    trait :system do
      role { 'system' }
      content { 'You are a helpful assistant.' }
    end

    trait :assistant do
      role { 'assistant' }
      content { 'How can I help you?' }
    end

    trait :multimodal do
      content do
        [
          { type: 'text', text: 'What is in this image?' },
          {
            type: 'image_url',
            image_url: {
              url: 'data:image/jpeg;base64,/9j/4AAQSkZJRg...'
            }
          }
        ]
      end
    end

    initialize_with { attributes }
  end

  factory :image_response, class: Hash do
    created { Time.now.to_i }
    data do
      [
        {
          url: "https://example.com/image-#{SecureRandom.hex(8)}.png"
        }
      ]
    end

    trait :multiple do
      data do
        [
          { url: "https://example.com/image-#{SecureRandom.hex(4)}.png" },
          { url: "https://example.com/image-#{SecureRandom.hex(4)}.png" }
        ]
      end
    end

    trait :base64 do
      data do
        [
          {
            b64_json: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
          }
        ]
      end
    end

    initialize_with { attributes }
  end

  factory :file_info, class: Hash do
    id { "file-#{SecureRandom.hex(8)}" }
    object { 'file' }
    bytes { 120000 }
    created_at { Time.now.to_i }
    filename { 'training_data.jsonl' }
    purpose { 'fine-tune' }
    status { 'processed' }

    initialize_with { attributes }
  end

  factory :files_list, class: Hash do
    object { 'list' }
    data do
      [
        build(:file_info),
        build(:file_info, id: "file-#{SecureRandom.hex(8)}", filename: 'examples.jsonl')
      ]
    end

    initialize_with { attributes }
  end

  factory :error_response, class: Hash do
    error do
      {
        message: 'Invalid API key',
        type: 'invalid_request_error',
        code: 'invalid_api_key'
      }
    end

    initialize_with { attributes }
  end
end
