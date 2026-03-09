# Files API

## Overview

The Files API manages files for fine-tuning and batch processing operations.

## Quick Start

```ruby
client = Z::AI::Client.new(api_key: 'your-api-key')

# Upload a file
content = JSON.generate([
  { prompt: 'Hello', completion: 'Hi!' }
])
uploaded = client.files.upload(
  file: content,
  purpose: 'fine-tune'
)

puts "Uploaded: #{uploaded.id}"
```

## Methods

### upload

Uploads a file to Z.ai.

**Signature:**

```ruby
def upload(file:, purpose:)
```

**Parameters:**

- `file` (String, required) - File content
- `purpose` (String, required) - Purpose of file

**Purposes:**
- `fine-tune` - Training data for fine-tuning
- `assistants` - Files for assistants
- `batch` - Batch processing
- `vision` - Images for vision

**Returns:** `Z::AI::Models::Files::FileInfo`

**Example:**

```ruby
file_content = JSON.generate([
  { prompt: 'Question?', completion: 'Answer.' }
])

file = client.files.upload(
  file: file_content,
  purpose: 'fine-tune'
)

puts "File ID: #{file.id}"
```

### list

Lists all uploaded files.

**Signature:**

```ruby
def list
```

**Returns:** `Z::AI::Models::Files::ListResponse`

**Example:**

```ruby
files = client.files.list

files.data.each do |file|
  puts "#{file.filename} (#{file.bytes} bytes)"
end
```

### retrieve

Gets file information by ID.

**Signature:**

```ruby
def retrieve(file_id)
```

**Parameters:**

- `file_id` (String, required) - File ID

**Returns:** `Z::AI::Models::Files::FileInfo`

**Example:**

```ruby
file = client.files.retrieve('file-123456')
puts "Filename: #{file.filename}"
puts "Purpose: #{file.purpose}"
```

### content

Downloads file content.

**Signature:**

```ruby
def content(file_id)
```

**Parameters:**

- `file_id` (String, required) - File ID

**Returns:** String (file content)

**Example:**

```ruby
content = client.files.content('file-123456')
puts content
```

### delete

Deletes a file.

**Signature:**

```ruby
def delete(file_id)
```

**Parameters:**

- `file_id` (String, required) - File ID

**Returns:** `Z::AI::Models::Files::DeleteResponse`

**Example:**

```ruby
result = client.files.delete('file-123456')
puts "Deleted: #{result.deleted?}"
```

## File Info Object

```ruby
file.id              # => "file-123456"
file.object          # => "file"
file.bytes           # => 12345
file.created_at      # => 1234567890
file.filename        # => "training_data.jsonl"
file.purpose         # => "fine-tune"
file.status          # => "processed"
```

## Complete Example

```ruby
# Upload
file_content = JSON.generate([
  { prompt: 'Hello', completion: 'Hi!' },
  { prompt: 'Bye', completion: 'Goodbye!' }
])

uploaded = client.files.upload(
  file: file_content,
  purpose: 'fine-tune'
)

# List
all_files = client.files.list
puts "Total files: #{all_files.data.length}"

# Retrieve
file_info = client.files.retrieve(uploaded.id)
puts "Status: #{file_info.status}"

# Download
content = client.files.content(uploaded.id)
puts "Content length: #{content.length}"

# Delete
result = client.files.delete(uploaded.id)
puts "Deleted: #{result.deleted?}"
```

## Best Practices

1. **Validate File Format**: Ensure files match expected format
2. **Clean Up Old Files**: Delete unused files regularly
3. **Monitor Status**: Check file processing status
4. **Use Appropriate Purpose**: Match purpose to use case

## Error Handling

```ruby
begin
  file = client.files.retrieve('invalid-id')
rescue Z::AI::APIResourceNotFoundError => e
  puts "File not found: #{e.message}"
rescue Z::AI::FileSizeError => e
  puts "File too large: #{e.message}"
rescue Z::AI::Error => e
  puts "File operation failed: #{e.message}"
end
```

## See Also

- [Chat API](CHAT_API.md)
- [Configuration](CONFIGURATION.md)
