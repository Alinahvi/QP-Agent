# 📚 Search Programs V5 - Salesforce Agent Action

## Overview
Searches Product Catalog (172 global programs) and Regional Programs (861 local programs) to find enablement programs, training sessions, and learning opportunities.

## Purpose
- Discover global standardized programs
- Find regional/local enablement initiatives
- Support quarterly planning
- Enable territory-specific learning

## Files Included

### Apex Classes
- **`ANAgentProgramSearchHandlerV5.cls`** - Handler layer (invocable method)
- **`ANAgentProgramSearchHandlerV5.cls-meta.xml`** - Metadata
- **`ANAgentProgramSearchServiceV5.cls`** - Service layer (business logic)
- **`ANAgentProgramSearchServiceV5.cls-meta.xml`** - Metadata

### GenAI Function
- **`SearchProgramsV5/`** - GenAI Function metadata folder
  - `SearchProgramsV5.genAiFunction-meta.xml` - Function definition

## Salesforce Objects Used
- **`Product_Catalog__c`** - Global programs (172 active)
- **`Regional_Programs__c`** - Regional programs (861 total)
- **`Enablement_Solutions__c`** - Usage metrics

## Key Features

### ✅ Dual Catalog Search
1. **GLOBAL** - Enterprise standardized programs (172)
2. **REGIONAL** - Localized initiatives (861)
3. **BOTH** - Search across all catalogs

### ✅ Flexible Input Handling
Accepts both string and proper types:
```json
{"searchTerm": "Agentforce", "programType": "BOTH", "limit": 50}
{"searchTerm": "Agentforce", "programType": "BOTH", "limit": "50"}
```

### ✅ **NEW: Optional searchTerm** 🎉
Browse programs by filters only (no keyword needed):
```json
{"programType": "GLOBAL", "enablementType": "PRODUCT", "limit": "50"}
```

### ✅ Smart Search Preprocessing
- Synonym expansion ("soft skills" → Skills)
- Acronym expansion (DC → Data Cloud)
- Duration extraction ("30 minutes" → sets minHours/maxHours)
- Region detection ("EMEA programs")

### ✅ Rich Filtering
- Enablement type (PRODUCT, SKILLS, INDUSTRY, DO_MY_JOB)
- Target level (BEGINNER, INTERMEDIATE, ADVANCED)
- Target role (AE, SE, BDR, SDR, CSM)
- Session type (VIRTUAL, PHYSICAL, HYBRID)
- Duration ranges
- Business priority
- Fiscal quarter/year
- Global region

### ✅ Usage Metrics
- Enrollment count
- Total learners
- Recent usage (90 days)
- Last scheduled date
- Avg learners per instance

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `searchTerm` | String | **No** ⭐ | Program name/keyword (min 2 chars) - **NOW OPTIONAL!** |
| `programType` | String | **Yes** | GLOBAL, REGIONAL, or BOTH |
| `enablementType` | String | No | PRODUCT, SKILLS, INDUSTRY, DO_MY_JOB, ALL |
| `targetLevel` | String | No | BEGINNER, INTERMEDIATE, ADVANCED, EXPERT, ALL |
| `targetRole` | String | No | AE, SE, BDR, SDR, SALES_MANAGER, LEADER, CSM, ALL |
| `fiscalQuarter` | String | No | Q1, Q2, Q3, Q4 (requires fiscalYear) |
| `fiscalYear` | String | No | FY 2024, FY 2025, FY 2026 |
| `globalRegion` | String | No | GLOBAL, AMER, EMEA, APAC, LATAM, JAPAN, ALL |
| `sessionType` | String | No | VIRTUAL, PHYSICAL, HYBRID, ALL (Regional only) |
| `businessPriority` | String | No | Strategic priority keyword |
| `minHoursRequired` | Decimal | No | Minimum duration (hours) |
| `maxHoursRequired` | Decimal | No | Maximum duration (hours) |
| `sortBy` | String | No | TITLE, USAGE, RECENT, DATE, DEFAULT |
| `sortOrder` | String | No | ASC, DESC (default: DESC) |
| `limit` | String/Integer | No | Max results per catalog (1-100, default: 50) |
| `includeUsageMetrics` | String/Boolean | No | Add usage data (default: true) |
| `includeArchived` | String/Boolean | No | Include archived (default: false) |

## Output Structure

```json
{
  "ok": true,
  "data": {
    "catalogType": "BOTH",
    "searchTerm": "Agentforce",
    "summary": {
      "totalPrograms": 25,
      "globalCount": 8,
      "regionalCount": 17,
      "avgDuration": 2.5,
      "topProducts": ["Agentforce", "Sales Cloud"],
      "topSkills": ["AI Selling", "Product Knowledge"]
    },
    "records": [...],
    "includeUsageMetrics": true
  },
  "error": null
}
```

## Example Usage

### Search with Keyword
```json
{
  "searchTerm": "Agentforce",
  "programType": "BOTH",
  "limit": "50"
}
```

### ⭐ Browse by Filters (NEW - No Search Term!)
```json
{
  "programType": "GLOBAL",
  "enablementType": "PRODUCT",
  "targetRole": "AE",
  "limit": "50"
}
```

### Find Short Programs
```json
{
  "searchTerm": "Tableau",
  "programType": "GLOBAL",
  "maxHoursRequired": 1.0
}
```

### Regional Virtual Programs
```json
{
  "searchTerm": "",
  "programType": "REGIONAL",
  "sessionType": "VIRTUAL",
  "globalRegion": "EMEA"
}
```

### Quarterly Plan Search
```json
{
  "searchTerm": "Data Cloud",
  "programType": "BOTH",
  "fiscalQuarter": "Q2",
  "fiscalYear": "FY 2026"
}
```

## Deployment

### Using Salesforce CLI
```bash
sf project deploy start \
  --source-dir ANAgentProgramSearchHandlerV5.cls \
  --source-dir ANAgentProgramSearchServiceV5.cls \
  --source-dir SearchProgramsV5 \
  --target-org <your-org-alias>
```

## Testing

Test with Anonymous Apex:
```apex
List<ANAgentProgramSearchHandlerV5.ProgramSearchRequest> requests = 
    new List<ANAgentProgramSearchHandlerV5.ProgramSearchRequest>();

ANAgentProgramSearchHandlerV5.ProgramSearchRequest req = 
    new ANAgentProgramSearchHandlerV5.ProgramSearchRequest();
req.searchTerm = 'Agentforce'; // Optional!
req.programType = 'BOTH';
req.limitStr = '50';

requests.add(req);

List<ANAgentProgramSearchHandlerV5.ProgramSearchResponse> responses = 
    ANAgentProgramSearchHandlerV5.searchPrograms(requests);

System.debug(responses[0].result);
```

## Field Mappings

### Product_Catalog__c (Global):
- `Course_Asset_Title__c` - Program title
- `Description__c` - Program description
- `Enablement_Type__c` - Category (multi-select)
- `Level__c` - Difficulty level
- `Role__c` - Target roles (multi-select)
- `L1_Cloud_Product__c`, `L2_Product_Line__c`, `L3_Product_Family__c` - Products
- `Excellence_Skill__c`, `Excellence_Competency__c` - Skills
- `Total_Learner_Time_Investment__c` - Duration
- `Regions__c` - Target regions
- `Business_Priority__c` - Strategic priority
- `Program_Menu_Item_Health__c` - Status

### Regional_Programs__c:
- `Regional_Program_Name__c` - Program title
- `Enablement_Type__c` - Category (single-select)
- `Session_Type__c` - Delivery format
- `Hours__c` - Duration
- `Business_Priority__c` - Strategic priority
- `Fast_Start__c` - Fast Start program flag

## Catalog Differences

| Feature | Global Programs | Regional Programs |
|---------|----------------|-------------------|
| **Count** | 172 active | 861 total |
| **Status Field** | ✅ Yes | ❌ No (all non-deleted shown) |
| **Description** | ✅ 56% populated | ❌ No description field |
| **Level** | ✅ 76% populated | ❌ No level field |
| **Role** | ✅ 74% populated | ❌ No role field |
| **Products** | ✅ 24% populated | ❌ No product fields |
| **Skills** | ✅ 50% populated | ❌ No skill fields |
| **Session Type** | ❌ No session type | ✅ 90% populated |
| **Business Priority** | 🟡 Varies | ✅ 100% populated |

## Smart Search Examples

### Synonym Expansion
- "soft skills" → Searches `Enablement_Type__c = 'Skills'`
- "DC" → Expands to "Data Cloud"
- "AF" → Expands to "Agentforce"

### Duration Extraction
- "30 minute programs" → Sets `maxHours = 0.5`
- "under 2 hours" → Sets `maxHours = 2`
- "lunch and learn" → Sets `minHours = 0.5, maxHours = 1.5`

### Region Detection
- "EMEA programs" → Sets `globalRegion = 'EMEA'`
- "APAC training" → Sets `globalRegion = 'APAC'`

## Version History
- **V5.1** (Oct 2025): **⭐ searchTerm now OPTIONAL!** Browse by filters only.
- **V5.0** (Oct 2025): Clean rebuild, flexible input, enhanced errors, no V4 references
- **V4** (Sep 2025): Added flexible boolean inputs, backward compatibility
- **V3** (Aug 2025): Enhanced smart search preprocessing
- **V2** (Jul 2025): Added usage metrics
- **V1** (Jun 2025): Initial release

## Support
For issues or questions, contact the Sales Operations team or reference:
- Test Report: `PROGRAMSEARCH_V5_FINAL_TEST_REPORT.md`
- Optional Search Term: `SEARCHPROGRAMSV5_OPTIONAL_SEARCHTERM_COMPLETE.md`
- Migration Guide: `🏆_FINAL_V5_COMPLETE_SUMMARY.md`

---

**Status:** ✅ Production Ready | **Test Coverage:** 30/30 (100%) | **Last Updated:** Oct 27, 2025
**New Feature:** ⭐ searchTerm is now OPTIONAL for filter-only browsing!

