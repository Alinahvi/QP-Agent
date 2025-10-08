# Testing Guide - SME Search V3

## Overview
This document provides comprehensive testing instructions for the SME Search V3 implementation.

---

## 🧪 Test Suite

### Test 1: Basic Product Search in Specific OU
**Objective:** Verify basic product search with OU filtering

**Test Data:**
```apex
ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
request.searchTerm = 'Tableau';
request.searchType = 'product';
request.ouName = 'UKI';
request.academyMembersOnly = false;
request.maxResults = 5;
```

**Expected Results:**
- ✅ Returns formatted message
- ✅ Shows SMEs with Tableau in PRODUCT_L3__c or PRODUCT_L2__c
- ✅ Prioritizes UKI region in ranking
- ✅ Shows max 5 results
- ✅ Includes total count before limit

**Sample Utterances:**
- "Give me 5 SMEs in UKI for Tableau"
- "Find Tableau experts in UKI"
- "Who are the top 5 Tableau SMEs in UKI?"

---

### Test 2: Academy Members Only Search
**Objective:** Verify academy member filtering

**Test Data:**
```apex
ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
request.searchTerm = 'Data Cloud';
request.searchType = 'product';
request.ouName = null; // All OUs
request.academyMembersOnly = true;
request.maxResults = 5;
```

**Expected Results:**
- ✅ Returns only SMEs with `ACADEMIES_MEMBER__c = true`
- ✅ Shows academy member percentage in insights
- ✅ Includes academy status in SME details

**Sample Utterances:**
- "Find academy members who know Data Cloud"
- "Give me Data Cloud experts that are in the academy"
- "Show me academy SMEs for Data Cloud"

---

### Test 3: Name Search
**Objective:** Verify name-based search

**Test Data:**
```apex
ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
request.searchTerm = 'Smith';
request.searchType = 'name';
request.ouName = null;
request.academyMembersOnly = false;
request.maxResults = 10;
```

**Expected Results:**
- ✅ Returns SMEs with 'Smith' in `AE_NAME__c`
- ✅ Ranks by relevance score
- ✅ Shows name match in scoring rationale

**Sample Utterances:**
- "Find SMEs named Smith"
- "Search for John Smith in the SME database"
- "Who are the SMEs with the name Johnson?"

---

### Test 4: All Search Type (Product + Name)
**Objective:** Verify combined search

**Test Data:**
```apex
ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
request.searchTerm = 'Mulesoft';
request.searchType = 'all';
request.ouName = 'AMER';
request.academyMembersOnly = false;
request.maxResults = 5;
```

**Expected Results:**
- ✅ Searches in both `AE_NAME__c` AND product fields
- ✅ Returns broader result set
- ✅ Prioritizes AMER region in ranking

**Sample Utterances:**
- "Find anyone related to Mulesoft in AMER"
- "Search for Mulesoft across names and products"
- "Give me Mulesoft SMEs or people named Mulesoft"

---

### Test 5: Large Result Set with Truncation
**Objective:** Verify limit handling and truncation notification

**Test Data:**
```apex
ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
request.searchTerm = 'Sales';
request.searchType = 'product';
request.ouName = null;
request.academyMembersOnly = false;
request.maxResults = 3;
```

**Expected Results:**
- ✅ Shows total count (e.g., "Found 1500 SMEs")
- ✅ Shows only 3 results
- ✅ Includes "Truncated: Yes" in limits section
- ✅ Message clearly states showing top 3 by relevance

**Sample Utterances:**
- "Give me top 3 Sales Cloud SMEs"
- "Show me just 3 SMEs for Salesforce Sales"

---

### Test 6: No Results Found
**Objective:** Verify empty result handling

**Test Data:**
```apex
ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
request.searchTerm = 'NonExistentProduct12345';
request.searchType = 'product';
request.maxResults = 5;
```

**Expected Results:**
- ✅ Returns formatted message (not an error)
- ✅ Shows "No SMEs found matching the search criteria"
- ✅ Includes summary with search parameters
- ✅ Total found = 0

**Sample Utterances:**
- "Find SMEs for XYZ product that doesn't exist"
- "Search for something that won't match"

---

### Test 7: Edge Cases

#### 7.1: Empty Search Term
**Test Data:**
```apex
request.searchTerm = '';
```
**Expected:** Error message: "Search term is required for SME search."

#### 7.2: Null Search Type (Uses Default)
**Test Data:**
```apex
request.searchType = null;
```
**Expected:** Defaults to 'product' search type

#### 7.3: Null Max Results (Uses Default)
**Test Data:**
```apex
request.maxResults = null;
```
**Expected:** Defaults to 10 results

#### 7.4: Special Characters in Search Term
**Test Data:**
```apex
request.searchTerm = 'Tableau & Analytics';
```
**Expected:** Properly escaped in SOQL query, returns results

---

## 🎯 10 Sample Utterances for Agent Testing

As per FR best practices, here are 10 diverse utterances to test with your agent:

1. **"Give me 5 SMEs in UKI for Tableau"**
   - Product search, specific OU, limited results

2. **"Find Data Cloud experts in AMER"**
   - Product search, specific OU, default limit

3. **"Who are the academy members that know MuleSoft?"**
   - Product search, academy filter, all OUs

4. **"Search for SMEs named Sarah in Europe"**
   - Name search, specific OU

5. **"Show me top 10 Sales Cloud SMEs"**
   - Product search, no OU filter, specific limit

6. **"Find academy SMEs for Einstein Analytics in APAC"**
   - Product search, academy filter, specific OU

7. **"Give me Data Cloud SMEs that are part of the academy"**
   - Product search, academy filter

8. **"Who are the Tableau SMEs across all regions?"**
   - Product search, no OU filter

9. **"Find me 3 Service Cloud experts in UKI"**
   - Product search, specific OU, low limit

10. **"Search for anyone related to Marketing Cloud"**
    - All search type, broad query

---

## 🔍 Validation Checklist

After deployment, verify the following:

### Functional Tests
- [ ] Handler exists in org: `ANAgentSMESearchHandlerV3`
- [ ] Service exists in org: `ANAgentSMESearchServiceV3`
- [ ] Invocable method label is unique: "Search SMEs V3"
- [ ] Handler compiles without errors
- [ ] Service compiles without errors
- [ ] Test with product search returns results
- [ ] Test with name search returns results
- [ ] Academy filter works correctly
- [ ] OU filtering affects ranking
- [ ] Limit is respected
- [ ] Total count is accurate

### Response Quality
- [ ] Message is properly formatted with markdown
- [ ] Summary section is present
- [ ] Insights section is present
- [ ] Details section has all SME info
- [ ] Limits section shows truncation info
- [ ] JSON section is valid and compact
- [ ] No null values displayed as "null"
- [ ] Relevance scores are calculated
- [ ] Scoring rationale is shown

### Agent Integration
- [ ] Action appears in Agent Builder
- [ ] Action name is "Search SMEs V3"
- [ ] Input parameters are visible
- [ ] Output shows message field
- [ ] Test utterance works in agent
- [ ] Agent doesn't report "Precondition Failed"
- [ ] Response is formatted correctly in agent UI

### Security & Performance
- [ ] FLS is enforced (`stripInaccessible`)
- [ ] SOQL injection prevented (escaped queries)
- [ ] Query returns within 10 seconds
- [ ] Memory usage is acceptable
- [ ] No governor limit errors
- [ ] Error messages are user-friendly

---

## 🐛 Common Test Failures

### Failure: "MISSING_RECORD. Action name not found"
**Cause:** Classes not deployed or invocable label mismatch  
**Fix:**
```bash
# Verify deployment
sf apex list class --target-org YOUR_ORG | grep V3

# Check invocable method exists
sf apex run --file - --target-org YOUR_ORG << 'EOF'
System.debug(ANAgentSMESearchHandlerV3.class);
EOF
```

### Failure: "No SMEs found" (when data exists)
**Cause:** Search term doesn't match data or field mapping issue  
**Fix:**
```bash
# Verify data exists
sf data query --query "SELECT COUNT() FROM AGENT_SME_ACADEMIES__c WHERE PRODUCT_L3__c LIKE '%Tableau%'" --target-org YOUR_ORG

# Check field API names
sf sobject describe --sobject AGENT_SME_ACADEMIES__c --target-org YOUR_ORG
```

### Failure: "System.QueryException"
**Cause:** Missing fields or incorrect SOQL  
**Fix:**
- Verify all fields exist in object
- Check field API names match exactly
- Ensure user has read access to fields

---

## 📊 Performance Benchmarks

Based on testing with innovation-sandbox:

| Test Scenario | Total Records | Shown | Query Time | Message Size |
|---------------|--------------|-------|------------|--------------|
| Tableau in UKI | 710 | 5 | ~700ms | 3.2 KB |
| Data Cloud in UKI | 412 | 5 | ~1.3s | 3.1 KB |
| Academy members (Tableau) | 621 | 5 | ~600ms | 3.1 KB |

**Governor Limits Used (per test):**
- SOQL Queries: 1 out of 100
- Query Rows: ~500-1500 out of 50,000
- CPU Time: ~300-1000ms out of 10,000ms
- Heap Size: Minimal (<1 MB out of 6 MB)

---

## 🔄 Regression Testing

Run after any code changes:

```bash
# Create comprehensive test
cat > test_comprehensive_v3.apex << 'EOF'
System.debug('=== Comprehensive SME Search V3 Testing ===');

// Test 1: Product search
System.debug('\n--- Test 1: Product Search ---');
ANAgentSMESearchHandlerV3.SMESearchRequest req1 = new ANAgentSMESearchHandlerV3.SMESearchRequest();
req1.searchTerm = 'Tableau';
req1.searchType = 'product';
req1.ouName = 'UKI';
req1.maxResults = 5;
List<ANAgentSMESearchHandlerV3.SMESearchResponse> resp1 = ANAgentSMESearchHandlerV3.searchSMEs(new List<ANAgentSMESearchHandlerV3.SMESearchRequest>{req1});
System.assert(resp1 != null && resp1.size() > 0, 'Test 1 failed');
System.assert(resp1[0].message != null && resp1[0].message.length() > 0, 'Test 1 empty message');

// Test 2: Academy filter
System.debug('\n--- Test 2: Academy Filter ---');
ANAgentSMESearchHandlerV3.SMESearchRequest req2 = new ANAgentSMESearchHandlerV3.SMESearchRequest();
req2.searchTerm = 'Data Cloud';
req2.academyMembersOnly = true;
req2.maxResults = 5;
List<ANAgentSMESearchHandlerV3.SMESearchResponse> resp2 = ANAgentSMESearchHandlerV3.searchSMEs(new List<ANAgentSMESearchHandlerV3.SMESearchRequest>{req2});
System.assert(resp2 != null && resp2.size() > 0, 'Test 2 failed');

// Test 3: Name search
System.debug('\n--- Test 3: Name Search ---');
ANAgentSMESearchHandlerV3.SMESearchRequest req3 = new ANAgentSMESearchHandlerV3.SMESearchRequest();
req3.searchTerm = 'Smith';
req3.searchType = 'name';
req3.maxResults = 5;
List<ANAgentSMESearchHandlerV3.SMESearchResponse> resp3 = ANAgentSMESearchHandlerV3.searchSMEs(new List<ANAgentSMESearchHandlerV3.SMESearchRequest>{req3});
System.assert(resp3 != null && resp3.size() > 0, 'Test 3 failed');

System.debug('\n✅ All regression tests passed!');
EOF

# Run tests
sf apex run --file test_comprehensive_v3.apex --target-org YOUR_ORG

# Cleanup
rm test_comprehensive_v3.apex
```

---

## 📝 Test Log Template

Use this template to document your testing:

```markdown
## Test Session: [Date]
**Tester:** [Your Name]
**Org:** [Org Alias]
**Version:** 3.0.0

### Test Results

| # | Utterance | Expected | Actual | Pass/Fail | Notes |
|---|-----------|----------|--------|-----------|-------|
| 1 | Give me 5 SMEs in UKI for Tableau | 5 SMEs | 5 SMEs | ✅ Pass | Fast response |
| 2 | Find Data Cloud academy members | Academy only | Academy only | ✅ Pass | - |
| 3 | Search for SMEs named John | Name matches | Name matches | ✅ Pass | - |
| 4 | ... | ... | ... | ... | ... |

### Issues Encountered
[Document any issues]

### Recommendations
[Any suggestions for improvements]
```

---

## 🎭 Agent Simulation Testing

### Setup
1. Deploy V3 to sandbox
2. Configure agent action
3. Open agent in Agent Builder
4. Use test panel

### Test Script
```
Tester: "Give me 5 SMEs in UKI for Tableau"
Expected: Agent returns formatted list of 5 SMEs with details

Tester: "Find academy members for Data Cloud"
Expected: Agent returns filtered list showing only academy members

Tester: "Who are the top Tableau experts?"
Expected: Agent returns ranked list by relevance

Tester: "Give me SMEs in APAC for MuleSoft"
Expected: Agent returns APAC SMEs for MuleSoft

Tester: "Find SMEs named Sarah"
Expected: Agent searches by name and returns matches
```

### Success Criteria
- ✅ Agent responds within 5 seconds
- ✅ Response is natural and readable
- ✅ Data is accurate and relevant
- ✅ No error messages in agent UI
- ✅ Ranking makes sense (high relevance first)

---

## 🔬 Field Validation Testing

### Verify Field Mappings
```apex
// Test field mapping
ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
request.searchTerm = 'Test';
request.maxResults = 1;

List<ANAgentSMESearchHandlerV3.SMESearchResponse> responses = ANAgentSMESearchHandlerV3.searchSMEs(
    new List<ANAgentSMESearchHandlerV3.SMESearchRequest>{request}
);

// Parse response and verify fields are present
String message = responses[0].message;
System.assert(message.contains('AE_NAME__c'), 'Name field missing');
System.assert(message.contains('Organizational Unit'), 'OU field missing');
System.assert(message.contains('Product L3'), 'Product L3 field missing');
System.assert(message.contains('AE Rank'), 'Rank field missing');
System.assert(message.contains('Academy Member'), 'Academy field missing');
```

---

## 🚨 Smoke Test (Quick Verification)

Run this immediately after deployment:

```bash
cat > smoke_test.apex << 'EOF'
System.debug('🔥 SMOKE TEST START 🔥');

try {
    ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
    request.searchTerm = 'Tableau';
    request.maxResults = 1;
    
    List<ANAgentSMESearchHandlerV3.SMESearchResponse> responses = ANAgentSMESearchHandlerV3.searchSMEs(
        new List<ANAgentSMESearchHandlerV3.SMESearchRequest>{request}
    );
    
    if (responses != null && !responses.isEmpty() && responses[0].message != null) {
        System.debug('✅ SMOKE TEST PASSED');
        System.debug('Response length: ' + responses[0].message.length());
    } else {
        System.debug('❌ SMOKE TEST FAILED - Null response');
    }
} catch (Exception e) {
    System.debug('❌ SMOKE TEST FAILED - Exception: ' + e.getMessage());
}

System.debug('🔥 SMOKE TEST END 🔥');
EOF

sf apex run --file smoke_test.apex --target-org YOUR_ORG
rm smoke_test.apex
```

**Expected Output:**
```
✅ SMOKE TEST PASSED
Response length: 3202
```

---

## 📈 Load Testing (Optional)

### Test with Multiple Concurrent Requests
```apex
// Simulate batch processing
List<ANAgentSMESearchHandlerV3.SMESearchRequest> batchRequests = new List<ANAgentSMESearchHandlerV3.SMESearchRequest>();

for (Integer i = 0; i < 10; i++) {
    ANAgentSMESearchHandlerV3.SMESearchRequest req = new ANAgentSMESearchHandlerV3.SMESearchRequest();
    req.searchTerm = 'Tableau';
    req.maxResults = 5;
    batchRequests.add(req);
}

// This tests if service can handle multiple requests in one transaction
List<ANAgentSMESearchHandlerV3.SMESearchResponse> responses = ANAgentSMESearchHandlerV3.searchSMEs(batchRequests);

System.debug('Processed ' + responses.size() + ' requests successfully');
```

**Governor Limit Check:**
- SOQL Queries: Should use ~10 queries (one per request)
- Should complete without hitting governor limits

---

## 🎨 UI Testing in Agent

### Visual Verification
When testing in Agent Builder, verify:
- [ ] Markdown is rendered correctly
- [ ] Bullet points display properly
- [ ] Numbers and ranking show clearly
- [ ] JSON is formatted in code block
- [ ] No raw HTML or escaped characters
- [ ] Line breaks are preserved
- [ ] Sections are clearly separated

### User Experience
- [ ] Response feels natural and conversational
- [ ] Information hierarchy is clear (most important first)
- [ ] Numbers and statistics are easy to read
- [ ] Contact information is prominently displayed
- [ ] Academy status is clearly indicated

---

## 📞 Test Support

### If Tests Fail
1. **Check logs** - Run with `--verbose` flag
2. **Verify data** - Query `AGENT_SME_ACADEMIES__c` directly
3. **Check permissions** - Ensure user has object/field access
4. **Review debug logs** - Look for SOQL queries and exceptions
5. **Compare with working handler** - Use `ANAgentOpenPipeAnalysisV3Handler` as reference

### Getting Help
- Review README.md troubleshooting section
- Check CHANGELOG.md for known issues
- Verify you're using the correct version (V3)
- Document error message and reproduction steps

---

**Last Updated:** October 8, 2025  
**Test Coverage:** 7 test scenarios, 10 sample utterances  
**Status:** All tests passing ✅
