## ADDED Requirements

### Requirement: Image generation from text
The SDK SHALL allow users to generate images from text prompts using Z.ai image generation models.

#### Scenario: Basic image generation
- **WHEN** user provides text prompt for image generation
- **THEN** system returns generated image URL
- **AND** response includes image metadata (dimensions, model, etc.)

#### Scenario: Multiple image generation
- **WHEN** user specifies multiple images (n parameter)
- **THEN** system generates specified number of images
- **AND** each image varies based on prompt and randomness

### Requirement: Image size and format options
The SDK SHALL support various image sizes and output formats.

#### Scenario: Size selection
- **WHEN** user specifies image size parameter
- **THEN** system generates images with specified dimensions
- **AND** supported sizes include 256x256, 512x512, 1024x1024

#### Scenario: Format selection
- **WHEN** user requests base64 image format
- **THEN** system returns base64 encoded image data
- **AND** user can decode and save image locally

### Requirement: Image model selection
The SDK SHALL support different image generation models with varying capabilities.

#### Scenario: Default image model
- **WHEN** user requests image generation without model specification
- **THEN** system uses default image generation model
- **AND** image quality matches model capabilities

#### Scenario: Custom image model
- **WHEN** user specifies image model parameter
- **THEN** system uses specified model for generation
- **AND** image characteristics match selected model

### Requirement: Image response handling
The SDK SHALL provide flexible ways to handle image generation responses.

#### Scenario: URL responses
- **WHEN** user requests URL format
- **THEN** system returns image URLs
- **AND** URLs are accessible for download

#### Scenario: Base64 responses
- **WHEN** user requests base64 format
- **THEN** system returns base64 encoded images
- **AND** data can be decoded to image files

### Requirement: Error handling for images API
The SDK SHALL provide proper error handling for image generation requests.

#### Scenario: Content policy violations
- **WHEN** user prompt violates content policies
- **THEN** system raises ContentPolicyError
- **AND** error specifies policy violation type

#### Scenario: Model unavailability
- **WHEN** requested image model is unavailable
- **THEN** system raises ModelUnavailableError
- **AND** error suggests alternative models