# 📊 Open Pipe Analysis V5 - Salesforce Agent Action

## Overview
Analyzes open pipeline (current deals in progress) to identify bottlenecks, stagnation, and areas requiring attention across territories, segments, products, and sales stages.

## Purpose
- Identify stalled opportunities by stage, product, or territory
- Pinpoint pipeline health issues (low confidence, stagnation)
- Analyze AE performance across management chains
- Support quarterly planning and territory analysis

## Files Included

### Apex Classes
- **`ANAgentOpenPipeAnalysisHandlerV5.cls`** - Handler layer (invocable method)
- **`ANAgentOpenPipeAnalysisHandlerV5.cls-meta.xml`** - Metadata
- **`ANAgentOpenPipeAnalysisServiceV5.cls`** - Service layer (business logic)
- **`ANAgentOpenPipeAnalysisServiceV5.cls-meta.xml`** - Metadata

### GenAI Function
- **`ANAGENT_Open_Pipe_Analysis_V5/`** - GenAI Function metadata folder
  - `ANAGENT_Open_Pipe_Analysis_V5.genAiFunction-meta.xml` - Function definition

## Salesforce Objects Used
- **`Agent_Open_Pipe__c`** - Main data source (open opportunities)
- **`Learner_Profile__c`** - AE enrichment data (manager chain, OU, segment, tenure)

## Key Features

### ✅ Flexible Input Handling
Accepts both string and proper types:
```json
{"summaryOnly": true, "limit": 50}
{"summaryOnly": "true", "limit": "50"}
```

### ✅ Territory Filtering
Filter by:
- Organizational Unit (`ouName`)
- Work Location Country (`workLocationCountry`)
- Manager Email (any of 12 management levels)
- Segment (`segment`)

### ✅ Product & Stage Analysis
- Product family filtering
- Sales stage analysis
- Confidence scoring
- Stagnation detection

### ✅ Enhanced Error Handling
All errors include:
- Error code
- Clear message
- 5+ correct examples
- Agent next steps

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ouName` | String | No | Organizational unit filter (e.g., "UKI", "AMER ACC") |
| `workLocationCountry` | String | No | Country filter (e.g., "United States", "United Kingdom") |
| `managerEmail` | String | No | Manager email (searches all 12 levels) |
| `segment` | String | No | Market segment (ENTR, COMM, SMB, ALL) |
| `productFamily` | String | No | Product family filter |
| `stage` | String | No | Sales stage filter |
| `limit` | String/Integer | No | Max records (1-40000, default: 20000) |
| `summaryOnly` | String/Boolean | No | Return summary only (default: false) |

## Output Structure

```json
{
  "ok": true,
  "data": {
    "summary": {
      "totalOpportunities": 1476,
      "totalACV": 176100000,
      "avgConfidence": 3.36,
      "stagnationRate": 0.42
    },
    "records": [...],
    "topProducts": [...],
    "stageBreakdown": {...}
  },
  "error": null
}
```

## Example Usage

### Basic Territory Analysis
```json
{
  "ouName": "UKI",
  "summaryOnly": "true",
  "limit": "20000"
}
```

### Manager Chain Analysis
```json
{
  "managerEmail": "sallen@salesforce.com",
  "summaryOnly": "false",
  "limit": "10000"
}
```

### Product-Specific Analysis
```json
{
  "productFamily": "Sales Cloud",
  "segment": "ENTR",
  "limit": "5000"
}
```

## Deployment

### Using Salesforce CLI
```bash
sf project deploy start \
  --source-dir ANAgentOpenPipeAnalysisHandlerV5.cls \
  --source-dir ANAgentOpenPipeAnalysisServiceV5.cls \
  --source-dir ANAGENT_Open_Pipe_Analysis_V5 \
  --target-org <your-org-alias>
```

### Using MCP Tool
```apex
mcp_salesforce_deploy_metadata({
  "usernameOrAlias": "your-org-alias",
  "directory": "/path/to/project",
  "sourceDir": [
    "force-app/main/default/classes/ANAgentOpenPipeAnalysisHandlerV5.cls",
    "force-app/main/default/classes/ANAgentOpenPipeAnalysisServiceV5.cls",
    "force-app/main/default/genAiFunctions/ANAGENT_Open_Pipe_Analysis_V5"
  ]
})
```

## Testing

Test with Anonymous Apex:
```apex
List<ANAgentOpenPipeAnalysisHandlerV5.OpenPipeAnalysisRequest> requests = 
    new List<ANAgentOpenPipeAnalysisHandlerV5.OpenPipeAnalysisRequest>();

ANAgentOpenPipeAnalysisHandlerV5.OpenPipeAnalysisRequest req = 
    new ANAgentOpenPipeAnalysisHandlerV5.OpenPipeAnalysisRequest();
req.ouName = 'UKI';
req.summaryOnly = 'true';
req.limit = '5000';

requests.add(req);

List<ANAgentOpenPipeAnalysisHandlerV5.OpenPipeAnalysisResponse> responses = 
    ANAgentOpenPipeAnalysisHandlerV5.analyzeOpenPipeline(requests);

System.debug(responses[0].result);
```

## Field Mappings

### Agent_Open_Pipe__c Fields Used:
- `OPEN_PIPE_PROD_NM__c` - Product name
- `OPEN_PIPE_APM_L2__c` - Product L2
- `STAGE__c` - Sales stage
- `CONFIDENCE__c` - Deal confidence
- `ACV__c` - Annual Contract Value
- `CLOSE_DATE__c` - Expected close date
- `LAST_ACTIVITY__c` - Last activity date
- `STAGNATION_DAYS__c` - Days stagnant
- `LEARNER_PROFILE_ID__c` - Link to AE profile

### Learner_Profile__c Fields Used:
- `OU_Name__c` - Organizational unit
- `Work_Location_Country__c` - Country
- `Macro_Segment__c` - Market segment
- `Emp_Mgt_Chain_Lvl_01_Em__c` through `Lvl_12_Em__c` - Manager chain
- `Employee_Tenure__c` - AE tenure

## Version History
- **V5** (Oct 2025): Clean rebuild with flexible input, enhanced errors, no V4 references
- **V4** (Sep 2025): Initial manager chain support, flexible boolean inputs
- **V3** (Aug 2025): Added segment filtering
- **V2** (Jul 2025): Enhanced product analysis
- **V1** (Jun 2025): Initial release

## Support
For issues or questions, contact the Sales Operations team or reference:
- Test Report: `OPENPIPE_V5_SUMMARY.md`
- Migration Guide: `🏆_FINAL_V5_COMPLETE_SUMMARY.md`

---

**Status:** ✅ Production Ready | **Test Coverage:** 5/5 (100%) | **Last Updated:** Oct 27, 2025

