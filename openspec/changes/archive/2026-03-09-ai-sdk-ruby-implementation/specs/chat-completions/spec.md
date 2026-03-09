## ADDED Requirements

### Requirement: Chat completion creation
The SDK SHALL allow users to create chat completions using Z.ai chat models with configurable parameters.

#### Scenario: Basic chat completion
- **WHEN** user requests a chat completion with model and messages
- **THEN** system returns a completion response with generated content
- **AND** response includes metadata (id, created timestamp, model, usage)

#### Scenario: Chat completion with custom parameters
- **WHEN** user requests completion with temperature, max_tokens, and other parameters
- **THEN** system applies parameters to influence generation behavior
- **AND** response reflects parameter usage in results

### Requirement: Streaming chat completions
The SDK SHALL support streaming responses for real-time chat completion delivery.

#### Scenario: Block-based streaming
- **WHEN** user requests streaming completion with block parameter
- **THEN** system yields chunks as they are generated
- **AND** chunks contain delta content and metadata

#### Scenario: Enumerator-based streaming
- **WHEN** user requests streaming completion without block
- **THEN** system returns Enumerator for iteration
- **AND** enumerator yields sequential chunks

### Requirement: Message format support
The SDK SHALL support multiple message formats including text, system, assistant, and multimodal content.

#### Scenario: Simple text messages
- **WHEN** user provides messages with role and content strings
- **THEN** system processes messages in correct order
- **AND** conversation context is maintained

#### Scenario: Multimodal messages
- **WHEN** user provides messages with text and image content
- **THEN** system processes both text and image inputs
- **AND** generation considers all provided content

### Requirement: Error handling for chat API
The SDK SHALL provide proper error handling for chat completion requests and responses.

#### Scenario: Invalid request handling
- **WHEN** user provides invalid parameters or missing required fields
- **THEN** system raises ValidationError with descriptive message
- **AND** error includes field-level validation details

#### Scenario: API error handling
- **WHEN** Z.ai API returns error responses
- **THEN** system raises appropriate error type (APIError, RateLimitError, etc.)
- **AND** error includes HTTP status and API error details