# Agent Knowledge Setup Guide

## Quick Setup for Agentforce

### 1. Find the Action
- Look for: **"Search Knowledge Articles"** (or "Retrieve Targeted Knowledge")
- Description: "Search for information in approved knowledge articles. Only requires a user query - other fields have smart defaults."

### 2. Configure Input Fields

#### Required Field:
- **Field Name**: `searchQuery`
- **Label**: "User Query"
- **Description**: "The search term or question from the user"
- **Instructions**: "Enter the user's search query or question here"
- **Data Type**: Text
- **Required**: ✅ Yes
- **Collect from user**: ✅ Yes (this is what users will input)

#### Optional Fields (with smart defaults):

**searchType:**
- **Label**: "Search Type"
- **Description**: "Type of search: title (titles only), content (full content), all (comprehensive)"
- **Instructions**: "Leave empty for comprehensive search (recommended)"
- **Data Type**: Text
- **Required**: ❌ No
- **Collect from user**: ❌ No (use default)

**maxResults:**
- **Label**: "Max Results"
- **Description**: "Maximum number of articles to return (1-10, default: 3)"
- **Instructions**: "Leave empty for default of 3 results"
- **Data Type**: Number
- **Required**: ❌ No
- **Collect from user**: ❌ No (use default)

### 3. Configure Output Fields

**knowledgeContent:**
- **Label**: "Knowledge Content"
- **Description**: "Formatted knowledge article content with questions, answers, and metadata"
- **Instructions**: "Display this content to the user"
- **Show in conversation**: ✅ Yes
- **Output Rendering**: Text

**matchedArticles:**
- **Label**: "Matched Articles"
- **Description**: "Comma-separated list of article titles that matched the search"
- **Instructions**: "Show which articles were found"
- **Show in conversation**: ✅ Yes
- **Output Rendering**: Text

**totalResults:**
- **Label**: "Total Results"
- **Description**: "Number of articles found and returned"
- **Instructions**: "Display count of results found"
- **Show in conversation**: ✅ Yes
- **Output Rendering**: Text

**success:**
- **Label**: "Success"
- **Description**: "Whether the knowledge search was successful"
- **Instructions**: "Use to check if search worked"
- **Show in conversation**: ❌ No

**errorMessage:**
- **Label**: "Error Message"
- **Description**: "Error details if the search failed"
- **Instructions**: "Display if search failed"
- **Show in conversation**: ✅ Yes (only when success = false)

### 4. User Experience

#### What Users See:
- **Input**: Simple text field asking for their question
- **Output**: Formatted knowledge content with article titles and metadata
- **No Technical Details**: Users don't see searchType, maxResults, or other technical fields

#### Example User Interaction:
```
User: "Tell me about AE Academy"
Agent: [Shows formatted AE Academy documentation with tables, examples, etc.]
```

### 5. Available Knowledge Articles

Users can search for information about:
1. **AE Academy** - Table documentation, schema, examples
2. **SME Finder** - Subject Matter Expert identification system
3. **Agentforce Badge** - Badge completion tracking
4. **Data Cloud** - Related documentation

### 6. Smart Defaults

- **searchType**: Defaults to "all" (comprehensive search)
- **maxResults**: Defaults to 3 (good balance of content vs. length)
- **Error Handling**: Graceful handling of no results or errors

### 7. Security Features

- ✅ Only approved articles are searchable
- ✅ Published articles only
- ✅ Latest versions only
- ✅ No access to unauthorized content 

## Quick Setup for Agentforce

### 1. Find the Action
- Look for: **"Search Knowledge Articles"** (or "Retrieve Targeted Knowledge")
- Description: "Search for information in approved knowledge articles. Only requires a user query - other fields have smart defaults."

### 2. Configure Input Fields

#### Required Field:
- **Field Name**: `searchQuery`
- **Label**: "User Query"
- **Description**: "The search term or question from the user"
- **Instructions**: "Enter the user's search query or question here"
- **Data Type**: Text
- **Required**: ✅ Yes
- **Collect from user**: ✅ Yes (this is what users will input)

#### Optional Fields (with smart defaults):

**searchType:**
- **Label**: "Search Type"
- **Description**: "Type of search: title (titles only), content (full content), all (comprehensive)"
- **Instructions**: "Leave empty for comprehensive search (recommended)"
- **Data Type**: Text
- **Required**: ❌ No
- **Collect from user**: ❌ No (use default)

**maxResults:**
- **Label**: "Max Results"
- **Description**: "Maximum number of articles to return (1-10, default: 3)"
- **Instructions**: "Leave empty for default of 3 results"
- **Data Type**: Number
- **Required**: ❌ No
- **Collect from user**: ❌ No (use default)

### 3. Configure Output Fields

**knowledgeContent:**
- **Label**: "Knowledge Content"
- **Description**: "Formatted knowledge article content with questions, answers, and metadata"
- **Instructions**: "Display this content to the user"
- **Show in conversation**: ✅ Yes
- **Output Rendering**: Text

**matchedArticles:**
- **Label**: "Matched Articles"
- **Description**: "Comma-separated list of article titles that matched the search"
- **Instructions**: "Show which articles were found"
- **Show in conversation**: ✅ Yes
- **Output Rendering**: Text

**totalResults:**
- **Label**: "Total Results"
- **Description**: "Number of articles found and returned"
- **Instructions**: "Display count of results found"
- **Show in conversation**: ✅ Yes
- **Output Rendering**: Text

**success:**
- **Label**: "Success"
- **Description**: "Whether the knowledge search was successful"
- **Instructions**: "Use to check if search worked"
- **Show in conversation**: ❌ No

**errorMessage:**
- **Label**: "Error Message"
- **Description**: "Error details if the search failed"
- **Instructions**: "Display if search failed"
- **Show in conversation**: ✅ Yes (only when success = false)

### 4. User Experience

#### What Users See:
- **Input**: Simple text field asking for their question
- **Output**: Formatted knowledge content with article titles and metadata
- **No Technical Details**: Users don't see searchType, maxResults, or other technical fields

#### Example User Interaction:
```
User: "Tell me about AE Academy"
Agent: [Shows formatted AE Academy documentation with tables, examples, etc.]
```

### 5. Available Knowledge Articles

Users can search for information about:
1. **AE Academy** - Table documentation, schema, examples
2. **SME Finder** - Subject Matter Expert identification system
3. **Agentforce Badge** - Badge completion tracking
4. **Data Cloud** - Related documentation

### 6. Smart Defaults

- **searchType**: Defaults to "all" (comprehensive search)
- **maxResults**: Defaults to 3 (good balance of content vs. length)
- **Error Handling**: Graceful handling of no results or errors

### 7. Security Features

- ✅ Only approved articles are searchable
- ✅ Published articles only
- ✅ Latest versions only
- ✅ No access to unauthorized content 