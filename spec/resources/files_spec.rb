# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Z::AI::Resources::Files do
  let(:client) { Z::AI::Client.new(api_key: 'test_key.12345') }
  let(:files) { described_class.new(client) }
  let(:file_id) { 'file-1234567890' }

  describe '#list' do
    context 'with successful response' do
      let(:files_response) do
        {
          object: 'list',
          data: [
            {
              id: 'file-123',
              object: 'file',
              bytes: 120000,
              created_at: Time.now.to_i,
              filename: 'training_data.jsonl',
              purpose: 'fine-tune',
              status: 'processed'
            },
            {
              id: 'file-456',
              object: 'file',
              bytes: 80000,
              created_at: Time.now.to_i,
              filename: 'examples.jsonl',
              purpose: 'fine-tune',
              status: 'processed'
            }
          ]
        }
      end

      before do
        stub_zai_request(:get, 'files', files_response)
      end

      it 'lists all files' do
        result = files.list
        
        expect(result).to be_a(Z::AI::Models::Files::ListResponse)
        expect(result.data).to be_an(Array)
        expect(result.data.length).to eq(2)
      end

      it 'returns file objects' do
        result = files.list
        
        expect(result.files.first.id).to eq('file-123')
        expect(result.files.first.filename).to eq('training_data.jsonl')
        expect(result.files.first.purpose).to eq('fine-tune')
      end
    end
  end

  describe '#upload' do
    let(:file_content) { '{"text": "example"}' }
    let(:purpose) { 'fine-tune' }

    context 'with successful upload' do
      let(:upload_response) do
        {
          id: 'file-new123',
          object: 'file',
          bytes: file_content.length,
          created_at: Time.now.to_i,
          filename: 'uploaded.jsonl',
          purpose: purpose,
          status: 'uploaded'
        }
      end

      before do
        stub_zai_request(:post, 'files/upload', upload_response)
      end

      it 'uploads a file' do
        result = files.upload(file: file_content, purpose: purpose)
        
        expect(result).to be_a(Z::AI::Models::Files::FileInfo)
        expect(result.id).to eq('file-new123')
        expect(result.purpose).to eq(purpose)
      end

      it 'accepts valid purposes' do
        %w[fine-tune assistants batch vision].each do |valid_purpose|
          stub_zai_request(:post, 'files/upload', upload_response)
          
          result = files.upload(file: file_content, purpose: valid_purpose)
          expect(result.purpose).to eq(valid_purpose)
        end
      end
    end

    context 'with validation errors' do
      it 'raises ValidationError for invalid purpose' do
        expect { files.upload(file: file_content, purpose: 'invalid') }
          .to raise_error(Z::AI::ValidationError, /Invalid purpose/)
      end
    end
  end

  describe '#retrieve' do
    context 'with successful response' do
      let(:file_response) do
        {
          id: file_id,
          object: 'file',
          bytes: 120000,
          created_at: Time.now.to_i,
          filename: 'example.jsonl',
          purpose: 'fine-tune',
          status: 'processed'
        }
      end

      before do
        stub_zai_request(:get, "files/#{file_id}", file_response)
      end

      it 'retrieves file information' do
        result = files.retrieve(file_id)
        
        expect(result).to be_a(Z::AI::Models::Files::FileInfo)
        expect(result.id).to eq(file_id)
        expect(result.filename).to eq('example.jsonl')
      end
    end

    context 'with API errors' do
      it 'raises APIResourceNotFoundError for 404' do
        stub_zai_error(:get, "files/#{file_id}", 'File not found', 404)
        
        expect { files.retrieve(file_id) }
          .to raise_error(Z::AI::APIResourceNotFoundError)
      end
    end
  end

  describe '#delete' do
    context 'with successful deletion' do
      let(:delete_response) do
        {
          id: file_id,
          object: 'file',
          deleted: true
        }
      end

      before do
        stub_zai_request(:delete, "files/#{file_id}", delete_response)
      end

      it 'deletes a file' do
        result = files.delete(file_id)
        
        expect(result).to be_a(Z::AI::Models::Files::DeleteResponse)
        expect(result.id).to eq(file_id)
        expect(result.deleted?).to be true
      end
    end

    context 'with failed deletion' do
      let(:delete_response) do
        {
          id: file_id,
          object: 'file',
          deleted: false
        }
      end

      before do
        stub_zai_request(:delete, "files/#{file_id}", delete_response)
      end

      it 'returns deleted false' do
        result = files.delete(file_id)
        
        expect(result.deleted?).to be false
      end
    end
  end

  describe '#content' do
    let(:file_content) { 'line1\nline2\nline3' }

    before do
      stub_request(:get, "https://api.z.ai/api/paas/v4/files/#{file_id}/content")
        .to_return(
          status: 200,
          body: file_content,
          headers: { 'Content-Type' => 'application/octet-stream' }
        )
    end

    it 'retrieves file content' do
      result = files.content(file_id)
      
      expect(result).to eq(file_content)
    end
  end
end
