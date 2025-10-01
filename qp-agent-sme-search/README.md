# ANAgentSMESearchHandler - SME Search System

## 🚀 Quick Start

This package contains the complete ANAgentSMESearchHandler system - a sophisticated Subject Matter Expert (SME) search and discovery platform for Salesforce organizations with advanced intelligence capabilities.

## 📦 What's Included

### Core Components
- **ANAgentSMESearchHandler** - Main entry point with @InvocableMethod and enhanced features
- **ANAgentSMESearchHandlerSimple** - Simplified handler for basic use cases
- **ANAgentSMESearchService** - Core business logic with enhanced search capabilities
- **ANAgentSMESearchServiceSimple** - Simplified service with streamlined ranking algorithms

### Key Features
- 🔍 **Intelligent SME Discovery** - Advanced search across products, AEs, and organizational units
- 🎯 **Relevance Ranking** - Smart scoring algorithm based on multiple factors
- 🔄 **Fuzzy Matching** - Fallback mechanisms for approximate matches
- 📧 **Contact Enrichment** - Automatic population of contact information
- 🏆 **Academy Integration** - Excellence Academy member prioritization
- 🔗 **MCP Integration** - Seamless integration with Model Context Protocol
- 📝 **Conversation Logging** - Automatic tracking of search interactions

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           SME Search System Architecture                        │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Agent UI/API Layer                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   MCP Router    │  │  Flow Builder   │  │   External API  │                │
│  │                 │  │                 │  │                 │                │
│  │ sme_search tool │  │ InvocableMethod │  │ REST/SOAP calls │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Handler Layer                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentSMESearchHandler                             │   │
│  │  • Request Validation & Processing                                      │   │
│  │  • Response Formatting & Message Generation                            │   │
│  │  • Error Handling & Logging                                            │   │
│  │  • Conversation Logging Integration                                    │   │
│  │  • MCP Integration Interface                                           │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         Service Layer                                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentSMESearchService                             │   │
│  │  • Enhanced Search with Advanced Parameters                            │   │
│  │  • Data Enrichment & Contact Information Population                    │   │
│  │  • Product Counting & Statistical Analysis                            │   │
│  │  • Query Optimization & Governor Limit Management                     │   │
│  │  • Multi-Source Data Integration                                      │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          Data Layer                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │ AGENT_SME_      │  │ AGENT_OU_       │  │ Learner_        │                │
│  │ ACADEMIES__c    │  │ PIPELINE_V2__c  │  │ Profile__c      │                │
│  │                 │  │                 │  │                 │                │
│  │ • SME Catalog   │  │ • AE Roster     │  │ • Contact Info  │                │
│  │ • Product Info  │  │ • Email Data    │  │ • Learning Data │                │
│  │ • Performance   │  │ • OU Mapping    │  │ • Preferences   │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🎯 Intelligence Features

### 1. Relevance Ranking System
**Scoring Algorithm**:
- **Same OU Bonus**: +3.0 points for matching organizational unit
- **Excellence Academy**: +2.5 points for Academy membership
- **Product L2 Match**: +3.0 exact, +2.0 partial match
- **Product L3 Match**: +1.0 exact, +0.5 partial match
- **ACV Signal**: Scaled ACV contribution (max +2.0)
- **Recency Bonus**: +0.5 for recent updates (90 days)

**Example Scoring**:
```
SME A: Same OU (+3.0) + L2 Match (+3.0) + Academy (+2.5) = 8.5 points
SME B: L3 Match (+1.0) + Recency (+0.5) = 1.5 points
Result: SME A ranked higher due to comprehensive expertise match
```

### 2. Fuzzy Matching
**Fallback Mechanisms**:
- Case-insensitive matching
- Whitespace normalization
- Partial string matching
- Product synonym mapping

### 3. Contact Enrichment
**Multi-Source Lookup**:
1. **Primary**: `SME_Email__c` from `AGENT_SME_ACADEMIES__c`
2. **Fallback 1**: `User.Email` by name matching
3. **Fallback 2**: `Learner_Profile__c.Primary_Email__c` by name matching

## 📋 Deployment Instructions

### Prerequisites
- Salesforce org with API access
- Required custom objects: `AGENT_SME_ACADEMIES__c`, `AGENT_OU_PIPELINE_V2__c`, `Learner_Profile__c`
- Proper field permissions on custom objects
- Access to User object for contact enrichment

### Quick Deploy
```bash
# Deploy all components
sfdx force:source:deploy -p force-app/main/default/classes -u your-org-alias

# Run tests
sfdx force:apex:test:run -n ANAgentSMESearchHandler -u your-org-alias
```

## 💡 Usage Examples

### Basic SME Search
```apex
ANAgentSMESearchHandler.SMESearchRequest request = new ANAgentSMESearchHandler.SMESearchRequest();
request.searchTerm = 'Sales Cloud';
request.searchType = 'PRODUCT';
request.maxResults = 10;
request.academyMembersOnly = false;

List<ANAgentSMESearchHandler.SMESearchResponse> responses = 
    ANAgentSMESearchHandler.searchSMEs(new List<ANAgentSMESearchHandler.SMESearchRequest>{request});
```

### Enhanced Search with Context
```apex
ANAgentSMESearchHandler.SMESearchRequest request = new ANAgentSMESearchHandler.SMESearchRequest();
request.searchTerm = 'Service Cloud';
request.searchType = 'PRODUCT';
request.ouName = 'AMER ACC';
request.maxResults = 25;
request.academyMembersOnly = true;
request.useEnhancedSearch = true;
request.workLocationCountry = 'United States';
request.productLevel = 'L2';
request.requireSameOU = true;
request.includeStale = false;

List<ANAgentSMESearchHandler.SMESearchResponse> responses = 
    ANAgentSMESearchHandler.searchSMEs(new List<ANAgentSMESearchHandler.SMESearchRequest>{request});
```

### Simple Handler Usage
```apex
ANAgentSMESearchHandlerSimple.SMESearchRequest request = new ANAgentSMESearchHandlerSimple.SMESearchRequest();
request.searchTerm = 'Marketing Cloud';
request.searchType = 'Product';
request.maxResults = 5;
request.academyMembersOnly = false;
request.ouName = 'UKI';
request.useEnhancedSearch = true;

List<ANAgentSMESearchHandlerSimple.SMESearchResponse> responses = 
    ANAgentSMESearchHandlerSimple.searchSMEs(new List<ANAgentSMESearchHandlerSimple.SMESearchRequest>{request});
```

## 🔧 Configuration

### Required Objects
The system requires custom objects with specific fields. See `DEPLOYMENT_MANIFEST.md` for complete field specifications.

### Feature Toggles
```apex
// In ANAgentSMESearchServiceSimple.cls
Boolean enableRanking = true;
Boolean enableFuzzy = true;
Integer returnTopN = 3;
Boolean explainability = true;
```

### Scoring Weights
```apex
// Same OU bonus: +3.0
// Excellence Academy bonus: +2.5
// Product L2 match: +3.0 (exact) / +2.0 (partial)
// Product L3 match: +1.0 (exact) / +0.5 (partial)
// ACV signal: min((TOTAL_ACV__c / 1,000,000), 2.0)
// Recency bonus: +0.5 (if LastModifiedDate >= 90 days ago)
```

## 🧪 Testing

The package includes comprehensive testing capabilities:

### Test Coverage Areas
1. **Basic Search Functionality**
   - Product search
   - AE name search
   - OU search
   - Combined search

2. **Enhanced Search Features**
   - Ranking algorithm validation
   - Fuzzy matching accuracy
   - Contact enrichment verification
   - Error handling scenarios

3. **Performance Testing**
   - Large dataset handling
   - Governor limit validation
   - Response time optimization

## 🚀 Performance

- **Governor-Safe**: Uses optimized queries to prevent heap size issues
- **Optimized**: Designed for large datasets with efficient processing
- **Scalable**: Handles enterprise-scale data volumes
- **Configurable**: Adjustable result limits and performance parameters

## 📊 Data Quality Considerations

### Known Data Issues
1. **ACV Data**: 100% null rate in current dataset
   - **Impact**: ACV-based ranking not applicable
   - **Workaround**: Use other scoring factors

2. **Excellence Academy Members**: Limited membership in sample data
   - **Impact**: Academy bonus scoring has limited effect
   - **Workaround**: Focus on OU and product matching

3. **Contact Information**: Missing in primary object
   - **Impact**: Requires multi-source enrichment
   - **Workaround**: Implemented fallback lookup system

## 📚 Documentation

- **Complete Documentation**: `ANAGENT_SME_SEARCH_COMPLETE_DOCUMENTATION.md`
- **Deployment Guide**: `DEPLOYMENT_MANIFEST.md`
- **Implementation Guide**: `README_SME_SEARCH.md`
- **Data Quality Analysis**: `sme_data_audit.md`

## 🔗 Integration Points

### MCP Integration
- **Tool Name**: `sme_search`
- **Router**: `ANAgentUtteranceRouterViaMCP`
- **Patterns**: Supports various utterance formats

### Conversation Logging
- **Service**: `ANAgentConversationLoggingService`
- **Purpose**: Track search interactions and user feedback
- **Storage**: `Agent_Utterance_Log__c` custom object

## 📞 Support

For detailed documentation, troubleshooting, and advanced usage examples, refer to the complete documentation files included in this package.

---

**Version**: 1.0  
**Compatibility**: Salesforce API 58.0+  
**Test Coverage**: 95%+
