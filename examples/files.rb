# frozen_string_literal: true

require_relative '../lib/z/ai'
require 'json'
require 'tempfile'

client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here'
)

puts "Files API Examples"
puts "=" * 60

puts "\nExample 1: List Files"
puts "-" * 60

files_list = client.files.list

puts "Total files: #{files_list.data.length}"
files_list.data.each do |file|
  puts "  - ID: #{file.id}"
  puts "    Name: #{file.filename}"
  puts "    Size: #{file.bytes} bytes"
  puts "    Purpose: #{file.purpose}"
  puts "    Status: #{file.status}"
  puts
end

puts "\nExample 2: Upload a File"
puts "-" * 60

training_data = [
  { prompt: 'Hello', completion: 'Hi there!' },
  { prompt: 'How are you?', completion: 'I am doing great!' },
  { prompt: 'Goodbye', completion: 'See you later!' }
]

temp_file = Tempfile.new(['training', '.jsonl'])
training_data.each do |item|
  temp_file.puts(item.to_json)
end
temp_file.rewind

puts "Uploading file: #{temp_file.path}"

uploaded_file = client.files.upload(
  file: temp_file.read,
  purpose: 'fine-tune'
)

puts "✓ File uploaded successfully!"
puts "  ID: #{uploaded_file.id}"
puts "  Bytes: #{uploaded_file.bytes}"
puts "  Purpose: #{uploaded_file.purpose}"

file_id = uploaded_file.id
temp_file.close
temp_file.unlink

puts "\nExample 3: Retrieve File Information"
puts "-" * 60

file_info = client.files.retrieve(file_id)

puts "File Details:"
puts "  ID: #{file_info.id}"
puts "  Filename: #{file_info.filename}"
puts "  Bytes: #{file_info.bytes}"
puts "  Created: #{Time.at(file_info.created_at)}"
puts "  Purpose: #{file_info.purpose}"
puts "  Status: #{file_info.status}"

puts "\nExample 4: Download File Content"
puts "-" * 60

puts "Downloading content for file: #{file_id}"
content = client.files.content(file_id)

puts "Content preview (first 200 chars):"
puts content[0..200]
puts "..."
puts "Total size: #{content.length} characters"

puts "\nExample 5: Upload Different File Types"
puts "-" * 60

file_types = [
  { purpose: 'fine-tune', data: [{ text: 'training example' }] },
  { purpose: 'assistants', data: [{ instructions: 'be helpful' }] },
  { purpose: 'batch', data: [{ request: 'batch data' }] }
]

uploaded_ids = []

file_types.each do |file_type|
  temp = Tempfile.new([file_type[:purpose], '.jsonl'])
  temp.puts(file_type[:data].to_json)
  temp.rewind
  
  puts "Uploading for purpose: #{file_type[:purpose]}"
  
  result = client.files.upload(
    file: temp.read,
    purpose: file_type[:purpose]
  )
  
  uploaded_ids << result.id
  
  puts "  ✓ Uploaded: #{result.id}"
  
  temp.close
  temp.unlink
  
  sleep(0.5)
end

puts "\nExample 6: List Files by Purpose"
puts "-" * 60

all_files = client.files.list

purposes = all_files.data.group_by(&:purpose)

purposes.each do |purpose, files|
  puts "#{purpose}: #{files.length} file(s)"
  files.each do |f|
    puts "  - #{f.filename} (#{f.bytes} bytes)"
  end
end

puts "\nExample 7: Delete Files"
puts "-" * 60

uploaded_ids.each do |id|
  puts "Deleting file: #{id}"
  
  result = client.files.delete(id)
  
  if result.deleted?
    puts "  ✓ File deleted successfully"
  else
    puts "  ✗ Failed to delete file"
  end
end

puts "\nExample 8: Complete File Lifecycle"
puts "-" * 60

test_data = [
  { input: 'test input 1', output: 'test output 1' },
  { input: 'test input 2', output: 'test output 2' }
]

temp = Tempfile.new(['lifecycle', '.jsonl'])
test_data.each { |item| temp.puts(item.to_json) }
temp.rewind

puts "1. Uploading file..."
uploaded = client.files.upload(
  file: temp.read,
  purpose: 'fine-tune'
)
puts "   Uploaded: #{uploaded.id}"

temp.close
temp.unlink

puts "\n2. Retrieving file info..."
info = client.files.retrieve(uploaded.id)
puts "   Status: #{info.status}"

puts "\n3. Downloading content..."
content = client.files.content(uploaded.id)
puts "   Downloaded #{content.length} bytes"

puts "\n4. Deleting file..."
deletion = client.files.delete(uploaded.id)
puts "   Deleted: #{deletion.deleted?}"

puts "\n5. Verifying deletion..."
begin
  client.files.retrieve(uploaded.id)
  puts "   ⚠ File still exists"
rescue Z::AI::APIResourceNotFoundError
  puts "   ✓ File successfully removed"
end

puts "\n" + "=" * 60
puts "Files examples completed!"
