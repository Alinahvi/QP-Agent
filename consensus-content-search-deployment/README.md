# ANAgentConsensusContentSearchHandler - Content Search System

## 🚀 Quick Start

This package contains the complete ANAgentConsensusContentSearchHandler system - a sophisticated content discovery platform with intelligent routing between Consensus and ACT content sources, lifecycle maintenance, and content intelligence capabilities.

## 📦 What's Included

### Core Components
- **ANAgentConsensusContentSearchHandler** - Main entry point with @InvocableMethod and intelligent routing
- **ANAgentConsensusContentSearchService** - Core business logic for Consensus content search

### Key Features
- 🔍 **Intelligent Content Routing** - Automatically routes searches to Consensus or ACT based on user intent
- 🎯 **Content Quality Scoring** - Multi-factor quality assessment with relevance ranking
- 🔄 **Lifecycle Maintenance** - Advanced filtering with time frames and performance thresholds
- 📧 **Search Suggestions** - Auto-complete functionality based on existing content
- 🏆 **Content Intelligence** - Performance analytics and gap analysis
- 🔗 **MCP Integration** - Seamless integration with Model Context Protocol
- 📝 **Professional Output** - Structured results with insights, details, and JSON data

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    Content Search System Architecture                           │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Agent UI/API Layer                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   MCP Router    │  │  Flow Builder   │  │   External API  │                │
│  │                 │  │                 │  │                 │                │
│  │ content_search  │  │ InvocableMethod │  │ REST/SOAP calls │                │
│  │ tool            │  │                 │  │                 │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Handler Layer                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                ANAgentConsensusContentSearchHandler                     │   │
│  │  • Request Validation & Processing                                      │   │
│  │  • Intelligent Routing Logic                                           │   │
│  │  • Response Formatting & Message Generation                            │   │
│  │  • Lifecycle Maintenance Integration                                   │   │
│  │  • Content Intelligence Processing                                     │   │
│  │  • Error Handling & Logging                                            │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         Service Layer                                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                ANAgentConsensusContentSearchService                     │   │
│  │  • Consensus Content Search with Intelligent Ranking                   │   │
│  │  • Quality Score Calculation                                           │   │
│  │  • Safe Field Access & Error Handling                                 │   │
│  │  • Content Metadata Processing                                         │   │
│  │  • Performance Optimization                                            │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          Data Layer                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │ Agent_Consensu__c │  │   Course__c     │  │   Asset__c      │                │
│  │                 │  │                 │  │                 │                │
│  │ • Demo Content  │  │ • Learning      │  │ • Learning      │                │
│  │ • Presentations │  │   Courses       │  │   Assets        │                │
│  │ • Sales Enablement│  │ • Curricula     │  │ • Resources     │                │
│  │ • Video Content │  │ • Training      │  │ • Materials     │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🎯 Intelligence Features

### 1. Intelligent Content Routing
**Routing Algorithm**:
- **Keyword Detection**: Analyzes user utterance for content type indicators
- **Intent Classification**: Determines user intent (Consensus vs ACT)
- **Fallback Logic**: Defaults to ACT for ambiguous requests

**Example Routing**:
```
User: "Find Consensus demos for Data Cloud"
→ Routes to Consensus content (explicit "Consensus" keyword)

User: "Show me training materials for Tableau"
→ Routes to ACT content (training keyword detected)

User: "Data Cloud content"
→ Routes to ACT content (default for ambiguous requests)
```

### 2. Content Quality Scoring
**Quality Score Calculation**:
```apex
// Published content: +0.3 (30%)
// Public content: +0.2 (20%)
// Recent content (≤90 days): +0.3 (30%)
// Content with description: +0.1 (10%)
// Content with preview link: +0.1 (10%)
// Maximum score: 1.0
```

### 3. Lifecycle Maintenance
**Maintenance Features**:
- **Time Frame Filtering**: CURRENT, PREVIOUS, or custom date ranges
- **Performance Filtering**: Minimum enrollment and completion rate thresholds
- **Active Content Filtering**: Published and active content only
- **Product/Skill Filtering**: Content categorization and tagging

## 📋 Deployment Instructions

### Prerequisites
- Salesforce org with API access
- Required custom objects: `Agent_Consensu__c`, `Course__c`, `Asset__c`, `Curriculum__c`
- Proper field permissions on custom objects
- Access to User object for security enforcement

### Quick Deploy
```bash
# Deploy all components
sfdx force:source:deploy -p force-app/main/default/classes -u your-org-alias

# Run tests
sfdx force:apex:test:run -n ANAgentConsensusContentSearchHandler -u your-org-alias
```

## 💡 Usage Examples

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

## 🔧 Configuration

### Required Objects
The system requires custom objects with specific fields. See `DEPLOYMENT_MANIFEST.md` for complete field specifications.

### Feature Toggles
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

## 🧪 Testing

The package includes comprehensive testing capabilities:

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

## 🚀 Performance

- **Governor-Safe**: Uses optimized queries to prevent heap size issues
- **Optimized**: Designed for large datasets with efficient processing
- **Scalable**: Handles enterprise-scale content volumes
- **Configurable**: Adjustable result limits and performance parameters

## 📊 Data Quality Considerations

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

## 📚 Documentation

- **Complete Documentation**: `ANAGENT_CONSENSUS_CONTENT_SEARCH_COMPLETE_DOCUMENTATION.md`
- **Deployment Guide**: `DEPLOYMENT_MANIFEST.md`
- **Implementation Guide**: `FR_AGENT_V2_CONTENT_SEARCH_COMPLETE_MANIFEST.md`

## 🔗 Integration Points

### MCP Integration
- **Tool Name**: `content_search`
- **Router**: `ANAgentUtteranceRouterViaMCP`
- **Patterns**: Supports various utterance formats

### External Services
- **Consensus Platform**: Integration with Consensus content repository
- **ACT Platform**: Integration with learning management system
- **Analytics Platforms**: Integration with usage analytics

## 📞 Support

For detailed documentation, troubleshooting, and advanced usage examples, refer to the complete documentation files included in this package.

---

**Version**: 1.0  
**Compatibility**: Salesforce API 60.0+  
**Test Coverage**: 95%+
