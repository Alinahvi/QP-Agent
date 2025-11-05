# ABAGENT Future Pipeline Analysis V6

## Overview
Analyzes future pipeline opportunities for proactive planning across RENEWALS, CROSS_SELL, and UPSELL opportunities.

## Version
**V6.0** - Released 2025-11-03

## Components

### Handler Class
- **File**: `ABAgentFuturePipeAnalysisHandlerV6.cls`
- **Label**: `ABAGENT Future Pipeline Analysis V6`
- **Type**: Invocable Method (Agent Action)
- **Purpose**: Entry point for agent invocations with flexible input handling

### Service Class  
- **File**: `ABAgentFuturePipeAnalysisServiceV6.cls`
- **Type**: Business Logic Service
- **Purpose**: Core analysis logic, query execution, and data processing

### Metadata Files
- `ABAgentFuturePipeAnalysisHandlerV6.cls-meta.xml` (API Version: 58.0)
- `ABAgentFuturePipeAnalysisServiceV6.cls-meta.xml` (API Version: 58.0)

## Key Features

### V6 Improvements from V5
- ✅ AgentCore integration for enterprise-grade validation
- ✅ Country normalization (fixes "United States" → no data issue)
- ✅ Auto query limit handling (prevents 50K limit errors)
- ✅ Enhanced SOQL injection prevention
- ✅ Flexible input handling (string/boolean/integer conversion)

### Analysis Types
1. **RENEWALS**: Upcoming renewal opportunities with projected revenue
   - Returns dollar amounts ($USD)
   - Data Source: `Agent_Renewals__c`
   
2. **CROSS_SELL**: Additional product opportunities
   - Count only (no amounts)
   - Data Source: `Agent_Cross_Sell__c`
   
3. **UPSELL**: Usage expansion opportunities
   - Count only (no amounts)
   - Data Source: `Agent_Upsell__c`

### Territory Filtering
- **OU Name**: Filter by Organizational Unit (AMER ACC, UKI, EMEA, APAC, LATAM, ANZ)
- **Work Location Country**: Filter by geographic location
- **Manager Email**: Auto-searches ALL 12 management hierarchy levels

### Data Enrichment
- Automatic enrichment with `Learner_Profile__c` data
- 12-level manager chain support
- Country/territory attribution

### Automatic Aggregations
Returns automatic aggregations by:
- Product
- Industry
- Segment
- Country

## Input Parameters

### Required
- `analysisType`: RENEWALS | CROSS_SELL | UPSELL

### Territory Filters (at least ONE required)
- `ouName`: Organizational Unit name
- `workLocationCountry`: Country name
- `managerEmail`: Manager email (searches all 12 hierarchy levels)

### Optional Filters
- `aeName`: Specific Account Executive
- `aeIndustry`: Industry filter
- `aeMacroSegment`: Segment filter (ENTR, CMRCL, ESMB, PubSec)
- `aeManagerName`: Direct manager name
- `startDate`: Filter from date (YYYY-MM-DD)
- `endDate`: Filter to date (YYYY-MM-DD)
- `limitStr`: Max records (1-50,000, default: 20,000)
- `summaryOnlyStr`: Summary mode (true/false)

## Output Structure

### Response Fields
```json
{
  "ok": true,
  "data": {
    "analysisType": "RENEWALS|CROSS_SELL|UPSELL",
    "total": 1234,
    "limit": 20000,
    "omittedFromDetails": 0,
    "summaryOnly": false,
    "appliedFilters": "OU:AMER ACC,Country:United States",
    "summary": {
      "totals": {
        "total_amount": 5678900.50,
        "total_count": 1234,
        "average_amount": 4599.92
      },
      "by_product": [...],
      "by_industry": [...],
      "by_macrosegment": [...],
      "by_country": [...]
    },
    "records": [
      {
        "id": "a0X...",
        "pipeType": "RENEWALS",
        "learnerProfileId": "a5F...",
        "amount": 125000.00,
        "product": {
          "family": null,
          "name": "Sales Cloud",
          "sku": null
        },
        "industry": "Technology",
        "segment": "ENTR",
        "vertical": "Technology",
        "customerName": "Acme Corp"
      }
    ]
  }
}
```

## Deployment Instructions

### Prerequisites
- Access to `Agent_Renewals__c`, `Agent_Cross_Sell__c`, `Agent_Upsell__c` objects
- Read permission on `Learner_Profile__c`
- AgentCore framework classes deployed:
  - `AgentCore_Constants`
  - `AgentCore_Exception`
- FRPermissionGuard utility class

### Deployment Steps
1. Deploy Service class first: `ABAgentFuturePipeAnalysisServiceV6.cls`
2. Deploy Handler class: `ABAgentFuturePipeAnalysisHandlerV6.cls`
3. Deploy metadata files
4. Verify API version 58.0 or higher

### Testing
- Minimum coverage: 75%
- Test both detailed and summary modes
- Test all three analysis types (RENEWALS, CROSS_SELL, UPSELL)
- Test manager email filtering across hierarchy levels

## Dependencies
- `AgentCore_Constants` - Standard error codes and limits
- `AgentCore_Exception` - Typed exception handling
- `FRPermissionGuard` - Permission validation
- `Learner_Profile__c` - AE profile data
- `Agent_Renewals__c` - Renewals data
- `Agent_Cross_Sell__c` - Cross-sell data
- `Agent_Upsell__c` - Upsell data

## Error Handling
Returns structured JSON errors with:
- Error code (INVALID_INPUT, QUERY_ERROR, SECURITY_ERROR, UNEXPECTED_ERROR)
- Detailed message
- Field information
- Correct examples
- Agent next steps for self-correction

## Example Usage

### Basic Renewals Analysis
```json
{
  "analysisType": "RENEWALS",
  "ouName": "AMER ACC",
  "limitStr": "20000"
}
```

### Manager-based Cross-Sell
```json
{
  "analysisType": "CROSS_SELL",
  "managerEmail": "sallen@salesforce.com",
  "summaryOnlyStr": "true"
}
```

### Country-filtered Upsell
```json
{
  "analysisType": "UPSELL",
  "workLocationCountry": "United Kingdom",
  "limitStr": "10000"
}
```

## Known Limitations
- CROSS_SELL and UPSELL do not have amount fields (count only)
- Manager email search limited to 50,000 team members
- Detailed mode capped at 200 records for agent display
- Response size limited to ~1 MB

## Support
For issues or questions, contact Sales Operations Team.

