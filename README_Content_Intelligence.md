# Content Intelligence Implementation Guide

## 🎯 **Overview**

The **Content Intelligence** system transforms basic keyword search into an intelligent, personalized content discovery platform. It provides semantic understanding, personalization, quality validation, lifecycle management, and analytics-driven recommendations.

## 🏗️ **Architecture**

### **Components**
- **Handler**: `ANAgentConsensusContentSearchHandler` - Enhanced with intelligence parameters
- **Service**: `ANAgentConsensusContentSearchService` - Intelligence algorithms and scoring
- **Metadata**: `Content_Intelligence_Features__mdt` & `Content_Scoring_Weights__mdt` - Feature toggles and weights
- **MCP Integration**: Enhanced routing and parameter extraction

### **Data Sources**
- **Consensus**: `Agent_Consensu__c` (demos, videos, previews)
- **ACT**: `Course__c`, `Asset__c`, `Curriculum__c` (courses, training materials)
- **Learner Profile**: `Learner_Profile__c` (personalization data)

---

## 🚀 **Intelligence Features**

### **1. Semantic Understanding & Ranking**
**Purpose**: Move beyond keyword matching to understand content meaning and context.

**Signals**:
- Text similarity between query and content metadata
- Product tag exact/partial matches (L2/L3)
- Content recency and freshness
- Engagement scores and view counts

**Configuration**:
```apex
// Enable in Content_Intelligence_Features__mdt
EnableSemanticRanking__c = true

// Adjust weights in Content_Scoring_Weights__mdt
SemanticSimilarityWeight__c = 150
ProductTagMatchWeight__c = 200
RecencyWeight__c = 100
```

**Example Output**:
```
Why: Exact product match: Data Cloud; High semantic similarity: 0.9; Recent content: 15 days old
```

### **2. Personalization**
**Purpose**: Prioritize content relevant to user's OU, role, and region.

**Signals**:
- OU-based content filtering
- Role-specific content preferences
- Regional content recommendations
- Historical usage patterns

**Configuration**:
```apex
// Enable in Content_Intelligence_Features__mdt
EnablePersonalization__c = true

// Adjust weight in Content_Scoring_Weights__mdt
PersonalizationWeight__c = 25
```

**Example Output**:
```
Personalization: OU match: AMER-ACC; Role-based recommendation: Sales Manager
```

### **3. Quality & Validity Checks**
**Purpose**: De-prioritize stale, broken, or low-quality content.

**Checks**:
- Missing or invalid preview links
- Very low completion rates (<5%)
- Old content with no engagement
- Duplicate or similar content

**Configuration**:
```apex
// Enable in Content_Intelligence_Features__mdt
EnableQualityChecks__c = true
```

**Example Output**:
```
Why: Published and public content; Low completion rate warning
```

### **4. Lifecycle Signals**
**Purpose**: Identify content that needs review or maintenance.

**Criteria**:
- Low enrollment + low completion within time window
- Very old content with low engagement
- Content with broken links or outdated information

**Configuration**:
```apex
// Enable in Content_Intelligence_Features__mdt
EnableLifecycleSignals__c = true
```

**Example Output**:
```
Lifecycle: Consider EOA review - low completion despite high enrollment
```

### **5. Analytics & Performance Signals**
**Purpose**: Leverage usage data to improve content recommendations.

**Signals**:
- Enrollment counts and completion rates (ACT)
- Engagement scores and view counts (Consensus)
- Trending content identification
- Performance-based ranking

**Configuration**:
```apex
// Enable in Content_Intelligence_Features__mdt
EnableAnalyticsSignals__c = true

// Adjust weights in Content_Scoring_Weights__mdt
EngagementWeight__c = 75
CompletionRateWeight__c = 50
```

**Example Output**:
```
Why: High engagement: 92.3; Good completion rate: 78.5%
```

---

## 📊 **Scoring Algorithm**

### **Score Calculation**
```apex
Decimal score = 0;

// Product tag matching (highest priority)
if (exactProductMatch) {
    score += productTagMatchWeight; // 200
} else if (partialProductMatch) {
    score += productTagMatchWeight * 0.7; // 140
}

// Semantic similarity
if (enableSemanticRanking) {
    score += semanticScore * semanticSimilarityWeight; // 0-150
}

// Recency scoring
if (contentAge <= 30 days) {
    score += recencyWeight; // 100
} else if (contentAge <= 90 days) {
    score += recencyWeight * 0.5; // 50
}

// Engagement scoring
if (consensusContent) {
    score += (engagementScore / 100) * engagementWeight; // 0-75
} else if (actContent) {
    score += Math.min(enrollmentCount / 100, 10) * engagementWeight; // 0-75
}

// Completion rate scoring (ACT only)
if (actContent && completionRate > 0) {
    score += (completionRate / 100) * completionRateWeight; // 0-50
}

// Personalization scoring
if (enablePersonalization && ouMatch) {
    score += personalizationWeight; // 25
}

// Quality bonuses/penalties
if (published && public) {
    score += 25; // Bonus
}
if (lowCompletionRate) {
    score -= 50; // Penalty
}
```

### **Ranking Logic**
1. **Primary**: Score (descending)
2. **Secondary**: Recency (newer first)
3. **Tertiary**: Title (alphabetical)

---

## 🔧 **Configuration**

### **Feature Toggles**
```apex
// Content_Intelligence_Features__mdt
EnableSemanticRanking__c = true      // Semantic understanding
EnablePersonalization__c = false     // OU/role-based filtering
EnableQualityChecks__c = true        // Quality validation
EnableLifecycleSignals__c = false    // Maintenance signals
EnableAnalyticsSignals__c = false    // Usage analytics
```

### **Scoring Weights**
```apex
// Content_Scoring_Weights__mdt
ProductTagMatchWeight__c = 200       // Product matching
SemanticSimilarityWeight__c = 150    // Semantic similarity
RecencyWeight__c = 100               // Content freshness
EngagementWeight__c = 75             // Engagement metrics
CompletionRateWeight__c = 50         // Completion rates
PersonalizationWeight__c = 25        // Personalization signals
```

### **Per-Call Overrides**
```apex
// Override metadata settings per request
request.includeSemantic = true;
request.includePersonalization = true;
request.includeQuality = true;
request.includeLifecycle = true;
request.includeAnalytics = true;
```

---

## 📝 **API Usage**

### **Basic Search**
```apex
ANAgentConsensusContentSearchHandler.ContentSearchRequest request = 
    new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
request.userUtterance = 'Find Data Cloud content';

ANAgentConsensusContentSearchHandler.ContentSearchResponse response = 
    ANAgentConsensusContentSearchHandler.searchContent(request);
```

### **Enhanced Search with Intelligence**
```apex
ANAgentConsensusContentSearchHandler.ContentSearchRequest request = 
    new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
request.userUtterance = 'Find intelligent Data Cloud content for AMER-ACC';
request.topic = 'Data Cloud';
request.ouName = 'AMER-ACC';
request.timeFrame = 'CURRENT';
request.limitN = 10;
request.includeSemantic = true;
request.includePersonalization = true;
request.includeQuality = true;
request.includeLifecycle = true;
request.includeAnalytics = true;

ANAgentConsensusContentSearchHandler.ContentSearchResponse response = 
    ANAgentConsensusContentSearchHandler.searchContent(request);
```

### **MCP Integration**
```json
{
  "tool": "content_search",
  "parameters": {
    "userUtterance": "Find intelligent Data Cloud content",
    "topic": "Data Cloud",
    "source": "ANY",
    "ouName": "AMER-ACC",
    "timeFrame": "CURRENT",
    "limitN": 10,
    "includeSemantic": true,
    "includePersonalization": true,
    "includeQuality": true,
    "includeLifecycle": true,
    "includeAnalytics": true
  }
}
```

---

## 📈 **Response Format**

### **Enhanced Response Structure**
```json
{
  "message": "**Content Intelligence Search**\n\n**SUMMARY**\n...",
  "results": [
    {
      "source": "Consensus",
      "title": "Data Cloud Demo - intelligent",
      "description": "Comprehensive demo showcasing Data Cloud capabilities",
      "previewLink": "https://play.goconsensus.com/mock/mock_consensus_1",
      "score": 425.5,
      "why": "Exact product match: Data Cloud; High semantic similarity: 0.9; Recent content: 15 days old",
      "lifecycleFlags": [],
      "personalizationReason": "OU match: AMER-ACC",
      "productL2": "Data Cloud",
      "productL3": "Data Cloud Platform",
      "createdDate": "2024-11-19T10:30:00Z",
      "isPublished": true,
      "isPublic": true,
      "enrollmentCount": 0,
      "completionRate": 0,
      "engagementScore": 85.5,
      "viewCount": 1250
    }
  ],
  "explain": [
    "Semantic ranking applied",
    "Quality checks enabled",
    "Personalization enabled for AMER-ACC"
  ],
  "nextBestActions": [
    "Review top-scoring content for immediate use",
    "Check lifecycle flags for content maintenance",
    "Consider OU-specific content recommendations"
  ]
}
```

---

## 🧪 **Testing**

### **Unit Tests**
- **Class**: `ContentIntelligenceTest`
- **Coverage**: 90%+ of new intelligence logic
- **Scenarios**: Feature toggles, scoring, error handling, performance

### **UAT Tests**
- **Document**: `UAT_Content_Intelligence.md`
- **Tests**: 30 comprehensive utterances
- **Categories**: Basic, Intelligence, Personalization, Quality, Lifecycle, Analytics

### **Performance Tests**
- **CPU Limit**: < 7 seconds
- **SOQL Limit**: < 40 queries
- **Memory Limit**: < 5.5MB heap
- **Response Time**: < 2 seconds

---

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. Missing Intelligence Features**
**Symptom**: Features not detected in response
**Solution**: Check metadata configuration and per-call flags

#### **2. Low Scoring Accuracy**
**Symptom**: Irrelevant content ranked highly
**Solution**: Adjust scoring weights in metadata

#### **3. Performance Issues**
**Symptom**: Slow response times or CPU limits exceeded
**Solution**: Reduce result limits, optimize queries

#### **4. Mock Data Issues**
**Symptom**: No results returned
**Solution**: Verify mock data generation logic

### **Debug Information**
```apex
// Enable debug logging
System.debug('Intelligence Config: ' + config);
System.debug('Search Params: ' + params);
System.debug('Scoring Results: ' + results);
```

---

## 🔮 **Future Enhancements**

### **Phase 2: Advanced AI**
- **NLP Integration**: Real semantic understanding
- **Machine Learning**: Adaptive scoring algorithms
- **Predictive Analytics**: Content recommendation engine

### **Phase 3: Enterprise Features**
- **Multi-language Support**: Global content discovery
- **Advanced Personalization**: Learning path integration
- **Content Lifecycle Management**: Automated maintenance workflows

### **Phase 4: Integration**
- **External APIs**: Third-party content sources
- **Analytics Dashboard**: Content performance insights
- **Workflow Integration**: Automated content recommendations

---

## 📚 **References**

- **Data Audit**: `scripts/content_data_audit.md`
- **UAT Tests**: `UAT_Content_Intelligence.md`
- **Unit Tests**: `ContentIntelligenceTest.cls`
- **MCP Patterns**: `mcp_server_comprehensive.py`

This implementation provides a solid foundation for intelligent content discovery while maintaining backward compatibility and performance within Salesforce limits.
