# frozen_string_literal: true

require_relative '../lib/z/ai'

client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here'
)

puts "Embeddings API Examples"
puts "=" * 60

puts "\nExample 1: Single Text Embedding"
puts "-" * 60

response = client.embeddings.create(
  input: 'Hello, world!',
  model: 'embedding-3'
)

puts "Model: #{response.model}"
puts "Embedding dimension: #{response.first_embedding.length}"
puts "First 10 values: #{response.first_embedding[0..9]}"
puts "Tokens used: #{response.usage.total_tokens}"

puts "\nExample 2: Multiple Text Embeddings"
puts "-" * 60

texts = [
  'The quick brown fox jumps over the lazy dog',
  'Machine learning is transforming technology',
  'Ruby is a beautiful programming language'
]

response = client.embeddings.create(
  input: texts,
  model: 'embedding-3'
)

puts "Number of embeddings: #{response.embeddings.length}"
puts "All embeddings have same dimension: #{response.embeddings.map(&:length).uniq.length == 1}"

puts "\nExample 3: Semantic Similarity"
puts "-" * 60

text1 = 'I love programming in Ruby'
text2 = 'Ruby programming is enjoyable'
text3 = 'The weather is nice today'

response = client.embeddings.create(
  input: [text1, text2, text3],
  model: 'embedding-3'
)

embeddings = response.embeddings

def cosine_similarity(vec1, vec2)
  dot_product = vec1.zip(vec2).sum { |a, b| a * b }
  magnitude1 = Math.sqrt(vec1.sum { |a| a ** 2 })
  magnitude2 = Math.sqrt(vec2.sum { |a| a ** 2 })
  dot_product / (magnitude1 * magnitude2)
end

sim12 = cosine_similarity(embeddings[0], embeddings[1])
sim13 = cosine_similarity(embeddings[0], embeddings[2])
sim23 = cosine_similarity(embeddings[1], embeddings[2])

puts "Similarity between '#{text1}' and '#{text2}': #{sim12.round(4)}"
puts "Similarity between '#{text1}' and '#{text3}': #{sim13.round(4)}"
puts "Similarity between '#{text2}' and '#{text3}': #{sim23.round(4)}"

puts "\nExample 4: Document Search"
puts "-" * 60

documents = [
  'Ruby is a dynamic, open source programming language',
  'Python is great for data science and machine learning',
  'JavaScript runs in the browser and on servers',
  'Go is designed for simplicity and performance'
]

query = 'Which language is best for AI?'

all_texts = documents + [query]
response = client.embeddings.create(
  input: all_texts,
  model: 'embedding-3'
)

doc_embeddings = response.embeddings[0..-2]
query_embedding = response.embeddings.last

similarities = doc_embeddings.map.with_index do |doc_emb, idx|
  [cosine_similarity(query_embedding, doc_emb), idx]
end

ranked = similarities.sort.reverse

puts "Query: #{query}"
puts "\nRanked results:"
ranked.each_with_index do |(sim, idx), rank|
  puts "#{rank + 1}. #{documents[idx]} (similarity: #{sim.round(4)})"
end

puts "\nExample 5: Using with Options"
puts "-" * 60

response = client.embeddings.create(
  input: 'Advanced embedding example',
  model: 'embedding-3',
  encoding_format: 'float'
)

puts "Embedding created with encoding_format: float"
puts "Dimensions: #{response.first_embedding.length}"

puts "\n" + "=" * 60
puts "Embeddings examples completed!"
