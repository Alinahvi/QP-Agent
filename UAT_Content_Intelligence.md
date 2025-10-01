# UAT Content Intelligence Test Pack

## Test Overview
**Purpose**: Validate Content Intelligence features end-to-end  
**Total Tests**: 30 utterances  
**Categories**: Basic, Intelligence-Enhanced, Personalization, Quality, Lifecycle, Analytics  
**Expected Success Rate**: 90%+  

---

## 🧪 **Test Categories**

### **1. Basic Content Search (5 tests)**
| # | Utterance | Expected Tool | Expected Features | Expected Result |
|---|-----------|---------------|-------------------|-----------------|
| 1 | "Find Data Cloud content" | content_search | Basic search | Data Cloud results with basic scoring |
| 2 | "Show me Sales Cloud courses" | content_search | Basic search | Sales Cloud ACT results |
| 3 | "Search for Marketing Cloud demos" | content_search | Basic search | Marketing Cloud Consensus results |
| 4 | "Get Service Cloud documentation" | content_search | Basic search | Service Cloud content with links |
| 5 | "Find content about Tableau" | content_search | Basic search | Tableau-related content |

### **2. Intelligence-Enhanced Search (5 tests)**
| # | Utterance | Expected Tool | Expected Features | Expected Result |
|---|-----------|---------------|-------------------|-----------------|
| 6 | "Find intelligent Data Cloud content" | content_search | Semantic + Quality | Smart ranking with explainability |
| 7 | "Show me smart Sales Cloud content" | content_search | Semantic + Analytics | AI-powered recommendations |
| 8 | "Get contextual Marketing Cloud content" | content_search | Semantic + Personalization | Context-aware results |
| 9 | "Find best performing Service Cloud content" | content_search | Analytics + Quality | Performance-based ranking |
| 10 | "Search for most effective Tableau content" | content_search | Analytics + Semantic | Effectiveness scoring |

### **3. Personalization Features (5 tests)**
| # | Utterance | Expected Tool | Expected Features | Expected Result |
|---|-----------|---------------|-------------------|-----------------|
| 11 | "Find personalized Data Cloud content for AMER-ACC" | content_search | Personalization + OU | OU-specific recommendations |
| 12 | "Show me role-based Sales Cloud content" | content_search | Personalization + Role | Role-tailored results |
| 13 | "Get customized Marketing Cloud content for EMEA-ENTR" | content_search | Personalization + Region | Region-specific content |
| 14 | "Find tailored Service Cloud content for my role" | content_search | Personalization + Role | Personalized recommendations |
| 15 | "Search for OU-specific Tableau content" | content_search | Personalization + OU | OU-filtered results |

### **4. Quality & Validation (5 tests)**
| # | Utterance | Expected Tool | Expected Features | Expected Result |
|---|-----------|---------------|-------------------|-----------------|
| 16 | "Find quality Data Cloud content with validation" | content_search | Quality + Validation | Quality-checked results |
| 17 | "Show me validated Sales Cloud content" | content_search | Quality + Validation | Validated content only |
| 18 | "Get health-checked Marketing Cloud content" | content_search | Quality + Health | Health-validated results |
| 19 | "Find non-broken Service Cloud content" | content_search | Quality + Broken Link Check | Working links only |
| 20 | "Search for up-to-date Tableau content" | content_search | Quality + Freshness | Recent, valid content |

### **5. Lifecycle & Maintenance (5 tests)**
| # | Utterance | Expected Tool | Expected Features | Expected Result |
|---|-----------|---------------|-------------------|-----------------|
| 21 | "Find Data Cloud content that needs review" | content_search | Lifecycle + Review | Content requiring maintenance |
| 22 | "Show me outdated Sales Cloud content" | content_search | Lifecycle + Outdated | Stale content identification |
| 23 | "Get Marketing Cloud content for refresh" | content_search | Lifecycle + Refresh | Content needing updates |
| 24 | "Find Service Cloud content for EOA review" | content_search | Lifecycle + EOA | End-of-life candidates |
| 25 | "Search for Tableau content maintenance" | content_search | Lifecycle + Maintenance | Maintenance-required content |

### **6. Analytics & Performance (5 tests)**
| # | Utterance | Expected Tool | Expected Features | Expected Result |
|---|-----------|---------------|-------------------|-----------------|
| 26 | "Find high-performing Data Cloud content" | content_search | Analytics + Performance | Top-performing results |
| 27 | "Show me trending Sales Cloud content" | content_search | Analytics + Trending | Popular, trending content |
| 28 | "Get high-engagement Marketing Cloud content" | content_search | Analytics + Engagement | High-engagement results |
| 29 | "Find most enrolled Service Cloud courses" | content_search | Analytics + Enrollment | High-enrollment content |
| 30 | "Search for effective Tableau content with metrics" | content_search | Analytics + Metrics | Metrics-driven results |

---

## 🎯 **Expected Outcomes**

### **Feature Detection Success Rate**
- **Tool Detection**: 100% (30/30)
- **Parameter Extraction**: 95%+ (28/30)
- **Intelligence Flags**: 90%+ (27/30)
- **OU Detection**: 85%+ (25/30)
- **Product Detection**: 90%+ (27/30)

### **Response Quality Metrics**
- **Explainability**: Every result includes "Why" reasoning
- **Scoring**: All results have intelligence scores
- **Lifecycle Flags**: Appropriate flags for maintenance content
- **Personalization**: OU/role-specific recommendations when requested
- **Quality Checks**: Validation and health indicators

### **Performance Benchmarks**
- **Response Time**: < 2 seconds per request
- **CPU Usage**: < 7 seconds total
- **SOQL Queries**: < 40 per request
- **Memory Usage**: < 5.5MB heap

---

## 🔍 **Validation Criteria**

### **1. Tool Detection Validation**
```json
{
  "tool": "content_search",
  "confidence": "high",
  "parameters": {
    "userUtterance": "Find intelligent Data Cloud content",
    "topic": "Data Cloud",
    "includeSemantic": true,
    "includeQuality": true
  }
}
```

### **2. Intelligence Features Validation**
- ✅ **Semantic Ranking**: Enabled for "intelligent", "smart", "contextual"
- ✅ **Personalization**: Enabled for "personalized", "role-based", "OU-specific"
- ✅ **Quality Checks**: Enabled for "quality", "validation", "health"
- ✅ **Lifecycle Signals**: Enabled for "review", "maintenance", "EOA"
- ✅ **Analytics Signals**: Enabled for "performance", "trending", "engagement"

### **3. Response Structure Validation**
```json
{
  "message": "**Content Intelligence Search**\n\n**SUMMARY**\nSearched for: Data Cloud\n...",
  "results": [
    {
      "source": "Consensus",
      "title": "Data Cloud Demo - intelligent",
      "score": 425.5,
      "why": "Exact product match: Data Cloud; High semantic similarity: 0.9; Recent content: 15 days old",
      "lifecycleFlags": [],
      "personalizationReason": "OU match: AMER-ACC"
    }
  ],
  "explain": ["Semantic ranking applied", "Quality checks enabled"],
  "nextBestActions": ["Review top-scoring content", "Check lifecycle flags"]
}
```

---

## 📊 **Test Execution Plan**

### **Phase 1: Basic Functionality (Tests 1-5)**
- Validate tool detection and basic parameter extraction
- Ensure backward compatibility with existing functionality
- Verify basic scoring and ranking

### **Phase 2: Intelligence Features (Tests 6-10)**
- Test semantic ranking and explainability
- Validate intelligence flag detection
- Verify enhanced scoring algorithms

### **Phase 3: Personalization (Tests 11-15)**
- Test OU-specific recommendations
- Validate role-based filtering
- Verify personalization reasoning

### **Phase 4: Quality & Lifecycle (Tests 16-25)**
- Test quality validation features
- Validate lifecycle signal generation
- Verify maintenance recommendations

### **Phase 5: Analytics & Performance (Tests 26-30)**
- Test analytics-driven recommendations
- Validate performance metrics
- Verify trending and engagement scoring

---

## 🚨 **Failure Scenarios & Troubleshooting**

### **Common Failure Patterns**
1. **Tool Detection Failures**: Check pattern matching in MCP server
2. **Parameter Extraction Issues**: Verify regex patterns and extraction logic
3. **Intelligence Flag Missing**: Check flag detection patterns
4. **Scoring Inconsistencies**: Validate scoring algorithm logic
5. **Performance Issues**: Monitor CPU and memory usage

### **Debug Information**
- Enable debug logging in MCP server
- Check Salesforce debug logs for Apex execution
- Verify metadata configuration
- Test with simplified utterances

---

## 📈 **Success Metrics**

### **Primary Success Criteria**
- **Overall Success Rate**: 90%+ (27/30 tests pass)
- **Feature Detection**: 90%+ intelligence flags detected
- **Response Quality**: All responses include explainability
- **Performance**: All requests complete within limits

### **Secondary Success Criteria**
- **User Experience**: Clear, actionable responses
- **Explainability**: Every result includes reasoning
- **Intelligence**: Smart ranking and recommendations
- **Maintainability**: Clear lifecycle and quality signals

---

## 🎉 **Expected Business Impact**

### **Immediate Benefits**
- **3x improvement** in content discovery success rate
- **50% reduction** in time to find relevant content
- **40% increase** in content utilization

### **Long-term Benefits**
- **Data-driven content strategy** with analytics insights
- **Automated content maintenance** with lifecycle signals
- **Personalized learning experience** with role-based recommendations
- **Quality assurance** with automated validation

This UAT test pack provides comprehensive coverage of all Content Intelligence features and ensures the system meets the specified requirements for intelligent, personalized content discovery.
