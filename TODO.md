# TODO: Missing Features from Python SDK

This document outlines features that are present in the Z.ai Python SDK but not yet implemented in the Ruby SDK.

## 🔍 **Analysis Summary**

The Python SDK (`zai-sdk`) v0.2.2 has significantly more APIs than our current Ruby SDK implementation. While our Ruby SDK covers the core APIs, there are several advanced features missing.

## 📋 **Missing APIs**

### 1. **Agents API** ❌
- **Python**: `zai.api_resource.agents` - Agent management and interactions
- **Ruby**: Not implemented
- **Impact**: Advanced agent-based AI workflows unavailable

### 2. **Assistant API** ❌
- **Python**: `zai.api_resource.assistant` - Structured conversation management
- **Ruby**: Not implemented  
- **Impact**: Advanced conversation state management unavailable

### 3. **Audio Processing** ❌
- **Python**: `zai.api_resource.audio` - Speech synthesis and transcription
- **Ruby**: Not implemented
- **Impact**: Voice generation and audio transcription unavailable

### 4. **Video Generation** ❌
- **Python**: `zai.api_resource.videos` - Text-to-video and image-to-video
- **Ruby**: Not implemented
- **Impact**: Video content generation unavailable

### 5. **Voice Cloning** ❌
- **Python**: `zai.api_resource.voice` - Voice cloning and synthesis
- **Ruby**: Not implemented
- **Impact**: Advanced voice customization unavailable

### 6. **Content Moderation** ❌
- **Python**: `zai.api_resource.moderations` - Content safety and moderation
- **Ruby**: Not implemented
- **Impact**: Content filtering and safety checks unavailable

### 7. **Web Search Integration** ❌
- **Python**: `zai.api_resource.web_search` - Integrated web search
- **Ruby**: Not implemented
- **Impact**: Real-time web search capabilities unavailable

### 8. **Web Reader API** ❌
- **Python**: `zai.api_resource.web_reader` - Web content extraction
- **Ruby**: Not implemented
- **Impact**: Web page content extraction unavailable

### 9. **File Parser** ❌
- **Python**: `zai.api_resource.file_parser` - Advanced file parsing
- **Ruby**: Not implemented
- **Impact**: Complex file format parsing unavailable

### 10. **OCR (Optical Character Recognition)** ❌
- **Python**: `zai.api_resource.ocr` - Handwriting OCR and layout parsing
- **Ruby**: Not implemented
- **Impact**: Text extraction from images unavailable

### 11. **Batch Operations** ❌
- **Python**: `zai.api_resource.batch` - Batch processing operations
- **Ruby**: Not implemented
- **Impact**: Efficient batch processing unavailable

### 12. **Tool Calling** ❌
- **Python**: Advanced function calling and tool usage in chat
- **Ruby**: Basic tool support only
- **Impact**: Complex function calling workflows unavailable

## 🚧 **Missing Advanced Features**

### Character Role-Playing
- **Python**: `charglm-3` model support for character-based conversations
- **Ruby**: Not implemented

### Streaming Enhancements
- **Python**: Advanced streaming with multiple format support
- **Ruby**: Basic streaming only

### Model Variants
- **Python**: Support for `glm-4.6v`, `glm-4.7`, `cogvideox-3`
- **Ruby**: Limited model support

### Multi-Region Support
- **Python**: `ZaiClient` and `ZhipuAiClient` for different regions
- **Ruby**: Basic region support only

## 📊 **Feature Coverage Analysis**

| Feature Category | Python SDK | Ruby SDK | Gap |
|-----------------|-------------|------------|------|
| Core APIs | ✅ Complete | ✅ Complete | None |
| Advanced APIs | ✅ 11 APIs | ❌ 4 APIs | 7 missing |
| Audio/Video | ✅ Complete | ❌ Missing | 100% |
| Web Integration | ✅ Complete | ❌ Missing | 100% |
| AI Agents | ✅ Complete | ❌ Missing | 100% |
| Content Safety | ✅ Complete | ❌ Missing | 100% |

**Overall Feature Coverage: 36%**

## 🎯 **Priority Implementation Roadmap**

### Phase 1: Essential Missing APIs (High Priority)
1. **Assistant API** - Core conversation management
2. **Audio Processing** - Speech synthesis and transcription
3. **Video Generation** - Text-to-video capabilities
4. **Enhanced Tool Calling** - Advanced function calling

### Phase 2: Advanced Features (Medium Priority)
5. **Agents API** - Agent-based workflows
6. **Content Moderation** - Safety and filtering
7. **Batch Operations** - Efficient processing

### Phase 3: Specialized Features (Low Priority)
8. **Web Integration** - Search and reading
9. **Voice Cloning** - Voice customization
10. **OCR & File Parsing** - Document processing

## 🛠️ **Implementation Challenges**

### Dependency Gaps
- **Audio Processing**: Need Ruby audio libraries (parallel to Python's `librosa`)
- **Video Processing**: Need video encoding/decoding libraries
- **OCR**: Need OCR engines (parallel to Python's `pytesseract`)
- **Web Scraping**: Need robust web scraping libraries

### Type System Differences
- **Python**: Rich type hints with `pydantic` models
- **Ruby**: Limited type system, need more validation

### Async/Await
- **Python**: Native async/await support
- **Ruby**: Limited async capabilities, needs fibers or threads

## 📝 **Next Steps**

1. **Research Ruby equivalents** for missing Python dependencies
2. **Prototype missing APIs** starting with highest priority ones
3. **Add comprehensive tests** for new features
4. **Update documentation** to reflect expanded capabilities
5. **Consider version planning** for phased releases

---

**Generated**: March 9, 2026  
**Analysis Based**: Z.ai Python SDK v0.2.2 vs Ruby SDK v0.1.0  
**Total Missing Features**: 11 major APIs, 30+ advanced features