# Keyword-Based Knowledge Search Enhancement

## Overview

This enhancement adds a new keyword-based search functionality to the knowledge retrieval system. The new feature extracts important keywords from conversation context and searches specifically in the `Answer__c` and `Question__c` fields of knowledge articles for better contextual matching.

## Key Features

### 1. Keyword Extraction from Context
The system automatically extracts important keywords from user queries, including:
- **APM** (Associate Product Manager)
- **AE** (Account Executive) 
- **Academy** (Training/Learning)
- **SME** (Subject Matter Expert)
- **Badge** (Certification/Completion)
- **ACT** (Assessment, enrollment, and session management)
- **Session** (Attendance, registration, timezone handling)
- **Profile** (Expertise, interests, language settings)
- **Media Assets** (Content completion and loading)
- **Trailhead** (Error handling and sync issues)
- **Support** (Case logging and help)
- **Seller Roster** (Schema and roster information)
- **Nomination** (Course nomination process)
- **Course** (Training courses)
- **Schema** (Technical structure)
- **Query** (Search/SQL operations)
- **Example** (Usage examples)

### 2. Targeted Field Search
Unlike the regular search that primarily looks at titles, this enhancement specifically searches:
- **Answer__c** field - Rich text content with detailed information
- **Question__c** field - Question content that might contain relevant keywords

### 3. Contextual Matching
The system is designed for scenarios where users are in the middle of conversations and ask questions like:
- "How can APM nominate courses?"
- "Tell me about AE Academy schema"
- "What is SME Finder?"
- "How do I enroll in ACT?"
- "How to register for a session?"
- "How do I log a support case?"

## Available Knowledge Articles

The system now includes access to the complete knowledge repository:

### Core Documentation
- **AE Academy Table Documentation** - Schema and table information
- **SME Finder Documentation** - Expert identification system
- **Subject-Matter-Expert (SME) Finder Topic** - Expert finder details
- **Agentforce Badge Completion** - Badge tracking and completion
- **Seller Roster Schema** - Roster and schema information

### ACT System Articles
- **ACT: Assessment Completion** - Assessment completion process
- **ACT: Assessor Swap** - Assessor management
- **ACT: Catalog Search for Content** - Content search functionality
- **ACT: Enroll** - Enrollment process
- **ACT: Event and Session Completion** - Event and session management
- **ACT: How to Log a Support Case** - Support case logging
- **ACT: LOA** - Leave of absence handling
- **ACT: Navigation Assistance** - Navigation help
- **ACT: Share Content** - Content sharing
- **ACT: Unenroll** - Unenrollment process
- **ACT: View Completion** - Completion viewing

### Session Management
- **Session: Attendance Code Error** - Attendance code troubleshooting
- **Session: Attendance Code Input** - Attendance code entry
- **Session: Registration** - Session registration
- **Session: Timezone** - Timezone handling

### Profile Management
- **Profile: Area of Expertise** - Expertise management
- **Profile: Area of Interest** - Interest management
- **Profile: Timezone / Language** - Timezone and language settings

### Media and Content
- **Media Assets: Media Completion** - Media completion tracking
- **Media Assets: Media Loading** - Media loading issues

### Error Handling
- **Trailhead: 404 Errors** - Trailhead error resolution

## Implementation Details

### New Methods Added

#### ANAgentKnowledgeService
- `searchKnowledgeByKeywords(String searchQuery, Integer maxResults)` - Main keyword search method
- `extractKeywordsFromContext(String context)` - Extracts keywords from conversation context
- `searchArticlesByKeywords(List<String> keywords, Integer maxResults)` - Searches articles by keywords
- `highlightKeywordMatches(Knowledge__kav article, List<String> keywords)` - Highlights relevant sections
- `extractRelevantSections(String content, List<String> keywords)` - Extracts keyword-containing sections

#### ANAgentKnowledgeHandler
- `searchKnowledgeByKeywords(List<KnowledgeRequest> requests)` - New invocable method
- `processKeywordKnowledgeRequest(KnowledgeRequest request)` - Processes keyword-based requests

### Usage Examples

#### Example 1: APM Nomination Query
```apex
ANAgentKnowledgeHandler.KnowledgeRequest request = new ANAgentKnowledgeHandler.KnowledgeRequest();
request.searchQuery = 'How can APM nominate courses?';
request.maxResults = 3;

List<ANAgentKnowledgeHandler.KnowledgeResponse> responses = 
    ANAgentKnowledgeHandler.searchKnowledgeByKeywords(new List<ANAgentKnowledgeHandler.KnowledgeRequest>{request});
```

**Expected Behavior:**
- Extracts keywords: "APM", "nominate", "courses"
- Searches Answer__c and Question__c fields for these terms
- Returns articles containing these keywords
- Highlights relevant sections in the response

#### Example 2: ACT Enrollment Query
```apex
ANAgentKnowledgeHandler.KnowledgeRequest request = new ANAgentKnowledgeHandler.KnowledgeRequest();
request.searchQuery = 'How do I enroll in ACT?';
request.maxResults = 3;

List<ANAgentKnowledgeHandler.KnowledgeResponse> responses = 
    ANAgentKnowledgeHandler.searchKnowledgeByKeywords(new List<ANAgentKnowledgeHandler.KnowledgeRequest>{request});
```

**Expected Behavior:**
- Extracts keywords: "ACT", "enroll"
- Searches for enrollment-related articles
- Returns "ACT: Enroll" and related articles
- Highlights enrollment-specific content

#### Example 3: Session Registration Query
```apex
ANAgentKnowledgeHandler.KnowledgeRequest request = new ANAgentKnowledgeHandler.KnowledgeRequest();
request.searchQuery = 'How to register for a session?';
request.maxResults = 3;

List<ANAgentKnowledgeHandler.KnowledgeResponse> responses = 
    ANAgentKnowledgeHandler.searchKnowledgeByKeywords(new List<ANAgentKnowledgeHandler.KnowledgeRequest>{request});
```

**Expected Behavior:**
- Extracts keywords: "Session", "register", "registration"
- Searches for session management articles
- Returns "Session: Registration" and related articles
- Highlights registration-specific content

## Agent Configuration

### New Action Available
- **Action Name**: "Search Knowledge Articles (Keyword Enhanced)"
- **Description**: "Search for information in approved knowledge articles using keyword extraction from conversation context. Ideal for contextual queries containing terms like 'APM', 'AE', 'Academy', 'SME', 'ACT', 'Session', etc."

### Input Parameters
- **User Query** (Required): The search query or conversation context
- **Max Results** (Optional): Maximum number of results (1-10, default: 3)

### Output Parameters
- **Knowledge Content**: Formatted content highlighting keyword matches
- **Matched Articles**: List of articles that contained the keywords
- **Total Results**: Number of matching articles found
- **Success**: Boolean indicating if the search was successful
- **Error Message**: Error details if the search failed

## Benefits

### 1. Better Contextual Matching
- Understands conversation context better than simple title matching
- Extracts important terms even when they're part of longer questions
- Handles various ways users might phrase their questions

### 2. Targeted Content Search
- Searches the actual content (Answer__c, Question__c) rather than just titles
- Finds relevant information even when titles don't contain the exact keywords
- Provides more comprehensive coverage of available knowledge

### 3. Flexible Keyword Recognition
- Recognizes variations of terms (e.g., "APM", "Associate Product Manager")
- Handles acronyms and full terms intelligently
- Supports all major knowledge areas in the repository

### 4. Fallback Mechanism
- If no keywords are extracted, falls back to regular search
- Ensures users always get some response
- Provides helpful suggestions when no matches are found

## Testing

Use the provided test script `test-enhanced-keyword-search.apex` to verify the functionality:

```apex
// Run the enhanced test script to see keyword extraction in action
// Execute: test-enhanced-keyword-search.apex
```

The test script includes examples for:
- APM nomination queries
- ACT enrollment queries
- Session registration queries
- Support case queries
- Profile management queries
- Trailhead error queries
- Assessment completion queries
- Media assets queries
- Generic queries (fallback testing)

## Integration with Existing System

### Backward Compatibility
- Existing "Search Knowledge Articles" action continues to work unchanged
- New keyword-enhanced search is an additional option
- Both methods can be used in the same flow

### Performance Considerations
- Keyword extraction is lightweight and fast
- Content searching is done in memory after SOQL query
- Results are limited to prevent performance issues
- Enhanced with all available knowledge articles

### Security
- Uses the same security model as existing knowledge search
- Only searches allowed knowledge articles
- Maintains all existing permission checks

## Best Practices

### When to Use Keyword-Enhanced Search
- User queries contain specific terms like "APM", "AE", "SME", "ACT", "Session"
- Users are asking contextual questions in the middle of conversations
- You want to search content rather than just titles
- Users are asking "how to" or "what is" questions
- Queries involve enrollment, assessment, session management, or support

### When to Use Regular Search
- Simple topic searches (e.g., "AE Academy")
- When you want broader, title-based matching
- When performance is critical and you need faster results

### Agent Configuration Tips
- Use keyword-enhanced search as the primary method for conversational queries
- Keep regular search as a fallback option
- Set appropriate max results (3-5 is usually sufficient)
- Provide clear error messages when no results are found
- Leverage the expanded knowledge repository for comprehensive coverage

## Future Enhancements

Potential improvements for future versions:
1. **Machine Learning Keyword Extraction**: Use ML models for better keyword recognition
2. **Semantic Similarity**: Add semantic matching alongside keyword matching
3. **User Feedback Integration**: Learn from user interactions to improve keyword extraction
4. **Dynamic Keyword Patterns**: Allow configuration of keyword patterns without code changes
5. **Multi-language Support**: Extend keyword extraction to support multiple languages
6. **Article Relevance Scoring**: Implement scoring to rank results by relevance
7. **Conversation History Integration**: Use previous conversation context for better keyword extraction 