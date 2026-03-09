## ADDED Requirements

### Requirement: Text embedding generation
The SDK SHALL allow users to generate vector embeddings for text input using Z.ai embedding models.

#### Scenario: Single text embedding
- **WHEN** user provides single text string for embedding
- **THEN** system returns vector representation of the text
- **AND** response includes embedding dimensions and usage metadata

#### Scenario: Multiple text embeddings
- **WHEN** user provides array of text strings
- **THEN** system returns array of corresponding embeddings
- **AND** each embedding maintains order correlation with input texts

### Requirement: Embedding model selection
The SDK SHALL support different embedding models with varying capabilities and dimensions.

#### Scenario: Default embedding model
- **WHEN** user requests embedding without specifying model
- **THEN** system uses default embedding model
- **AND** embedding dimensions match model specifications

#### Scenario: Custom embedding model
- **WHEN** user specifies embedding model parameter
- **THEN** system uses specified model for generation
- **AND** embedding characteristics match selected model

### Requirement: Embedding usage tracking
The SDK SHALL provide token usage information for embedding requests.

#### Scenario: Usage metadata
- **WHEN** user generates embeddings
- **THEN** system returns token usage statistics
- **AND** usage includes prompt tokens and total tokens

### Requirement: Error handling for embeddings API
The SDK SHALL provide proper error handling for embedding generation requests.

#### Scenario: Invalid input handling
- **WHEN** user provides empty or invalid text input
- **THEN** system raises ValidationError with descriptive message
- **AND** error specifies validation requirements

#### Scenario: Model error handling
- **WHEN** specified embedding model is unavailable
- **THEN** system raises APIError with model information
- **AND** error suggests available models