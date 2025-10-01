# ANAgentKnowledgeRetriever - Agentforce Integration Guide

## Overview
The `ANAgentKnowledgeRetriever` class provides secure, targeted knowledge retrieval from explicitly identified Salesforce Knowledge articles. This ensures your agent only has access to specific, approved knowledge content.

## Invocable Method Details

### Method Information
- **Method Name**: `retrieveKnowledge`
- **Label**: "Retrieve Targeted Knowledge"
- **Description**: "Retrieve knowledge from explicitly identified articles only"

### Input Parameters

#### 1. searchQuery (REQUIRED)
- **Type**: String
- **Description**: The search term to find in knowledge articles
- **Examples**: 
  - "AE Academy"
  - "SME Finder"
  - "Data Cloud"
  - "Agentforce Badge"
- **Note**: Only searches within explicitly allowed articles

#### 2. searchType (OPTIONAL)
- **Type**: String
- **Default**: 'all'
- **Valid Values**:
  - `'title'` - Search only in article titles
  - `'content'` - Search in titles, questions, and answers (with post-query filtering)
  - `'all'` - Search across all fields (same as 'content' due to SOQL limitations)
- **Note**: Rich text fields cannot be filtered in SOQL, so content search uses Apex filtering

#### 3. maxResults (OPTIONAL)
- **Type**: Integer
- **Default**: 5
- **Description**: Maximum number of articles to return
- **Range**: 1-50 (recommended)
- **Note**: Actual results may be fewer if fewer matching articles exist

### Output Parameters

#### 1. success (Boolean)
- `true`: Request processed successfully (even if no results found)
- `false`: Error occurred during processing

#### 2. knowledgeContent (String)
- Contains the formatted knowledge article content
- **Format**: Each article starts with "=== [Title] ===" followed by content
- **Includes**: Question, Answer, Description, Article ID, URL Name
- **HTML tags are stripped** for clean text output
- **If no results**: Contains "No matching knowledge articles found for: [query]"

#### 3. matchedArticles (String)
- Comma-separated list of article titles that matched the search
- **Example**: "AE Academy Table Documentation, SME Finder Documentation"
- Empty string if no matches found

#### 4. totalResults (Integer)
- Number of articles returned
- 0 if no matches found
- May be less than maxResults if fewer articles match

#### 5. errorMessage (String)
- Contains error details if success = false
- **Common errors**:
  - "Search query is required" - Empty or null search query
  - "Query error: [details]" - SOQL or processing errors
- Empty string if success = true

## Security Features

### Access Control
- **Only articles explicitly listed** in `ALLOWED_KNOWLEDGE_IDS` or `ALLOWED_ARTICLE_TITLES` are accessible
- **Articles must be published** (`PublishStatus = 'Online'`) and latest version (`IsLatestVersion = true`)
- **All queries are filtered** by allowed articles before any search is performed

### Current Allowed Articles
1. **AE Academy Table Documentation** (ID: ka0D7000000TQUHIA4)
   - Contains AE Academy table schema, examples, and usage
2. **Subject-Matter-Expert (SME) Finder Topic** (ID: ka0D7000000TQUCIA4)
   - Contains SME Finder topic documentation
3. **SME Finder Documentation** (ID: ka0D7000000TQU7IAO)
   - Contains complete SME Finder table documentation
4. **Agentforce Badge Completion** (ID: ka0D7000000TQTsIAO)
   - Contains Agentforce badge program documentation

## Usage Examples

### Example 1: Search for AE Academy Content
```json
{
  "searchQuery": "AE Academy",
  "searchType": "all",
  "maxResults": 3
}
```

### Example 2: Search by Title Only
```json
{
  "searchQuery": "SME Finder",
  "searchType": "title",
  "maxResults": 2
}
```

### Example 3: Limit Results
```json
{
  "searchQuery": "Data Cloud",
  "maxResults": 1
}
```

## Expected Responses

### Successful Response
```json
{
  "success": true,
  "knowledgeContent": "=== AE Academy Table Documentation ===\nAnswer: Table Documentation: AE_ACADEMY\n1. Metadata\nFull Table Name: SSE_DM_GDSO_PRD.SELLER_INSIGHTS.AE_ACADEMY\n...",
  "matchedArticles": "AE Academy Table Documentation",
  "totalResults": 1,
  "errorMessage": ""
}
```

### No Results Response
```json
{
  "success": true,
  "knowledgeContent": "No matching knowledge articles found for: \"Salesforce CRM\"",
  "matchedArticles": "",
  "totalResults": 0,
  "errorMessage": ""
}
```

### Error Response
```json
{
  "success": false,
  "knowledgeContent": "",
  "matchedArticles": "",
  "totalResults": 0,
  "errorMessage": "Search query is required"
}
```

## Error Handling

### Input Validation
- **Empty search query** returns error with message "Search query is required"
- **Invalid searchType** defaults to 'all'
- **Invalid maxResults** defaults to 5

### Query Processing
- **No matches** returns success=true with "No matching articles" message
- **Query errors** return success=false with error details
- **Exception handling** catches all errors and returns structured error response

## Agent Configuration Tips

### 1. Default Configuration
- Use `searchType = "all"` for comprehensive searches
- Use `maxResults = 5` for reasonable response sizes
- Always provide a `searchQuery`

### 2. Search Strategies
- **Broad searches**: Use general terms like "AE Academy" or "SME"
- **Specific searches**: Use exact titles like "SME Finder Documentation"
- **Content searches**: Use `searchType = "content"` for deep content searching

### 3. Response Handling
- Always check `success` field first
- Use `totalResults` to determine if content was found
- Display `knowledgeContent` to users
- Log `errorMessage` for debugging

## Management Functions

### Adding New Articles
```apex
// Add by ID
ANAgentKnowledgeRetriever.addAllowedKnowledgeId('ka0D7000000XXXXX');

// Add by title
ANAgentKnowledgeRetriever.addAllowedArticleTitle('New Article Title');
```

### Viewing Allowed Articles
```apex
Set<String> allowedIds = ANAgentKnowledgeRetriever.getAllowedKnowledgeIds();
Set<String> allowedTitles = ANAgentKnowledgeRetriever.getAllowedArticleTitles();
```

## Technical Notes

### SOQL Limitations
- Rich text fields (`Answer__c`, `Question__c`) cannot be filtered in SOQL
- Content search uses post-query Apex filtering
- Title search is more efficient than content search

### Performance Considerations
- Queries are limited to allowed articles only
- Default limit of 5 results prevents large responses
- HTML stripping adds minimal processing overhead

### Data Format
- All content is returned as plain text (HTML stripped)
- Articles are formatted with clear separators
- Metadata (ID, URL) is included for reference 

## Overview
The `ANAgentKnowledgeRetriever` class provides secure, targeted knowledge retrieval from explicitly identified Salesforce Knowledge articles. This ensures your agent only has access to specific, approved knowledge content.

## Invocable Method Details

### Method Information
- **Method Name**: `retrieveKnowledge`
- **Label**: "Retrieve Targeted Knowledge"
- **Description**: "Retrieve knowledge from explicitly identified articles only"

### Input Parameters

#### 1. searchQuery (REQUIRED)
- **Type**: String
- **Description**: The search term to find in knowledge articles
- **Examples**: 
  - "AE Academy"
  - "SME Finder"
  - "Data Cloud"
  - "Agentforce Badge"
- **Note**: Only searches within explicitly allowed articles

#### 2. searchType (OPTIONAL)
- **Type**: String
- **Default**: 'all'
- **Valid Values**:
  - `'title'` - Search only in article titles
  - `'content'` - Search in titles, questions, and answers (with post-query filtering)
  - `'all'` - Search across all fields (same as 'content' due to SOQL limitations)
- **Note**: Rich text fields cannot be filtered in SOQL, so content search uses Apex filtering

#### 3. maxResults (OPTIONAL)
- **Type**: Integer
- **Default**: 5
- **Description**: Maximum number of articles to return
- **Range**: 1-50 (recommended)
- **Note**: Actual results may be fewer if fewer matching articles exist

### Output Parameters

#### 1. success (Boolean)
- `true`: Request processed successfully (even if no results found)
- `false`: Error occurred during processing

#### 2. knowledgeContent (String)
- Contains the formatted knowledge article content
- **Format**: Each article starts with "=== [Title] ===" followed by content
- **Includes**: Question, Answer, Description, Article ID, URL Name
- **HTML tags are stripped** for clean text output
- **If no results**: Contains "No matching knowledge articles found for: [query]"

#### 3. matchedArticles (String)
- Comma-separated list of article titles that matched the search
- **Example**: "AE Academy Table Documentation, SME Finder Documentation"
- Empty string if no matches found

#### 4. totalResults (Integer)
- Number of articles returned
- 0 if no matches found
- May be less than maxResults if fewer articles match

#### 5. errorMessage (String)
- Contains error details if success = false
- **Common errors**:
  - "Search query is required" - Empty or null search query
  - "Query error: [details]" - SOQL or processing errors
- Empty string if success = true

## Security Features

### Access Control
- **Only articles explicitly listed** in `ALLOWED_KNOWLEDGE_IDS` or `ALLOWED_ARTICLE_TITLES` are accessible
- **Articles must be published** (`PublishStatus = 'Online'`) and latest version (`IsLatestVersion = true`)
- **All queries are filtered** by allowed articles before any search is performed

### Current Allowed Articles
1. **AE Academy Table Documentation** (ID: ka0D7000000TQUHIA4)
   - Contains AE Academy table schema, examples, and usage
2. **Subject-Matter-Expert (SME) Finder Topic** (ID: ka0D7000000TQUCIA4)
   - Contains SME Finder topic documentation
3. **SME Finder Documentation** (ID: ka0D7000000TQU7IAO)
   - Contains complete SME Finder table documentation
4. **Agentforce Badge Completion** (ID: ka0D7000000TQTsIAO)
   - Contains Agentforce badge program documentation

## Usage Examples

### Example 1: Search for AE Academy Content
```json
{
  "searchQuery": "AE Academy",
  "searchType": "all",
  "maxResults": 3
}
```

### Example 2: Search by Title Only
```json
{
  "searchQuery": "SME Finder",
  "searchType": "title",
  "maxResults": 2
}
```

### Example 3: Limit Results
```json
{
  "searchQuery": "Data Cloud",
  "maxResults": 1
}
```

## Expected Responses

### Successful Response
```json
{
  "success": true,
  "knowledgeContent": "=== AE Academy Table Documentation ===\nAnswer: Table Documentation: AE_ACADEMY\n1. Metadata\nFull Table Name: SSE_DM_GDSO_PRD.SELLER_INSIGHTS.AE_ACADEMY\n...",
  "matchedArticles": "AE Academy Table Documentation",
  "totalResults": 1,
  "errorMessage": ""
}
```

### No Results Response
```json
{
  "success": true,
  "knowledgeContent": "No matching knowledge articles found for: \"Salesforce CRM\"",
  "matchedArticles": "",
  "totalResults": 0,
  "errorMessage": ""
}
```

### Error Response
```json
{
  "success": false,
  "knowledgeContent": "",
  "matchedArticles": "",
  "totalResults": 0,
  "errorMessage": "Search query is required"
}
```

## Error Handling

### Input Validation
- **Empty search query** returns error with message "Search query is required"
- **Invalid searchType** defaults to 'all'
- **Invalid maxResults** defaults to 5

### Query Processing
- **No matches** returns success=true with "No matching articles" message
- **Query errors** return success=false with error details
- **Exception handling** catches all errors and returns structured error response

## Agent Configuration Tips

### 1. Default Configuration
- Use `searchType = "all"` for comprehensive searches
- Use `maxResults = 5` for reasonable response sizes
- Always provide a `searchQuery`

### 2. Search Strategies
- **Broad searches**: Use general terms like "AE Academy" or "SME"
- **Specific searches**: Use exact titles like "SME Finder Documentation"
- **Content searches**: Use `searchType = "content"` for deep content searching

### 3. Response Handling
- Always check `success` field first
- Use `totalResults` to determine if content was found
- Display `knowledgeContent` to users
- Log `errorMessage` for debugging

## Management Functions

### Adding New Articles
```apex
// Add by ID
ANAgentKnowledgeRetriever.addAllowedKnowledgeId('ka0D7000000XXXXX');

// Add by title
ANAgentKnowledgeRetriever.addAllowedArticleTitle('New Article Title');
```

### Viewing Allowed Articles
```apex
Set<String> allowedIds = ANAgentKnowledgeRetriever.getAllowedKnowledgeIds();
Set<String> allowedTitles = ANAgentKnowledgeRetriever.getAllowedArticleTitles();
```

## Technical Notes

### SOQL Limitations
- Rich text fields (`Answer__c`, `Question__c`) cannot be filtered in SOQL
- Content search uses post-query Apex filtering
- Title search is more efficient than content search

### Performance Considerations
- Queries are limited to allowed articles only
- Default limit of 5 results prevents large responses
- HTML stripping adds minimal processing overhead

### Data Format
- All content is returned as plain text (HTML stripped)
- Articles are formatted with clear separators
- Metadata (ID, URL) is included for reference 