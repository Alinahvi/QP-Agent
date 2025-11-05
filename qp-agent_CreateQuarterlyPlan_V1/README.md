# ANAGENT Create Quarterly Plan V1

## Overview
Creates quarterly enablement plans with parent Quarterly_Planning__c record and child Enablement_Solutions__c records based on pipeline analysis.

## Version
**V1.0** - Released 2025-10-22

## Components

### Handler Class
- **File**: `ANAgentPlanningHandlerV1.cls`
- **Label**: `ANAGENT Create Quarterly Plan V1`
- **Type**: Invocable Method (Agent Action)
- **Purpose**: Validates inputs and routes to service

### Service Class  
- **File**: `ANAgentPlanningServiceV1.cls`
- **Type**: Business Logic Service
- **Purpose**: Creates plan records with transaction safety

### Metadata Files
- `ANAgentPlanningHandlerV1.cls-meta.xml` (API Version: 62.0)
- `ANAgentPlanningServiceV1.cls-meta.xml` (API Version: 62.0)

## Key Features

### Record Creation
Creates 3 types of records:
1. **Quarterly_Planning__c**: Parent plan record
2. **Agent_OU_Quarterly_Plan__c**: Metrics/aggregation record
3. **Enablement_Solutions__c**: Individual recommendations (5+ records)

### Status Management
- **Initial Status**: Draft/Planned/Inactive
- **After Review**: Active/Approved (via separate activation action)
- **Transaction Safety**: All-or-nothing with savepoint rollback

### Data Integration
Pulls metrics from:
- Future Pipeline Analysis (RENEWALS, CROSS_SELL, UPSELL)
- Open Pipeline Analysis (current deals, stagnation)
- Program Search (matched programs for recommendations)

## Input Parameters

### Required
- `ouName`: Organizational Unit (AMER ACC, UKI, APAC, etc.)
- `macroSegment`: ENTR | CMRCL | ESMB | PubSec
- `fiscalQuarter`: Q1 | Q2 | Q3 | Q4
- `fiscalYear`: FY 2024 | FY 2025 | FY 2026 | FY 2027
- `globalRegion`: AMER | EMEA | APAC | LATAM
- `analysisDataJson`: Combined pipeline analysis JSON
- `recommendationsJson`: Array of 5 recommendation objects
- `ebpType`: CSG | Sales & Solutions (controls OU picklist)

### Optional
- `primaryIndustry`: Most common industry from analysis
- `planOwnerUserId`: 18-char Salesforce User ID (defaults to current user)
- `leaderUserId`: 18-char Salesforce User ID
- `businessPriority`: Priority 1-5 strategic focus
- `quarterTiming`: Fiscal Year | Fiscal Quarter
- `templateFlag`: Boolean (default: false)

## Analysis Data JSON Structure

### Required Format
```json
{
  "renewals": {
    "totals": {
      "total_amount": 5678900.50,
      "count": 1234
    }
  },
  "cross_sell": {
    "totals": {
      "count": 456
    }
  },
  "upsell": {
    "totals": {
      "count": 789
    }
  },
  "open_pipeline": {
    "totals": {
      "sum": 12345678.90,
      "count": 3456,
      "avg_stagnation": 28.5,
      "avg_ae_score": 2.9
    }
  }
}
```

### Source Actions
1. Run `ABAGENT Future Pipeline Analysis V6` three times:
   - analysisType=RENEWALS
   - analysisType=CROSS_SELL
   - analysisType=UPSELL

2. Run `ANAGENT Open Pipeline Analysis V6` once

3. Combine results into above JSON structure

## Recommendations JSON Structure

### Required Fields Per Recommendation
```json
[
  {
    "program_name": "Service Cloud Renewal Mastery",
    "enablement_type": "Product",
    "product_l1__c": "Service Cloud",
    "product_l2__c": "Service Cloud - Core",
    "segment": "Enterprise",
    "of_learners__c": 87,
    "delivery_date__c": "2025-03-15",
    "end_date__c": "2025-03-15",
    "additional_details__c": "Addresses renewal risk in Service Cloud ($16.2M). Low AE confidence (2.9/5). Targets 87 learners.",
    "businesspriority__c": "Priority 2: ACV growth (sales plays, Signature Success)",
    "severity": "HIGH",
    "industry_l1__c": "Technology",
    "industry_l2__c": "Software",
    "ge_program_menu_item__c": "a0X..." (if found from SearchProgramsV6),
    "regional_program_menu_item__c": "a0Y..." (if regional program)
  }
]
```

### Critical Field Requirements

**enablement_type** (case-sensitive):
- Do My Job
- Industry
- Product
- Skills

**segment** (case-sensitive):
- Enterprise (for ENTR)
- Commercial (for CMRCL)
- SMB (for ESMB)
- ECS
- CSG
- Field AE
- Leader
- Sales Dev
- Solutions
- Specialist

**product_l1__c** (exact picklist values):
- Sales Cloud, Service Cloud, Marketing Cloud
- Slack, Salesforce Platform, MuleSoft
- Customer Data Cloud, Commerce Cloud
- Health Cloud, Financial Services Cloud
- Manufacturing Cloud, and more...

**businesspriority__c** (exact format with prefix):
- Priority 1: High Performance Culture
- Priority 2: ACV growth (sales plays, Signature Success)
- Priority 3: Field success (participation/ DMJ/ skills)
- Priority 4: Big Deal motion
- Priority 5: Customer Success (Industry, Product...)

**severity**:
- CRITICAL → Priority: Locally Required
- HIGH → Priority: Locally Recommended
- MEDIUM → Priority: Locally Recommended
- LOW → Priority: Locally Recommended

**of_learners__c**:
- Must be positive number
- Count of learnerProfileIds from analysis with this specific gap

**Dates**:
- Format: YYYY-MM-DD (ISO 8601)
- delivery_date__c: When program will be delivered
- end_date__c: Same as delivery for single-day

**additional_details__c**:
- Max 255 characters
- Rationale explaining gap and impact

## Output Structure

```json
{
  "success": true,
  "quarterlyPlanningId": "a4h...",
  "agentOuPlanId": "a4i...",
  "enablementSolutionIds": "a4j...,a4k...,a4l...,a4m...,a4n...",
  "totalRecordsCreated": 7,
  "message": "Successfully created quarterly plan AMER ACC Q2 FY 2025 Enablement Plan with 5 enablement solutions",
  "errorDetails": null
}
```

## Workflow

### Phase 1: Analysis
1. Run ABAGENT Future Pipeline Analysis V6 (RENEWALS)
2. Run ABAGENT Future Pipeline Analysis V6 (CROSS_SELL)
3. Run ABAGENT Future Pipeline Analysis V6 (UPSELL)
4. Run ANAGENT Open Pipeline Analysis V6
5. Combine results into analysisDataJson

### Phase 2: Recommendations
1. Run SearchProgramsV6 for each identified gap
2. Match programs to gaps
3. Build recommendations array with all required fields
4. Ensure 5 recommendations minimum

### Phase 3: Plan Creation
1. Call ANAGENT Create Quarterly Plan V1
2. Review created Draft records
3. Use separate activation action to promote to Active/Approved

## Deployment Instructions

### Prerequisites
- Access to `Quarterly_Planning__c` (Create permission)
- Access to `Agent_OU_Quarterly_Plan__c` (Create permission)
- Access to `Enablement_Solutions__c` (Create permission)
- Default Scrum Team ID: a4fHu000001d54cIAA
- Default Product Tag ID: a4SHu000004cT5QMAU

### Deploy Order
1. Deploy Service: `ANAgentPlanningServiceV1.cls`
2. Deploy Handler: `ANAgentPlanningHandlerV1.cls`
3. Deploy metadata files
4. Configure default IDs if different

## Dependencies
- `Quarterly_Planning__c`
- `Agent_OU_Quarterly_Plan__c`
- `Enablement_Solutions__c`
- `Product_Catalog__c` (for program links)
- `Regional_Programs__c` (for regional program links)

## Validation Rules

### Quarterly_Planning__c
- Must have unique combination of: OU + Fiscal Quarter + Fiscal Year
- Name format: "{OU} {Quarter} {Year} Enablement Plan"

### Enablement_Solutions__c
- Must link to Quarterly_Planning__c (Master-Detail)
- Must have valid Scrum Team and Product Tag
- Status must be valid picklist value
- Segment must be valid value for record type

### Recommendations
- Each must have program_name, enablement_type, segment
- Each must have of_learners__c > 0
- Each must have delivery_date__c and end_date__c in YYYY-MM-DD format
- additional_details__c max 255 characters

## Common Errors

### Invalid Picklist Values
**Problem**: Field value not in picklist
**Solution**: Use exact values from README requirements

### Missing Required Fields
**Problem**: Recommendation missing critical field
**Solution**: Include all 10 required fields per recommendation

### Invalid Date Format
**Problem**: Date in MM/DD/YYYY format
**Solution**: Use YYYY-MM-DD format

### Negative Learner Count
**Problem**: of_learners__c <= 0
**Solution**: Use actual count from analysis (must be > 0)

## Support
Contact Sales Operations Team for support.

