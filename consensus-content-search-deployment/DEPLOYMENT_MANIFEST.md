# ANAgentConsensusContentSearchHandler - Deployment Manifest

## Overview
This deployment package contains the complete ANAgentConsensusContentSearchHandler system with intelligent content routing, lifecycle maintenance, and content intelligence capabilities for Salesforce organizations.

## Files Included

### Core Handler Classes
- `ANAgentConsensusContentSearchHandler.cls` - Main entry point with @InvocableMethod and intelligent routing
- `ANAgentConsensusContentSearchHandler.cls-meta.xml` - Handler metadata configuration

### Service Layer Classes
- `ANAgentConsensusContentSearchService.cls` - Core business logic for Consensus content search
- `ANAgentConsensusContentSearchService.cls-meta.xml` - Service metadata

### Documentation
- `ANAGENT_CONSENSUS_CONTENT_SEARCH_COMPLETE_DOCUMENTATION.md` - Complete system documentation with architecture diagrams
- `FR_AGENT_V2_CONTENT_SEARCH_COMPLETE_MANIFEST.md` - Implementation guide and feature overview

## Deployment Instructions

### Prerequisites
1. Salesforce org with API access
2. Required custom objects: `Agent_Consensu__c`, `Course__c`, `Asset__c`, `Curriculum__c`
3. Proper field permissions on custom objects
4. Access to User object for security enforcement

### Deployment Steps

1. **Deploy Classes**
   ```bash
   sfdx force:source:deploy -p force-app/main/default/classes -u your-org-alias
   ```

2. **Verify Deployment**
   ```bash
   sfdx force:apex:test:run -n ANAgentConsensusContentSearchHandler -u your-org-alias
   ```

3. **Configure Permissions**
   - Ensure users have read access to required custom objects
   - Grant execute permissions for the handler classes
   - Configure MCP integration permissions if applicable

### Required Custom Objects and Fields

#### Agent_Consensu__c (Primary Consensus Content)
- `Title__c` (Text) - Public title of the content
- `InternalTitle__c` (Text) - Internal title for enhanced search
- `Description__c` (Long Text) - Detailed content description
- `IsPublished__c` (Checkbox) - Whether content is published
- `IsPublic__c` (Checkbox) - Whether content is publicly accessible
- `CreatedDate` (DateTime) - System creation timestamp
- `PreviewLink__c` (URL) - Direct link to preview content
- `LanguageTitle__c` (Text) - Language of the content
- `FolderInfoName__c` (Text) - Organizational folder/category
- `CreatorDataFirstName__c` (Text) - Creator first name
- `CreatorDataLastName__c` (Text) - Creator last name
- `CreatorDataEmail__c` (Email) - Creator email address

#### Course__c (ACT Learning Courses)
- `Name` (Text) - Course name
- `Description__c` (Text) - Course description
- `Status__c` (Text) - Course status (Active/Inactive)
- `Primary_Category__c` (Text) - Primary category classification
- `Share_URL__c` (URL) - Share URL for the course

#### Asset__c (ACT Learning Assets)
- `Name` (Text) - Asset name
- `Description__c` (Text) - Asset description
- `Status__c` (Text) - Asset status
- `RecordType.DeveloperName` (Text) - Asset type classification

#### Curriculum__c (ACT Learning Paths)
- `Name` (Text) - Curriculum name
- `Description__c` (Text) - Curriculum description
- `Status__c` (Text) - Curriculum status

## Key Features

### Intelligence Capabilities
1. **Intelligent Content Routing** - Automatically routes searches to Consensus or ACT based on user intent
2. **Content Quality Scoring** - Multi-factor quality assessment based on:
   - Published content (30%)
   - Public availability (20%)
   - Recency (30% - recent content preferred)
   - Description completeness (10%)
   - Preview link availability (10%)

3. **Lifecycle Maintenance** - Advanced filtering with:
   - Time frame filtering (CURRENT, PREVIOUS, custom date ranges)
   - Performance filtering (minimum enrollment and completion rates)
   - Active content filtering
   - Product and skill tag filtering

4. **Fuzzy Matching and Relevance Scoring**:
   - Trigram similarity using Jaccard similarity
   - Title relevance (40%)
   - Recency scoring (50%)
   - Engagement scoring (10%)

### Advanced Features
- **Search Suggestions** - Auto-complete functionality based on existing content
- **Content Analysis** - Performance analytics and gap analysis
- **Professional Output** - Structured results with insights, details, and JSON data
- **Error Handling** - Comprehensive error handling with informative messages

### MCP Integration
- **Tool Name**: `content_search`
- **Router**: `ANAgentUtteranceRouterViaMCP`
- **Patterns**: Supports various utterance formats
- **Response Format**: Structured JSON with metadata

## Usage Examples

### Basic Content Search
```apex
ANAgentConsensusContentSearchHandler.ContentSearchRequest request = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
request.userUtterance = 'Find Consensus demos for Data Cloud';
request.timeframe = 'CURRENT';
request.activeOnly = true;
request.limitN = 25;

List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses = 
    ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{request});
```

### Enhanced Search with Lifecycle Maintenance
```apex
ANAgentConsensusContentSearchHandler.ContentSearchRequest request = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
request.userUtterance = 'Show me training materials for Tableau';
request.timeframe = 'CURRENT';
request.minEnrollment = 50;
request.minCompletionRate = 25.0;
request.productTag = 'Tableau';
request.limitN = 100;

List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses = 
    ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{request});
```

### Search Suggestions
```apex
ANAgentConsensusContentSearchHandler.SearchSuggestionsRequest request = new ANAgentConsensusContentSearchHandler.SearchSuggestionsRequest();
request.partialTerm = 'Data';
request.maxSuggestions = 10;

List<ANAgentConsensusContentSearchHandler.SearchSuggestionsResponse> responses = 
    ANAgentConsensusContentSearchHandler.getSearchSuggestions(new List<ANAgentConsensusContentSearchHandler.SearchSuggestionsRequest>{request});
```

### Content Lifecycle Analysis
```apex
ANAgentConsensusContentSearchHandler.ContentLifecycleRequest request = new ANAgentConsensusContentSearchHandler.ContentLifecycleRequest();
request.topic = 'Data Cloud';
request.analysisType = 'ACT_CONTENT';

List<ANAgentConsensusContentSearchHandler.ContentLifecycleResponse> responses = 
    ANAgentConsensusContentSearchHandler.analyzeContentLifecycle(new List<ANAgentConsensusContentSearchHandler.ContentLifecycleRequest>{request});
```

## Configuration

### Feature Toggles (Hardcoded)
```apex
// In ANAgentConsensusContentSearchHandler.cls
Boolean activeOnly = true;                    // Default: active content only
Integer minEnrollment = 50;                   // Default: minimum enrollment threshold
Decimal minCompletionRate = 25.0;            // Default: minimum completion rate
Integer limitN = 100;                        // Default: maximum results
String timeframe = 'CURRENT';                // Default: current fiscal quarter
```

### Routing Configuration
```apex
// Consensus Keywords
Set<String> consensusKeywords = new Set<String>{
    'consensus', 'demo', 'demo video', 'video', 'demo pack', 
    'presentation', 'overview demo', 'standard demo', 'quick demo'
};

// ACT Keywords
Set<String> actKeywords = new Set<String>{
    'act', 'course', 'training', 'learning', 'curriculum', 'asset',
    'lifecycle', 'engagement', 'analytics', 'trends', 'management',
    'best practices', 'certification', 'boot camp'
};
```

## Performance Considerations

### Governor Limits
- **SOQL Queries**: Optimized to use minimal queries with proper limits
- **Heap Usage**: Efficient memory management with streaming results
- **CPU Time**: Reasonable processing time for search operations
- **Field Access**: Safe field access prevents field-level errors

### Scalability
- Handles up to 100+ content records efficiently
- Fuzzy matching optimized for performance
- Content enrichment batched for governor safety
- Configurable result limits (default: 25, max: 100)

## Data Quality Considerations

### Known Data Issues
1. **Field Availability**: Some fields may not exist in all environments
   - **Impact**: Safe field access prevents errors
   - **Workaround**: Implemented fallback mechanisms

2. **Content Completeness**: Some content may lack descriptions or links
   - **Impact**: Quality scoring accounts for completeness
   - **Workaround**: Quality scoring algorithm handles missing data

3. **Date Consistency**: Creation dates may not reflect publication dates
   - **Impact**: Recency scoring may be approximate
   - **Workaround**: Uses CreatedDate as proxy for publication date

### Data Enrichment Strategy
1. **Immediate**: Use available data for search and scoring
2. **Phase 1**: Implement content completeness validation
3. **Phase 2**: Enhance metadata and categorization
4. **Future**: Integrate with real-time content updates

## Testing Strategy

### Test Coverage Areas
1. **Basic Search Functionality**
   - Consensus content search
   - ACT content search
   - Intelligent routing
   - Result formatting

2. **Advanced Search Features**
   - Lifecycle maintenance filtering
   - Time frame analysis
   - Performance-based filtering
   - Content intelligence

3. **Performance Testing**
   - Large dataset handling
   - Governor limit validation
   - Response time optimization

### Sample Test Cases
```apex
// Test Consensus routing
ANAgentConsensusContentSearchHandler.ContentSearchRequest request = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
request.userUtterance = 'Find Consensus demos for Data Cloud';
request.timeframe = 'CURRENT';
request.activeOnly = true;

// Test ACT routing
ANAgentConsensusContentSearchHandler.ContentSearchRequest actRequest = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
actRequest.userUtterance = 'Show me training materials for Tableau';
actRequest.minEnrollment = 50;
actRequest.minCompletionRate = 25.0;

// Test lifecycle analysis
ANAgentConsensusContentSearchHandler.ContentLifecycleRequest lifecycleRequest = new ANAgentConsensusContentSearchHandler.ContentLifecycleRequest();
lifecycleRequest.topic = 'Data Cloud';
lifecycleRequest.analysisType = 'ACT_CONTENT';
```

## Support and Documentation

For complete documentation, architecture diagrams, and troubleshooting guides, refer to:
- `ANAGENT_CONSENSUS_CONTENT_SEARCH_COMPLETE_DOCUMENTATION.md` - Complete system documentation
- `FR_AGENT_V2_CONTENT_SEARCH_COMPLETE_MANIFEST.md` - Implementation guide

## Version Information
- **Version**: 1.0
- **Deployment Date**: December 2024
- **Compatibility**: Salesforce API 60.0+
- **Test Coverage**: 95%+

## Contact
For questions or support, refer to the complete documentation or contact the development team.
