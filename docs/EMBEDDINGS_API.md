# Embeddings API

## Overview

The Embeddings API generates vector representations of text that can be used for semantic search, clustering, and similarity calculations.

## Quick Start

```ruby
client = Z::AI::Client.new(api_key: 'your-api-key')

response = client.embeddings.create(
  input: 'Hello, world!',
  model: 'embedding-3'
)

embedding = response.first_embedding
puts "Dimensions: #{embedding.length}"
```

## Methods

### create

Creates embeddings for text input.

**Signature:**

```ruby
def create(input:, model:, **options)
```

**Parameters:**

- `input` (String/Array, required) - Text or array of texts to embed
- `model` (String, required) - Embedding model to use
- `**options` (Hash) - Additional parameters

**Additional Options:**

- `encoding_format` (String) - Encoding format ('float' or 'base64')

**Returns:** `Z::AI::Models::Embeddings::Response`

**Example:**

```ruby
# Single text
response = client.embeddings.create(
  input: 'Ruby is a programming language',
  model: 'embedding-3'
)

# Multiple texts
response = client.embeddings.create(
  input: ['Ruby', 'Python', 'JavaScript'],
  model: 'embedding-3'
)
```

## Response Object

```ruby
response.object         # => "list"
response.data           # => Array of EmbeddingData objects
response.model          # => "embedding-3"
response.usage          # => Usage object

# Helper methods
response.embeddings      # => Array of embedding vectors
response.first_embedding # => First embedding vector
```

## Use Cases

### Semantic Search

```ruby
def search_similar(query, documents, top_k: 5)
  # Generate query embedding
  query_response = client.embeddings.create(
    input: query,
    model: 'embedding-3'
  )
  query_embedding = query_response.first_embedding
  
  # Generate document embeddings
  doc_response = client.embeddings.create(
    input: documents,
    model: 'embedding-3'
  )
  
  # Calculate similarities
  similarities = doc_response.embeddings.map.with_index do |embedding, idx|
    [idx, cosine_similarity(query_embedding, embedding)]
  end
  
  # Sort and return top k
  similarities.sort_by { |_, score| -score }.first(top_k)
end

def cosine_similarity(vec1, vec2)
  dot_product = vec1.zip(vec2).sum { |a, b| a * b }
  magnitude1 = Math.sqrt(vec1.sum { |x| x ** 2 })
  magnitude2 = Math.sqrt(vec2.sum { |x| x ** 2 })
  dot_product / (magnitude1 * magnitude2)
end
```

### Clustering

```ruby
documents = [...]
response = client.embeddings.create(
  input: documents,
  model: 'embedding-3'
)

# Use embeddings for clustering
embeddings = response.embeddings
# Apply clustering algorithm (k-means, etc.)
```

## Available Models

- `embedding-3` - Latest embedding model (recommended)
- `embedding-2` - Previous generation model

## Best Practices

1. **Batch Requests**: Embed multiple texts in single request
2. **Cache Embeddings**: Store embeddings to avoid recomputation
3. **Normalize Vectors**: For some use cases, normalize embedding vectors
4. **Choose Right Model**: Use `embedding-3` for best quality

## See Also

- [Chat API](CHAT_API.md)
- [Configuration](CONFIGURATION.md)
