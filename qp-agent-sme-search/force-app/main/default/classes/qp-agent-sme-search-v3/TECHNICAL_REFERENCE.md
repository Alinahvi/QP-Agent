# Technical Reference - SME Search V3

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Agentforce                            │
│  (Sends invocable request with search parameters)           │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│         ANAgentSMESearchHandlerV3 (DUMB ROUTER)             │
│  • Validates input (searchTerm required)                    │
│  • Sets defaults (searchType, maxResults, etc.)             │
│  • Calls service with parameters                            │
│  • Returns single message string                            │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│      ANAgentSMESearchServiceV3 (BUSINESS LOGIC)             │
│  • Builds SOQL query with proper escaping                   │
│  • Executes query with Security.stripInaccessible()         │
│  • Calculates relevance scores                              │
│  • Sorts by ranking                                         │
│  • Applies limits                                           │
│  • Builds complete formatted message                        │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              AGENT_SME_ACADEMIES__c Object                  │
│  (Queries fields: AE_NAME__c, PRODUCT_L3__c, etc.)         │
└─────────────────────────────────────────────────────────────┘
```

---

## Class Diagram

```
ANAgentSMESearchHandlerV3
├── SMESearchRequest (Inner Class)
│   ├── searchTerm: String (required)
│   ├── searchType: String (optional)
│   ├── maxResults: Integer (optional)
│   ├── academyMembersOnly: Boolean (optional)
│   ├── ouName: String (optional)
│   └── useEnhancedSearch: Boolean (optional)
│
├── SMESearchResponse (Inner Class)
│   └── message: String (required) ← ONLY FIELD EXPOSED TO AGENT
│
└── searchSMEs() [InvocableMethod]
    └── Returns List<SMESearchResponse>

ANAgentSMESearchServiceV3
├── SMEInfo (Private Inner Class)
│   ├── id, name, aeName, aeRank
│   ├── organizationalUnit, totalACV
│   ├── productL3, productL2
│   ├── isAcademyMember
│   ├── createdDate, lastModifiedDate
│   ├── relevanceScore, scoringRationale, isFuzzyMatch
│   └── Constructor(11 parameters)
│
├── SMERankingComparator (Private Inner Class)
│   └── compare() - Sorts by relevanceScore, aeRank, totalACV
│
└── Public Methods
    ├── searchSMEsEnhanced() → Returns String
    │   └── Main entry point
    │
    └── Private Methods
        ├── buildEnhancedSearchQuery()
        ├── processSMERecordsWithRanking()
        ├── calculateRelevanceScore()
        ├── buildCompleteMessage()
        └── buildErrorMessage()
```

---

## Data Flow

```
1. Agent Request
   └─> Agentforce parses user utterance
       └─> Extracts parameters (searchTerm, ouName, etc.)

2. Handler Receives Request
   └─> ANAgentSMESearchHandlerV3.searchSMEs()
       ├─> Validates searchTerm is not blank
       ├─> Sets defaults (searchType='product', maxResults=10)
       └─> Calls service.searchSMEsEnhanced()

3. Service Processes Request
   └─> ANAgentSMESearchServiceV3.searchSMEsEnhanced()
       ├─> Builds SOQL query with escaped search term
       ├─> Executes query: List<SObject> records
       ├─> Applies FLS: Security.stripInaccessible()
       ├─> Converts to List<SMEInfo>
       ├─> Calculates relevance scores
       ├─> Sorts by SMERankingComparator
       ├─> Applies limit (keep top N)
       ├─> Builds formatted message string
       └─> Returns: String message

4. Handler Returns Response
   └─> Wraps message in SMESearchResponse
       └─> Returns List<SMESearchResponse>

5. Agent Presents Results
   └─> Reads response.message
       └─> Formats for user in natural language
```

---

## SOQL Query Construction

### Query Template
```sql
SELECT Id, AE_NAME__c, AE_RANK__c, OU__c, TOTAL_ACV__c, 
       PRODUCT_L3__c, PRODUCT_L2__c, ACADEMIES_MEMBER__c, 
       CreatedDate, LastModifiedDate
FROM AGENT_SME_ACADEMIES__c
WHERE [DYNAMIC_WHERE_CLAUSE]
ORDER BY AE_RANK__c DESC NULLS LAST, TOTAL_ACV__c DESC NULLS LAST
```

### Where Clause Construction

**Product Search:**
```sql
WHERE (PRODUCT_L3__c LIKE '%Tableau%' OR PRODUCT_L2__c LIKE '%Tableau%')
```

**Name Search:**
```sql
WHERE AE_NAME__c LIKE '%John Smith%'
```

**All Search:**
```sql
WHERE (AE_NAME__c LIKE '%MuleSoft%' 
       OR PRODUCT_L3__c LIKE '%MuleSoft%' 
       OR PRODUCT_L2__c LIKE '%MuleSoft%')
```

**With Academy Filter:**
```sql
WHERE (PRODUCT_L3__c LIKE '%Tableau%' OR PRODUCT_L2__c LIKE '%Tableau%')
  AND ACADEMIES_MEMBER__c = true
```

### SOQL Injection Prevention
```apex
// CORRECT - Escape user input
String escapedSearchTerm = String.escapeSingleQuotes(searchTerm);
String query = 'WHERE PRODUCT_L3__c LIKE \'%' + escapedSearchTerm + '%\'';

// WRONG - Using bind variables in dynamic SOQL
String query = 'WHERE PRODUCT_L3__c LIKE \'%:searchTerm%\''; // ❌ Will fail
```

---

## Ranking Algorithm

### Relevance Score Calculation

```apex
Double score = 0.0;

// 1. Base score from AE_RANK__c
if (sme.aeRank != null) {
    score += sme.aeRank * 10;  // Multiplier: 10
}

// 2. OU matching bonus
if (sme.organizationalUnit == ouName) {
    score += 50;  // Exact match bonus
}

// 3. Academy member bonus
if (sme.isAcademyMember == true) {
    score += 25;  // Academy member bonus
}

// 4. Product relevance (for product searches)
if (sme.productL3.contains(searchTerm)) {
    score += 30;  // L3 match bonus
} else if (sme.productL2.contains(searchTerm)) {
    score += 20;  // L2 match bonus (lower than L3)
}

// 5. Name relevance (for name searches)
if (sme.aeName.contains(searchTerm)) {
    score += 40;  // Name match bonus
}

sme.relevanceScore = score;
```

### Sorting Priority
1. **Primary:** Relevance Score (highest first)
2. **Secondary:** AE Rank (highest first)
3. **Tertiary:** Total ACV (highest first)

### Example Scores

**Scenario:** Searching for "Tableau" in "UKI"

| SME | AE Rank | OU Match | Academy | Product Match | Total Score |
|-----|---------|----------|---------|---------------|-------------|
| John Doe | 95.5 | Yes | Yes | L3 | 955 + 50 + 25 + 30 = **1060** |
| Jane Smith | 89.0 | Yes | No | L3 | 890 + 50 + 0 + 30 = **970** |
| Bob Johnson | 92.0 | No | Yes | L2 | 920 + 0 + 25 + 20 = **965** |

Result order: John Doe → Jane Smith → Bob Johnson

---

## Field Mappings

### SObject → SMEInfo Mapping

```apex
// From AGENT_SME_ACADEMIES__c record to SMEInfo
new SMEInfo(
    String.valueOf(record.get('Id')),                      // id
    String.valueOf(record.get('AE_NAME__c')),              // name
    String.valueOf(record.get('AE_NAME__c')),              // aeName
    (Double) record.get('AE_RANK__c'),                     // aeRank
    String.valueOf(record.get('OU__c')),                   // organizationalUnit
    (Double) record.get('TOTAL_ACV__c'),                   // totalACV
    String.valueOf(record.get('PRODUCT_L3__c')),           // productL3
    String.valueOf(record.get('PRODUCT_L2__c')),           // productL2
    (Boolean) record.get('ACADEMIES_MEMBER__c'),           // isAcademyMember
    (Datetime) record.get('CreatedDate'),                  // createdDate
    (Datetime) record.get('LastModifiedDate')              // lastModifiedDate
);
```

### SMEInfo → Message String Mapping

```markdown
### [Index]. [aeName]
- **Organizational Unit**: [organizationalUnit]
- **Product L3**: [productL3]
- **Product L2**: [productL2]
- **AE Rank**: [aeRank]
- **Total ACV**: $[totalACV]
- **Academy Member**: [isAcademyMember ? 'Yes' : 'No']
- **Relevance Score**: [relevanceScore]
- **Scoring**: [scoringRationale]
```

---

## Message Structure Specification

### Complete Message Template

```markdown
# SME Search Results

## Summary
- **Search Term**: {searchTerm}
- **Search Type**: {searchType}
- **Organizational Unit**: {ouName || 'All'}
- **Academy Members Only**: {academyMembersOnly ? 'Yes' : 'No'}
- **Total Found**: {totalFound} SMEs
- **Showing**: {showing} results

## Insights
- **Top OU**: {topOU} ({count} SMEs)
- **Academy Members**: {academyCount} of {showing} ({percentage}%)

## SME Details
{for each SME}
### {index}. {aeName}
- **Organizational Unit**: {ou}
- **Product L3**: {productL3}
- **Product L2**: {productL2}
- **AE Rank**: {aeRank}
- **Total ACV**: ${totalACV}
- **Academy Member**: {Yes/No}
- **Relevance Score**: {score}
- **Scoring**: {rationale}
{end for}

## Limits & Counts
- **Query Limit**: {maxResults} results
- **Total Matches**: {totalFound} (before limit)
- **Results Shown**: {showing}
- **Truncated**: {Yes/No} (showing top {maxResults} by relevance)

## Data (JSON)
```json
{
  "searchTerm": "{searchTerm}",
  "totalFound": {totalFound},
  "showing": {showing},
  "academyMembers": {academyCount},
  "topOU": "{topOU}",
  "results": [
    {
      "name": "{aeName}",
      "ou": "{ou}",
      "product": "{productL3}",
      "rank": {aeRank},
      "academy": {true/false},
      "score": {relevanceScore}
    }
  ]
}
```
```

---

## API Reference

### Handler API

**Class:** `ANAgentSMESearchHandlerV3`

**Method:**
```apex
@InvocableMethod(
    label='Search SMEs V3'
    description='Search for Subject Matter Experts by product or name with enhanced ranking'
)
public static List<SMESearchResponse> searchSMEs(List<SMESearchRequest> requests)
```

**Request Object:**
```apex
public class SMESearchRequest {
    @InvocableVariable(required=true)
    public String searchTerm;
    
    @InvocableVariable(required=false)
    public String searchType;  // 'product', 'name', or 'all'
    
    @InvocableVariable(required=false)
    public Integer maxResults;  // Default: 10
    
    @InvocableVariable(required=false)
    public Boolean academyMembersOnly;  // Default: false
    
    @InvocableVariable(required=false)
    public String ouName;  // e.g., 'UKI', 'AMER'
    
    @InvocableVariable(required=false)
    public Boolean useEnhancedSearch;  // Default: true
}
```

**Response Object:**
```apex
public class SMESearchResponse {
    @InvocableVariable(required=true)
    public String message;  // Complete formatted message
}
```

---

### Service API

**Class:** `ANAgentSMESearchServiceV3`

**Main Method:**
```apex
public static String searchSMEsEnhanced(
    String searchTerm,
    String searchType,
    Integer maxResults,
    Boolean academyMembersOnly,
    String ouName
)
```

**Returns:** Complete formatted message as String

**Internal Classes:**
- `SMEInfo` - Private DTO for processing
- `SMERankingComparator` - Private comparator for sorting

---

## Security Implementation

### Field-Level Security (FLS)

```apex
// After querying records
records = Security.stripInaccessible(
    AccessType.READABLE,
    records
).getRecords();
```

**What this does:**
- Removes fields user cannot read
- Prevents unauthorized data exposure
- Throws exception if object not accessible
- Enforces sharing rules

### SOQL Injection Prevention

```apex
// Step 1: Escape user input
String escapedSearchTerm = String.escapeSingleQuotes(searchTerm);

// Step 2: Build query with escaped input
String whereClause = 'WHERE PRODUCT_L3__c LIKE \'%' + escapedSearchTerm + '%\'';

// Step 3: Execute query
List<SObject> records = Database.query(query);
```

**Protected Against:**
- Single quote injection
- SOQL command injection
- Field name manipulation

---

## Error Handling

### Error Scenarios

**1. Empty Search Term**
```apex
if (String.isBlank(request.searchTerm)) {
    response.message = '# SME Search Error\n\n**Error**: Search term is required';
    return response;
}
```

**2. Query Exception**
```apex
try {
    List<SObject> records = Database.query(query);
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'SME Search Service Error: ' + e.getStackTraceString());
    return buildErrorMessage(e.getMessage());
}
```

**3. No Request Provided**
```apex
if (requests == null || requests.isEmpty()) {
    SMESearchResponse errRes = new SMESearchResponse();
    errRes.message = '# SME Search Error\n\n**Error**: No request provided.';
    return errRes;
}
```

### Error Message Format
```markdown
# SME Search Error

**Error**: [Error description]

Please check your search parameters and try again.
```

---

## Performance Optimization

### Query Optimization
1. **Selective WHERE clause** - Filters applied before ordering
2. **Indexed fields** - Uses `AE_RANK__c` in ORDER BY
3. **NULLS LAST** - Handles null values efficiently
4. **Field limit** - Only selects required fields

### Memory Optimization
1. **String building** - Incremental concatenation
2. **Limited result set** - Truncates before detailed processing
3. **No intermediate collections** - Direct mapping where possible
4. **Private inner classes** - Limited scope, garbage collected

### Governor Limits

**Per Request:**
- SOQL Queries: 1
- Query Rows: Up to 50,000 (limited by governor)
- CPU Time: ~500-1500ms (varies with result count)
- Heap Size: Minimal (<1 MB for typical searches)

**Recommendations:**
- Keep `maxResults` ≤ 50 for best performance
- Use specific `searchType` to reduce query scope
- Add `ouName` filter to reduce result set
- Enable `academyMembersOnly` when possible

---

## Customization Points

### 1. Modify Ranking Weights

**Location:** `ANAgentSMESearchServiceV3.calculateRelevanceScore()`

```apex
// Current weights:
score += sme.aeRank * 10;           // AE Rank multiplier
score += 50;                         // OU match bonus
score += 25;                         // Academy member bonus
score += 30;                         // L3 product match
score += 20;                         // L2 product match
score += 40;                         // Name match

// Customize by changing these values
```

### 2. Add New Search Type

**Location:** `ANAgentSMESearchServiceV3.buildEnhancedSearchQuery()`

```apex
if (searchType.toLowerCase() == 'department') {
    whereClause = 'WHERE DEPARTMENT__c LIKE \'%' + escapedSearchTerm + '%\'';
}
```

### 3. Modify Message Format

**Location:** `ANAgentSMESearchServiceV3.buildCompleteMessage()`

```apex
// Change sections, add new insights, modify JSON structure
message += '## Your Custom Section\n';
message += '- **Custom Field**: ' + customValue + '\n';
```

### 4. Add New Fields to Query

**Step 1:** Add to SOQL SELECT
```apex
String query = 'SELECT Id, AE_NAME__c, ..., YOUR_NEW_FIELD__c ...';
```

**Step 2:** Add to SMEInfo constructor
```apex
public SMEInfo(String id, ..., String yourNewField) {
    // ...
    this.yourNewField = yourNewField;
}
```

**Step 3:** Map in processSMERecordsWithRanking()
```apex
new SMEInfo(
    // ... existing params ...
    String.valueOf(record.get('YOUR_NEW_FIELD__c'))
);
```

**Step 4:** Include in message
```apex
message += '- **Your New Field**: ' + sme.yourNewField + '\n';
```

---

## Code Quality Standards

### Followed Patterns
- ✅ **Single Responsibility** - Each method has one clear purpose
- ✅ **DRY (Don't Repeat Yourself)** - Reusable helper methods
- ✅ **Separation of Concerns** - Handler vs Service layers
- ✅ **Defensive Programming** - Null checks, try-catch blocks
- ✅ **Named Parameters** - Clear method signatures
- ✅ **Private Visibility** - Internal classes and methods are private
- ✅ **Consistent Naming** - camelCase for methods, PascalCase for classes

### Code Metrics
- **Handler LOC:** ~110 lines
- **Service LOC:** ~320 lines
- **Cyclomatic Complexity:** Low-Medium
- **Method Length:** Average ~20 lines
- **Class Cohesion:** High (focused responsibility)

---

## Dependencies

### Required Classes
1. `ANAgentSMESearchHandlerV3` - Handler
2. `ANAgentSMESearchServiceV3` - Service

### No External Dependencies
- ✅ No third-party libraries
- ✅ No custom utilities
- ✅ No managed packages
- ✅ Uses only standard Apex

### System Dependencies
- Salesforce API v62.0 or higher
- `AGENT_SME_ACADEMIES__c` custom object
- Security model with FLS support

---

## Version Compatibility

### Salesforce API Versions
- **Minimum:** v60.0 (Winter '24)
- **Recommended:** v62.0 (Winter '25)
- **Tested On:** v62.0, v64.0

### Agentforce Compatibility
- **Minimum:** Winter '25 release
- **Tested With:** Agentforce v1.0

### Breaking Changes from V2
1. Response structure: Changed from complex DTO to single String
2. Handler logic: Removed all business logic
3. Service return type: Changed from SMESearchResult to String
4. Invocable label: Changed from "Search SMEs V2" to "Search SMEs V3"

**Migration Required:** Yes (cannot upgrade in place)

---

## Debugging

### Enable Debug Logs

```bash
# Enable debug logs for user
sf apex log tail --target-org YOUR_ORG
```

### Key Debug Statements

**In Service:**
```
System.debug('SME Search Query: ' + query);  // Shows generated SOQL
```

**In Handler:**
```
System.debug(LoggingLevel.ERROR, 'SME Search Handler Error: ' + e.getStackTraceString());
```

### Debug Log Analysis

**Look for:**
1. `SME Search Query:` - Verify SOQL is correct
2. Query execution time - Should be <2 seconds
3. Number of records returned
4. Relevance score calculations
5. Message length - Should be reasonable (2-5 KB)

**Red Flags:**
- Query execution > 5 seconds
- Governor limit warnings
- Null pointer exceptions
- "Variable does not exist" errors

---

## Testing Strategy

### Unit Testing (Coming Soon)
```apex
@isTest
private class ANAgentSMESearchHandlerV3Test {
    @isTest
    static void testBasicProductSearch() {
        // Test implementation
    }
    
    @isTest
    static void testAcademyFilter() {
        // Test implementation
    }
    
    @isTest
    static void testEmptySearchTerm() {
        // Test implementation
    }
}
```

### Integration Testing
- Deploy to sandbox
- Run with real data
- Test through Agentforce
- Verify end-to-end flow

### Performance Testing
- Query with large result sets (>1000 records)
- Measure CPU time and heap usage
- Verify no governor limit hits

---

## Maintenance

### Monthly Review
- [ ] Check for new governor limit changes
- [ ] Review debug logs for errors
- [ ] Analyze usage patterns
- [ ] Optimize ranking algorithm based on feedback
- [ ] Update documentation

### Quarterly Updates
- [ ] Review Salesforce API version compatibility
- [ ] Update to latest API version if needed
- [ ] Refactor code for new platform features
- [ ] Add new features based on user requests

---

## Reference Implementation

This V3 implementation is based on the working pattern from:
- `ANAgentOpenPipeAnalysisV3Handler` (reference for FR-style)
- GitHub repository: `qp-agent-sme-search` (original Simple version)

**Key Learnings Applied:**
1. Single message output only
2. No business logic in handler
3. Complete message building in service
4. Stable, predictable formatting
5. Security-first approach

---

**Technical Reference Version:** 1.0  
**Last Updated:** October 8, 2025  
**Maintainer:** Readiness Team
