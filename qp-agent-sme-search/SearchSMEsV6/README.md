# SearchSMEsV6

## Overview
Find Subject Matter Experts (SMEs) based on product expertise, location, and organizational attributes with 12-level manager chain support.

## Version
**V6.0** - Released 2025-11-04

## Components

### Handler Class
- **File**: `ANAgentSMESearchHandlerV6.cls`
- **Label**: `SearchSMEsV6`
- **Type**: Invocable Method (Agent Action)
- **Purpose**: Flexible input handling and validation

### Service Class  
- **File**: `ANAgentSMESearchServiceV6.cls`
- **Type**: Business Logic Service
- **Purpose**: SME search, filtering, relevance scoring

### Metadata Files
- `ANAgentSMESearchHandlerV6.cls-meta.xml` (API Version: 60.0)
- `ANAgentSMESearchServiceV6.cls-meta.xml` (API Version: 60.0)

## Key Features

### V6 Improvements from V5
- ✅ AgentCore integration (PermissionValidator, Exception, Constants)
- ✅ 12-level manager chain support (was 5 levels)
- ✅ Better "no results" messages with org data samples
- ✅ Enhanced exception handling
- ✅ Removed FRSearchGuard/FRPermissionGuard dependencies

### Search Capabilities
- **Product Search**: PRODUCT_L2__c, PRODUCT_L3__c fields
- **Name Search**: SME person names
- **All Search**: Combined product and name search

### Filtering Options
- Academy membership (ACADEMIES_MEMBER__c)
- Organizational Unit (OU)
- Work location country
- Industry vertical
- Macro segment (ENTR, CMRCL, ESMB, PubSec)
- Employee tenure (days)
- Leave status (active/on-leave)
- Manager chain (12 hierarchy levels)

### Relevance Scoring
Smart relevance scoring based on:
- AE Rank (0-10 scale): +10 per rank point
- Academy Member: +30 points
- OU Match: +50 points
- Country Match: +25 points
- Product L3 Match: +40 points
- Product L2 Match: +30 points
- Name Match: +35 points
- Tenure Bonus: +1 per year (max +20)

## Input Parameters

### Required
- `searchTerm`: Product name or SME name (min 2 characters)

### Optional
- `searchType`: Product | Name | All (default: All)
- `limitStr`: Max results (1-200, default: 20)
- `academyMembersOnlyStr`: Filter academy members (true/false)
- `ouName`: Organizational unit filter
- `workCountry`: Country filter
- `industry`: Industry filter
- `vertical`: Segment filter (ENTR, CMRCL, ESMB, PubSec)
- `minTenureDaysStr`: Minimum tenure in days
- `managerEmail`: Manager email (searches 12 levels)
- `includeOnLeaveStr`: Include on-leave employees (default: true)
- `summaryOnlyStr`: Summary mode (default: false)

## Output Structure

```json
{
  "ok": true,
  "data": {
    "analysisType": "SME_SEARCH",
    "searchMetadata": {
      "searchTerm": "Sales Cloud",
      "searchType": "Product",
      "limitN": 20,
      "summaryOnly": false,
      "appliedFilters": {
        "ouName": "AMER ACC"
      }
    },
    "summary": {
      "totals": {
        "total_smes": 45,
        "showing": 20,
        "academy_members": 12,
        "top_ou": "AMER ACC",
        "top_country": "United States of America",
        "top_product": "Sales Cloud"
      },
      "by_ou": [...],
      "by_product": [...],
      "by_country": [...],
      "by_segment": [...]
    },
    "records": [
      {
        "learnerProfileId": "a5F...",
        "learnerProfileName": "John Smith",
        "productL3": "Sales Cloud Enterprise",
        "productL2": "Sales Cloud",
        "organizationalUnit": "AMER ACC",
        "workCountry": "United States of America",
        "macroSegment": "ENTR",
        "totalACV": 2500000,
        "aeRank": 8.5,
        "isAcademyMember": true,
        "tenureDays": 1825,
        "hireDate": "2020-01-15",
        "isOnLeave": false,
        "managerL1": "manager1@salesforce.com",
        "managerL2": "manager2@salesforce.com",
        "...": "... through managerL12",
        "relevanceScore": 165.0,
        "scoringRationale": "AE Rank +85, Academy Member +30, OU match +50"
      }
    ]
  },
  "total": 45,
  "limit": 20
}
```

## Academy Members
**What is Academy?**
A leadership program for top-performing AEs at Salesforce. Academy members are elite sellers who:
- Coach other AEs
- Create enablement content
- Help tech teams understand sales processes
- Provide product/skill enablement

These are your most experienced and willing-to-help SMEs.

## Deployment Instructions

### Prerequisites
- Access to `AGENT_SME_ACADEMIES__c`
- Read permission on `Learner_Profile__c`
- AgentCore framework
- FRPermissionGuard utility

### Deploy Order
1. Deploy Service: `ANAgentSMESearchServiceV6.cls`
2. Deploy Handler: `ANAgentSMESearchHandlerV6.cls`
3. Deploy metadata files

## Dependencies
- `AgentCore_PermissionValidator`
- `AgentCore_Exception`
- `AgentCore_Constants`
- `AGENT_SME_ACADEMIES__c`
- `Learner_Profile__c` (with 12-level manager chain fields)

## Example Usage

### Find Sales Cloud Experts
```json
{
  "searchTerm": "Sales Cloud",
  "searchType": "Product",
  "academyMembersOnlyStr": "true",
  "limitStr": "50"
}
```

### Find SMEs in AMER ACC
```json
{
  "searchTerm": "Agentforce",
  "ouName": "AMER ACC",
  "minTenureDaysStr": "730"
}
```

### Find SMEs by Manager
```json
{
  "searchTerm": "Data Cloud",
  "managerEmail": "sallen@salesforce.com"
}
```

## Known Limitations
- Requires exact product names or partial matches
- searchTerm is REQUIRED for data quality
- Manager chain search across 12 levels may be slow for large hierarchies

## Support
Contact Sales Operations Team for support.

