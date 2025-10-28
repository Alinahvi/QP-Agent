# 👥 Search SMEs V5 - Salesforce Agent Action

## Overview
Searches Subject Matter Experts (SMEs) by product expertise or name to connect AEs with internal product specialists and academy members.

## Purpose
- Find product experts by expertise area
- Discover academy members
- Connect AEs with SME resources
- Support cross-functional collaboration

## Files Included

### Apex Classes
- **`ANAgentSMESearchHandlerV5.cls`** - Handler layer (invocable method)
- **`ANAgentSMESearchHandlerV5.cls-meta.xml`** - Metadata
- **`ANAgentSMESearchServiceV5.cls`** - Service layer (business logic)
- **`ANAgentSMESearchServiceV5.cls-meta.xml`** - Metadata

### GenAI Function
- **`SearchSMEsV5/`** - GenAI Function metadata folder
  - `SearchSMEsV5.genAiFunction-meta.xml` - Function definition

## Salesforce Objects Used
- **`AGENT_SME_ACADEMIES__c`** - SME expertise and academy membership data
- **`Learner_Profile__c`** - SME profile enrichment (OU, tenure, manager chain)

## Key Features

### ✅ Three Search Types
1. **Product** - Search by product expertise (PRODUCT_L2__c, PRODUCT_L3__c)
2. **Name** - Search by SME name
3. **All** - Search across both product and name fields

### ✅ Flexible Input Handling
Accepts both string and proper types:
```json
{"searchTerm": "Data Cloud", "searchType": "Product", "limit": 50}
{"searchTerm": "Data Cloud", "searchType": "Product", "limit": "50"}
```

### ✅ Academy Filtering
- Filter by academy members only
- Include/exclude non-academy SMEs
- Useful for finding certified experts

### ✅ Tenure Filtering
- Minimum tenure requirement (days)
- Filter experienced vs. new SMEs
- Support expertise-based searches

### ✅ Enhanced Error Handling
All errors include:
- Error code
- Clear message
- 5+ correct examples
- Agent next steps

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `searchTerm` | String | **Yes** | Product/name keyword (min 2 chars) |
| `searchType` | String | No | Product, Name, or All (default: All) |
| `academyMembersOnly` | String/Boolean | No | Filter academy members (default: false) |
| `minTenureDays` | String/Integer | No | Minimum tenure in days |
| `includeOnLeave` | String/Boolean | No | Include on-leave SMEs (default: false) |
| `limitValue` | String/Integer | No | Max results (1-200, default: 50) |
| `summaryOnly` | String/Boolean | No | Return summary only (default: false) |

## Output Structure

```json
{
  "ok": true,
  "data": {
    "searchType": "Product",
    "summary": {
      "totalSMEs": 25,
      "academyMembers": 18,
      "avgTenure": 1247,
      "topProducts": ["Data Cloud", "Einstein AI"]
    },
    "records": [
      {
        "id": "a0GHu000017Y6WoMAK",
        "name": "SME-12345",
        "learnerProfileName": "John Smith",
        "organizationalUnit": "AMER ACC",
        "workCountry": "United States",
        "productL2": "Data Cloud",
        "productL3": "Data Cloud Core",
        "academyMember": "Yes",
        "aeRank": 4.5,
        "totalACV": 2500000,
        "tenureDays": 1456,
        "managerL1": "Jane Doe"
      }
    ]
  },
  "error": null
}
```

## Example Usage

### Find Product Experts
```json
{
  "searchTerm": "Data Cloud",
  "searchType": "Product",
  "academyMembersOnly": "true",
  "limit": "50"
}
```

### Search by Name
```json
{
  "searchTerm": "Smith",
  "searchType": "Name",
  "limit": "20"
}
```

### Find Experienced SMEs
```json
{
  "searchTerm": "Agentforce",
  "searchType": "Product",
  "minTenureDays": "365",
  "limit": "30"
}
```

### Comprehensive Search
```json
{
  "searchTerm": "Sales Cloud",
  "searchType": "All",
  "academyMembersOnly": "false",
  "includeOnLeave": "false"
}
```

## Deployment

### Using Salesforce CLI
```bash
sf project deploy start \
  --source-dir ANAgentSMESearchHandlerV5.cls \
  --source-dir ANAgentSMESearchServiceV5.cls \
  --source-dir SearchSMEsV5 \
  --target-org <your-org-alias>
```

### Using MCP Tool
```apex
mcp_salesforce_deploy_metadata({
  "usernameOrAlias": "your-org-alias",
  "directory": "/path/to/project",
  "sourceDir": [
    "force-app/main/default/classes/ANAgentSMESearchHandlerV5.cls",
    "force-app/main/default/classes/ANAgentSMESearchServiceV5.cls",
    "force-app/main/default/genAiFunctions/SearchSMEsV5"
  ]
})
```

## Testing

Test with Anonymous Apex:
```apex
List<ANAgentSMESearchHandlerV5.SMESearchRequest> requests = 
    new List<ANAgentSMESearchHandlerV5.SMESearchRequest>();

ANAgentSMESearchHandlerV5.SMESearchRequest req = 
    new ANAgentSMESearchHandlerV5.SMESearchRequest();
req.searchTerm = 'Data Cloud';
req.searchType = 'Product';
req.academyMembersOnly = 'true';
req.limitValue = '50';

requests.add(req);

List<ANAgentSMESearchHandlerV5.SMESearchResponse> responses = 
    ANAgentSMESearchHandlerV5.searchSMEs(requests);

System.debug(responses[0].result);
```

## Field Mappings

### AGENT_SME_ACADEMIES__c Fields:
- `Name` - SME ID
- `ACADEMIES_MEMBER__c` - Academy membership flag
- `AE_RANK__c` - Performance ranking
- `PRODUCT_L2__c` - Product level 2 expertise
- `PRODUCT_L3__c` - Product level 3 expertise
- `TOTAL_ACV__c` - Total ACV value
- `LEARNER_PROFILE_ID__c` - Link to Learner Profile
- `CreatedDate` - Record creation
- `LastModifiedDate` - Last update

### Learner_Profile__c Enrichment Fields:
- `Name` - SME full name
- `OU_Name__c` - Organizational unit
- `Work_Location_Country__c` - Work country
- `Macro_Segment__c` - Market segment
- `em_Industry__c` - Industry focus
- `Employee_Tenure__c` - Tenure in days
- `Employee_on_Leave__c` - On leave status
- `Hire_Date__c` - Hire date
- `Primary_Email__c` - Contact email
- `Emp_Mgt_Chain_Lvl_01_Nm__c` through `Lvl_12_Nm__c` - Manager hierarchy

## Search Types Explained

### Product Search
**Searches:** `PRODUCT_L2__c` and `PRODUCT_L3__c` fields

**Use Cases:**
- "Find Data Cloud experts"
- "Who knows Agentforce?"
- "Sales Cloud SMEs"

**Returns:** SMEs with matching product expertise

### Name Search
**Searches:** Learner Profile `Name` field

**Use Cases:**
- "Find John Smith"
- "Search for experts named Sarah"
- "Locate SME Johnson"

**Returns:** SMEs with matching names

### All Search
**Searches:** Both product expertise AND name fields

**Use Cases:**
- "Find anything related to Tableau"
- "Search all for Einstein"
- "Comprehensive AI expert search"

**Returns:** SMEs matching in either product or name

## Filtering Options

### Academy Members Only
```json
{"academyMembersOnly": "true"}
```
**Purpose:** Find certified/academy SMEs
**Use Case:** Need validated product experts

### Minimum Tenure
```json
{"minTenureDays": "365"}
```
**Purpose:** Find experienced SMEs (1 year+)
**Use Case:** Complex technical questions

### Include On Leave
```json
{"includeOnLeave": "true"}
```
**Purpose:** Include unavailable SMEs
**Use Case:** Planning future connections

## Common Use Cases

### 1. Find Product Expert for Customer Call
```json
{
  "searchTerm": "Data Cloud",
  "searchType": "Product",
  "academyMembersOnly": "true",
  "minTenureDays": "180",
  "limit": "10"
}
```

### 2. Build SME Network for Territory
```json
{
  "searchTerm": "Sales Cloud",
  "searchType": "Product",
  "limit": "50",
  "summaryOnly": "false"
}
```

### 3. Find Specific Expert
```json
{
  "searchTerm": "Smith",
  "searchType": "Name",
  "limit": "20"
}
```

### 4. Discover All Agentforce Experts
```json
{
  "searchTerm": "Agentforce",
  "searchType": "All",
  "academyMembersOnly": "false",
  "limit": "100"
}
```

## Response Enrichment

Each SME record includes:
- ✅ **Core Data:** Name, ID, products
- ✅ **Academy Status:** Member/non-member
- ✅ **Performance:** AE rank, Total ACV
- ✅ **Profile:** OU, country, segment, industry
- ✅ **Experience:** Tenure days, hire date
- ✅ **Availability:** On leave status
- ✅ **Management:** Manager chain (L1-L12)

## Data Quality Notes

- **No date filtering:** SME discovery doesn't filter by date ranges
- **All non-deleted records:** Searches all active SME records
- **Enrichment depends on LP linkage:** Profile data requires valid `LEARNER_PROFILE_ID__c`
- **Product fields optional:** Not all SMEs have product expertise populated

## Version History
- **V5** (Oct 2025): Clean rebuild, flexible input, enhanced errors, no V4 references
- **V4** (Sep 2025): Added flexible boolean inputs, backward compatibility
- **V3** (Aug 2025): Added academy filtering
- **V2** (Jul 2025): Enhanced name search
- **V1** (Jun 2025): Initial product search only

## Support
For issues or questions, contact the Sales Operations team or reference:
- Test Report: `SMESEARCH_V5_FINAL_TEST_REPORT.md`
- Migration Guide: `🏆_FINAL_V5_COMPLETE_SUMMARY.md`

---

**Status:** ✅ Production Ready | **Test Coverage:** 30/30 (100%) | **Last Updated:** Oct 27, 2025

