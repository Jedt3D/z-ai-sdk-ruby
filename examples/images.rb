# frozen_string_literal: true

require_relative '../lib/z/ai'
require 'fileutils'

client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here'
)

puts "Images API Examples"
puts "=" * 60

puts "\nExample 1: Basic Image Generation"
puts "-" * 60

response = client.images.generate(
  prompt: 'A serene mountain landscape at sunset',
  model: 'cogview-3'
)

puts "Generated #{response.data.length} image(s)"
puts "Image URL: #{response.first_url}"
puts "Created at: #{Time.at(response.created)}"

puts "\nExample 2: Multiple Images"
puts "-" * 60

response = client.images.generate(
  prompt: 'A futuristic city with flying cars',
  model: 'cogview-3',
  n: 2,
  size: '1024x1024'
)

puts "Generated #{response.urls.length} images:"
response.urls.each_with_index do |url, idx|
  puts "  #{idx + 1}. #{url}"
end

puts "\nExample 3: Different Sizes"
puts "-" * 60

sizes = ['256x256', '512x512', '1024x1024']

sizes.each do |size|
  puts "Generating image with size: #{size}"
  
  response = client.images.generate(
    prompt: 'A cute robot painting art',
    model: 'cogview-3',
    size: size
  )
  
  puts "  ✓ Generated: #{response.first_url}"
end

puts "\nExample 4: Base64 Response Format"
puts "-" * 60

response = client.images.generate(
  prompt: 'A colorful abstract painting',
  model: 'cogview-3',
  response_format: 'b64_json',
  size: '512x512'
)

if response.base64_images.any?
  puts "Received #{response.base64_images.length} base64-encoded image(s)"
  
  FileUtils.mkdir_p('tmp/images')
  
  response.base64_images.each_with_index do |b64, idx|
    filename = "tmp/images/generated_#{idx}_#{Time.now.to_i}.png"
    File.binwrite(filename, Base64.decode64(b64))
    puts "  ✓ Saved to: #{filename}"
  end
else
  puts "No base64 images received"
end

puts "\nExample 5: Creative Prompts"
puts "-" * 60

prompts = [
  'A magical treehouse in an enchanted forest',
  'An astronaut playing guitar on Mars',
  'A steampunk coffee machine',
  'Underwater city with bioluminescent buildings',
  'A library made entirely of crystal'
]

prompts.each_with_index do |prompt, idx|
  puts "\nPrompt #{idx + 1}: #{prompt}"
  
  response = client.images.generate(
    prompt: prompt,
    model: 'cogview-3',
    size: '512x512'
  )
  
  puts "  URL: #{response.first_url}"
  
  sleep(1) if idx < prompts.length - 1
end

puts "\nExample 6: Using the create alias"
puts "-" * 60

response = client.images.create(
  prompt: 'A minimalist logo design for a tech startup',
  model: 'cogview-3',
  size: '1024x1024'
)

puts "Image created using 'create' method: #{response.first_url}"

puts "\nExample 7: Error Handling"
puts "-" * 60

begin
  client.images.generate(
    prompt: 'Test image',
    model: 'cogview-3',
    size: 'invalid_size'
  )
rescue Z::AI::ValidationError => e
  puts "Validation Error: #{e.message}"
end

begin
  client.images.generate(
    prompt: 'Test image',
    model: 'cogview-3',
    response_format: 'invalid_format'
  )
rescue Z::AI::ValidationError => e
  puts "Validation Error: #{e.message}"
end

puts "\n" + "=" * 60
puts "Images examples completed!"
puts "\nNote: Some examples may have created images in tmp/images/"
