# frozen_string_literal: true

require 'active_job'

module Z
  module AI
    module Rails
      # Base job for Z.ai API calls
      class BaseJob < ActiveJob::Base
        queue_as :z_ai

        # Automatically retry on transient failures
        retry_on Z::AI::APITimeoutError, wait: :exponentially_longer, attempts: 3
        retry_on Z::AI::APIConnectionError, wait: :exponentially_longer, attempts: 3

        # Don't retry on permanent failures
        discard_on Z::AI::APIAuthenticationError
        discard_on Z::AI::ValidationError

        before_perform :log_job_start
        after_perform :log_job_complete

        private

        def client
          @client ||= Z::AI::Client.new
        end

        def log_job_start
          Rails.logger.info("[Z::AI Job] Starting #{self.class.name} (Job ID: #{job_id})")
        end

        def log_job_complete
          Rails.logger.info("[Z::AI Job] Completed #{self.class.name} (Job ID: #{job_id})")
        end

        def handle_api_error(error)
          Rails.logger.error("[Z::AI Job] Error in #{self.class.name}: #{error.message}")
          Rails.logger.error(error.backtrace[0..10].join("\n"))
          
          # Re-raise to let ActiveJob handle retry logic
          raise error
        end
      end

      # Example: Chat completion job
      class ChatCompletionJob < BaseJob
        queue_as :z_ai_chat

        def perform(model:, messages:, callback_url: nil, **options)
          response = client.chat.completions.create(
            model: model,
            messages: messages,
            **options
          )

          result = {
            id: response.id,
            content: response.choices.first.message.content,
            model: response.model,
            usage: response.usage&.to_h
          }

          if callback_url
            send_callback(callback_url, result)
          end

          result
        rescue Z::AI::Error => e
          handle_api_error(e)
        end

        private

        def send_callback(url, data)
          # Send result to callback URL
          uri = URI.parse(url)
          Net::HTTP.post(uri, data.to_json, 'Content-Type' => 'application/json')
        rescue => e
          Rails.logger.error("[Z::AI Job] Callback failed: #{e.message}")
        end
      end

      # Example: Embedding job
      class EmbeddingJob < BaseJob
        queue_as :z_ai_embeddings

        def perform(texts:, model:, callback_url: nil, **options)
          response = client.embeddings.create(
            input: texts,
            model: model,
            **options
          )

          result = {
            embeddings: response.embeddings,
            model: response.model,
            usage: response.usage&.to_h
          }

          if callback_url
            send_callback(callback_url, result)
          end

          result
        rescue Z::AI::Error => e
          handle_api_error(e)
        end

        private

        def send_callback(url, data)
          uri = URI.parse(url)
          Net::HTTP.post(uri, data.to_json, 'Content-Type' => 'application/json')
        rescue => e
          Rails.logger.error("[Z::AI Job] Callback failed: #{e.message}")
        end
      end
    end
  end
end
