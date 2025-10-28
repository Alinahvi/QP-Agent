# 🔮 Future Pipeline Analysis V5 - Salesforce Agent Action

## Overview
Analyzes future pipeline opportunities including RENEWALS, CROSS-SELL, and UPSELL to help prioritize revenue protection and expansion strategies across territories.

## Purpose
- Protect existing revenue (RENEWALS)
- Identify expansion opportunities (CROSS-SELL, UPSELL)
- Analyze product renewal risks
- Support territory planning and account strategy

## Files Included

### Apex Classes
- **`ABAgentFuturePipeAnalysisHandlerV5.cls`** - Handler layer (invocable method)
- **`ABAgentFuturePipeAnalysisHandlerV5.cls-meta.xml`** - Metadata
- **`ABAgentFuturePipeAnalysisServiceV5.cls`** - Service layer (business logic)
- **`ABAgentFuturePipeAnalysisServiceV5.cls-meta.xml`** - Metadata

### GenAI Function
- **`ABAGENT_Future_Pipeline_Analysis_V5/`** - GenAI Function metadata folder
  - `ABAGENT_Future_Pipeline_Analysis_V5.genAiFunction-meta.xml` - Function definition

## Salesforce Objects Used
- **`Agent_Renewals__c`** - Renewal opportunities
- **`Agent_Cross_Sell__c`** - Cross-sell opportunities
- **`Agent_Upsell__c`** - Upsell opportunities
- **`Learner_Profile__c`** - AE enrichment data

## Key Features

### ✅ Three Analysis Types
1. **RENEWALS** - Protect existing revenue, identify at-risk renewals
2. **CROSS_SELL** - Expand product footprint in existing accounts
3. **UPSELL** - Increase license counts or tier upgrades

### ✅ Flexible Input Handling
Accepts both string and proper types:
```json
{"analysisType": "RENEWALS", "summaryOnly": true, "limit": 20000}
{"analysisType": "RENEWALS", "summaryOnly": "true", "limit": "20000"}
```

### ✅ Territory Filtering
- Organizational Unit (`ouName`)
- Country (`workLocationCountry`)
- Manager Email (searches 12 management levels)
- Segment (`segment`)

### ✅ Enhanced Error Handling
All errors include:
- Error code
- Clear message
- 5+ correct examples
- Agent next steps

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `analysisType` | String | **Yes** | RENEWALS, CROSS_SELL, or UPSELL |
| `ouName` | String | No | Organizational unit (e.g., "UKI", "AMER ACC") |
| `workLocationCountry` | String | No | Country filter |
| `managerEmail` | String | No | Manager email (searches all 12 levels) |
| `segment` | String | No | Market segment (ENTR, COMM, SMB, ALL) |
| `limit` | String/Integer | No | Max records (1-40000, default: 20000) |
| `summaryOnly` | String/Boolean | No | Return summary only (default: false) |

## Output Structure

```json
{
  "ok": true,
  "data": {
    "analysisType": "RENEWALS",
    "summary": {
      "totalOpportunities": 1382,
      "totalACV": 214400000,
      "atRiskACV": 52300000,
      "topProducts": ["Service Cloud", "Sales Cloud", "Marketing Cloud"]
    },
    "records": [...],
    "productBreakdown": {...},
    "riskAnalysis": {...}
  },
  "error": null
}
```

## Example Usage

### Renewal Analysis by Territory
```json
{
  "analysisType": "RENEWALS",
  "ouName": "AMER ACC",
  "summaryOnly": "true",
  "limit": "20000"
}
```

### Cross-Sell Opportunities by Manager
```json
{
  "analysisType": "CROSS_SELL",
  "managerEmail": "lsteele@salesforce.com",
  "summaryOnly": "false",
  "limit": "10000"
}
```

### Upsell Analysis by Segment
```json
{
  "analysisType": "UPSELL",
  "segment": "ENTR",
  "workLocationCountry": "United Kingdom",
  "limit": "5000"
}
```

## Deployment

### Using Salesforce CLI
```bash
sf project deploy start \
  --source-dir ABAgentFuturePipeAnalysisHandlerV5.cls \
  --source-dir ABAgentFuturePipeAnalysisServiceV5.cls \
  --source-dir ABAGENT_Future_Pipeline_Analysis_V5 \
  --target-org <your-org-alias>
```

### Using MCP Tool
```apex
mcp_salesforce_deploy_metadata({
  "usernameOrAlias": "your-org-alias",
  "directory": "/path/to/project",
  "sourceDir": [
    "force-app/main/default/classes/ABAgentFuturePipeAnalysisHandlerV5.cls",
    "force-app/main/default/classes/ABAgentFuturePipeAnalysisServiceV5.cls",
    "force-app/main/default/genAiFunctions/ABAGENT_Future_Pipeline_Analysis_V5"
  ]
})
```

## Testing

Test with Anonymous Apex:
```apex
List<ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisRequest> requests = 
    new List<ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisRequest>();

ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisRequest req = 
    new ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisRequest();
req.analysisType = 'RENEWALS';
req.ouName = 'UKI';
req.summaryOnly = 'true';
req.limit = '5000';

requests.add(req);

List<ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisResponse> responses = 
    ABAgentFuturePipeAnalysisHandlerV5.analyzeFuturePipeline(requests);

System.debug(responses[0].result);
```

## Field Mappings

### Agent_Renewals__c Fields:
- `PRODUCT_NAME__c` - Product name
- `ACV__c` - Annual Contract Value
- `RENEWAL_DATE__c` - Expected renewal date
- `RISK_LEVEL__c` - Risk assessment
- `CONFIDENCE__c` - Renewal confidence
- `LEARNER_PROFILE_ID__c` - Link to AE

### Agent_Cross_Sell__c Fields:
- `RECOMMENDED_PRODUCT__c` - Suggested product
- `CURRENT_PRODUCTS__c` - Existing products
- `POTENTIAL_ACV__c` - Estimated value
- `OPPORTUNITY_SCORE__c` - Fit score

### Agent_Upsell__c Fields:
- `PRODUCT_NAME__c` - Current product
- `UPGRADE_PATH__c` - Recommended upgrade
- `INCREMENTAL_ACV__c` - Additional value
- `READINESS_SCORE__c` - Account readiness

## Analysis Types Explained

### RENEWALS
**Purpose:** Protect existing revenue
**Key Metrics:**
- At-risk ACV
- Renewal confidence by product
- Time to renewal
- Customer health scores

**Use Cases:**
- Identify products with low renewal confidence
- Prioritize at-risk accounts
- Plan renewal campaigns

### CROSS_SELL
**Purpose:** Expand product footprint
**Key Metrics:**
- Cross-sell potential by product
- Recommended products
- Account penetration gaps

**Use Cases:**
- Find untapped product opportunities
- Identify "lighthouse" product gaps
- Plan expansion campaigns

### UPSELL
**Purpose:** Increase account value
**Key Metrics:**
- Upsell potential by tier
- License expansion opportunities
- Usage-based growth signals

**Use Cases:**
- Identify accounts ready for upgrades
- Plan consumption growth strategies
- Prioritize expansion deals

## Version History
- **V5** (Oct 2025): Clean rebuild, flexible input, enhanced errors, no V4 references
- **V4** (Sep 2025): Manager chain support, single input parameter
- **V3** (Aug 2025): Added UPSELL analysis type
- **V2** (Jul 2025): Enhanced CROSS_SELL logic
- **V1** (Jun 2025): Initial RENEWALS analysis

## Support
For issues or questions, contact the Sales Operations team or reference:
- Test Report: `FUTUREPIPE_V5_TEST_REPORT.md`
- Migration Guide: `🏆_FINAL_V5_COMPLETE_SUMMARY.md`

---

**Status:** ✅ Production Ready | **Test Coverage:** 30/30 (100%) | **Last Updated:** Oct 27, 2025

