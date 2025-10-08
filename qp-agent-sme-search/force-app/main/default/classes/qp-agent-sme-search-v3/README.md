# SME Search V3 - FR-Style Implementation

## Overview
This package contains a production-ready SME (Subject Matter Expert) search implementation following **FR-style best practices** for Salesforce Agentforce integration.

**Version:** 3.0  
**Date:** October 8, 2025  
**API Version:** 62.0  
**Status:** Production Ready ✅

---

## 📋 Package Contents

### Apex Classes
1. **ANAgentSMESearchHandlerV3.cls** - Dumb router handler
2. **ANAgentSMESearchHandlerV3.cls-meta.xml** - Handler metadata
3. **ANAgentSMESearchServiceV3.cls** - Business logic service
4. **ANAgentSMESearchServiceV3.cls-meta.xml** - Service metadata

---

## 🏗️ Architecture - FR-Style Compliance

### ✅ Agent Boundary = 1 Variable Only
- Response exposes **ONLY** `message: String` field
- No Lists, Maps, Sets, SObjects, or nested DTOs at the boundary
- Agent reads only the message field

### ✅ Handler = Dumb Router
- **Exactly one** `@InvocableMethod`
- **No business logic** in handler
- Pattern: Input validation → Service call → Return message

### ✅ Service = All Logic + DTO Composer
- All business logic in service layer
- Builds complete formatted message string
- Structure: HEADER → SUMMARY → INSIGHTS → DETAILS → LIMITS & COUNTS → JSON
- Uses `Security.stripInaccessible()` for FLS compliance
- Deterministic limits with explicit truncation info

---

## 📊 Data Source

**Object:** `AGENT_SME_ACADEMIES__c`

### Required Fields:
- `Id`
- `AE_NAME__c` - Account Executive name
- `AE_RANK__c` - Ranking score
- `OU__c` - Organizational Unit
- `TOTAL_ACV__c` - Total Annual Contract Value
- `PRODUCT_L3__c` - Product Level 3
- `PRODUCT_L2__c` - Product Level 2
- `ACADEMIES_MEMBER__c` - Boolean flag for academy membership
- `CreatedDate`
- `LastModifiedDate`

---

## 🚀 Deployment Instructions

### Prerequisites
- Salesforce CLI installed
- Authenticated to target org
- Object `AGENT_SME_ACADEMIES__c` must exist with required fields

### Step 1: Deploy to Org
```bash
# Navigate to package directory
cd qp-agent-sme-search-v3

# Deploy to your org
sf project deploy start \
  --source-dir force-app/main/default/classes \
  --target-org YOUR_ORG_ALIAS \
  --wait 10
```

### Step 2: Verify Deployment
```bash
# Check deployment status
sf project deploy report --target-org YOUR_ORG_ALIAS

# Verify classes are deployed
sf apex list class --target-org YOUR_ORG_ALIAS | grep ANAgentSMESearchHandlerV3
sf apex list class --target-org YOUR_ORG_ALIAS | grep ANAgentSMESearchServiceV3
```

### Step 3: Test the Implementation
```bash
# Create test file
cat > test_sme_v3.apex << 'EOF'
ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
request.searchTerm = 'Tableau';
request.searchType = 'product';
request.ouName = 'UKI';
request.academyMembersOnly = false;
request.maxResults = 5;

List<ANAgentSMESearchHandlerV3.SMESearchRequest> requests = new List<ANAgentSMESearchHandlerV3.SMESearchRequest>{request};
List<ANAgentSMESearchHandlerV3.SMESearchResponse> responses = ANAgentSMESearchHandlerV3.searchSMEs(requests);

System.debug('Response: ' + responses[0].message);
EOF

# Run test
sf apex run --file test_sme_v3.apex --target-org YOUR_ORG_ALIAS

# Clean up
rm test_sme_v3.apex
```

---

## 🔧 Integration with Agentforce

### Add as Agent Action

1. **Navigate to Agent Builder**
   - Setup → Agents → Select your agent

2. **Add Action**
   - Click "New Action"
   - Select "Apex"
   - Choose **"Search SMEs V3"**

3. **Configure Input Instructions**
```
Search for Subject Matter Experts by product name or AE name.

Required:
- searchTerm: The product or person name to search for (e.g., "Tableau", "Data Cloud")

Optional:
- searchType: "product", "name", or "all" (default: "product")
- maxResults: Number of results to return (default: 10)
- academyMembersOnly: true/false (default: false)
- ouName: Filter by organizational unit (e.g., "UKI", "AMER")

Example queries:
- "Find SMEs for Tableau in UKI"
- "Give me 5 academy members who know Data Cloud"
- "Search for SMEs named John"
```

4. **Configure Output Instructions**
```
The response contains a formatted message with:
- Summary of search parameters
- Key insights (top OU, academy member percentage)
- Detailed SME information (name, OU, products, ranking)
- Explicit limit information
- Compact JSON for further processing

Present the information naturally to the user, highlighting:
- SME names and their organizational units
- Product expertise
- Academy membership status
- Contact rankings
```

5. **Save and Test**
   - Save the action
   - Test with: "Give me 5 SMEs in UKI for Tableau"

---

## 🧪 Testing Scenarios

### Test 1: Basic Product Search
```apex
request.searchTerm = 'Tableau';
request.searchType = 'product';
request.ouName = 'UKI';
request.maxResults = 5;
```

### Test 2: Academy Members Only
```apex
request.searchTerm = 'Data Cloud';
request.searchType = 'product';
request.academyMembersOnly = true;
request.maxResults = 5;
```

### Test 3: Name Search
```apex
request.searchTerm = 'John';
request.searchType = 'name';
request.maxResults = 10;
```

### Test 4: All Search (Product + Name)
```apex
request.searchTerm = 'Smith';
request.searchType = 'all';
request.ouName = 'AMER';
request.maxResults = 5;
```

---

## 📝 Response Format

The service returns a single formatted message string with:

### 1. HEADER
```markdown
# SME Search Results
```

### 2. SUMMARY
```markdown
## Summary
- **Search Term**: Tableau
- **Search Type**: product
- **Organizational Unit**: UKI
- **Academy Members Only**: No
- **Total Found**: 710 SMEs
- **Showing**: 5 results
```

### 3. INSIGHTS
```markdown
## Insights
- **Top OU**: UKI (3 SMEs)
- **Academy Members**: 2 of 5 (40%)
```

### 4. DETAILS
```markdown
## SME Details
### 1. John Doe
- **Organizational Unit**: UKI
- **Product L3**: Tableau CRM
- **Product L2**: Analytics
- **AE Rank**: 95.5
- **Total ACV**: $1,250,000
- **Academy Member**: Yes
- **Relevance Score**: 165.5
- **Scoring**: AE Rank: 95.5 (+955), OU Match: UKI (+50), Academy Member (+25), L3 Product Match (+30)
```

### 5. LIMITS & COUNTS
```markdown
## Limits & Counts
- **Query Limit**: 5 results
- **Total Matches**: 710 (before limit)
- **Results Shown**: 5
- **Truncated**: Yes (showing top 5 by relevance)
```

### 6. JSON (Compact)
```json
{
  "searchTerm": "Tableau",
  "totalFound": 710,
  "showing": 5,
  "academyMembers": 2,
  "topOU": "UKI",
  "results": [...]
}
```

---

## 🔄 Rollback Instructions

If you need to revert to this version:

### From Any Future Version
```bash
# 1. Remove current version
sf project delete source \
  --metadata ApexClass:ANAgentSMESearchHandlerV3 \
  --metadata ApexClass:ANAgentSMESearchServiceV3 \
  --target-org YOUR_ORG_ALIAS

# 2. Deploy this package
cd qp-agent-sme-search-v3
sf project deploy start \
  --source-dir force-app/main/default/classes \
  --target-org YOUR_ORG_ALIAS \
  --wait 10

# 3. Verify deployment
sf apex list class --target-org YOUR_ORG_ALIAS | grep V3
```

### If Agent Action Broken
1. Remove action from agent
2. Save agent configuration
3. Close Agent Builder tab
4. Reopen Agent Builder
5. Add action back (this forces schema refresh)
6. Save and test

---

## 🛠️ Customization Guide

### Modify Ranking Logic
Edit `ANAgentSMESearchServiceV3.cls` → `calculateRelevanceScore()` method

```apex
private static void calculateRelevanceScore(SMEInfo sme, String searchTerm, String searchType, String ouName) {
    Double score = 0.0;
    
    // Customize scoring weights here
    if (sme.aeRank != null) {
        score += sme.aeRank * 10;  // Change multiplier
    }
    
    // Add your custom scoring logic
}
```

### Change Message Format
Edit `ANAgentSMESearchServiceV3.cls` → `buildCompleteMessage()` method

```apex
private static String buildCompleteMessage(...) {
    String message = '';
    
    // Customize message structure here
    message += '# Your Custom Header\n\n';
    // ... rest of formatting
    
    return message;
}
```

### Add New Search Types
Edit `ANAgentSMESearchServiceV3.cls` → `buildEnhancedSearchQuery()` method

```apex
private static String buildEnhancedSearchQuery(...) {
    // Add new search type conditions
    if (searchType.toLowerCase() == 'yourcustomtype') {
        whereClause = 'WHERE YOUR_FIELD__c LIKE \'%' + escapedSearchTerm + '%\'';
    }
}
```

---

## 🐛 Troubleshooting

### Issue: "MISSING_RECORD. Action name not found"
**Cause:** Classes not deployed or Agent Action not configured  
**Fix:** 
1. Verify deployment: `sf apex list class | grep V3`
2. Check invocable method label matches: "Search SMEs V3"
3. Remove and re-add action in Agent Builder

### Issue: "Precondition Failed: Unable to load agent config"
**Cause:** Multiple invocable methods with same label  
**Fix:**
1. Verify only one handler has label "Search SMEs V3"
2. Remove any conflicting handlers
3. Refresh Agent Builder (close and reopen)

### Issue: "No SMEs found"
**Cause:** Data not available or incorrect search term  
**Fix:**
1. Verify `AGENT_SME_ACADEMIES__c` has data
2. Check search term matches data in `PRODUCT_L3__c`, `PRODUCT_L2__c`, or `AE_NAME__c`
3. Try broader search with `searchType = 'all'`

### Issue: "Query Exception"
**Cause:** Missing fields or incorrect object API name  
**Fix:**
1. Verify all required fields exist
2. Check field API names match exactly
3. Ensure user has read access to object and fields

---

## 📈 Performance Considerations

- **Query Optimization**: Uses selective filters before sorting
- **Security**: Implements `Security.stripInaccessible()` for FLS
- **Limit Handling**: Explicit limit with truncation notification
- **Memory Efficient**: Builds string incrementally
- **Governor Limits**: Respects SOQL query limits (100 queries per transaction)

### Recommended Limits
- **maxResults**: Keep ≤ 50 for optimal performance
- **searchTerm**: Minimum 2 characters for meaningful results
- **Total Records**: Service handles up to 50,000 records per query

---

## 📚 Best Practices Followed

1. ✅ **Agent Boundary = 1 Variable Only** - Only `message` field exposed
2. ✅ **Handler = Dumb Router** - No business logic in handler
3. ✅ **Service = All Logic + DTO Composer** - Complete message building in service
4. ✅ **Flatten Everything** - No Lists, Maps, or nested DTOs at boundary
5. ✅ **Stable Formatting** - Predictable message structure
6. ✅ **Security Compliance** - FLS enforcement via `stripInaccessible()`
7. ✅ **Deterministic Limits** - Explicit truncation notification
8. ✅ **Unique Labels** - Org-wide unique invocable method label
9. ✅ **Public Visibility** - Uses `public` not `global`
10. ✅ **API Version Alignment** - Matches known-working actions (v62.0)

---

## 📞 Support & Maintenance

### Version History
- **v3.0** (Oct 8, 2025) - FR-style implementation with single message output
- **v2.0** (Deprecated) - Complex DTO structure (removed)
- **v1.0** (Deprecated) - Initial implementation (removed)

### Future Enhancements
- [ ] Add fuzzy matching for product names
- [ ] Implement caching for frequently searched terms
- [ ] Add email and phone fields to SME data
- [ ] Support for multiple language locales
- [ ] Export results to CSV functionality

---

## 📄 License
Internal use only - Salesforce Readiness Team

## 👥 Contributors
- AI Assistant (Development)
- Readiness Team (Requirements & Testing)

---

## 🔗 Related Resources
- [Salesforce Agentforce Documentation](https://help.salesforce.com/agentforce)
- [Invocable Apex Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableMethod.htm)
- [GitHub Repository](https://github.com/Alinahvi/QP-Agent)

---

**Last Updated:** October 8, 2025  
**Package Version:** 3.0.0  
**Tested On:** Salesforce v62.0
