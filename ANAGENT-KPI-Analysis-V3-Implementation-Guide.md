# ANAGENT KPI Analysis V3 Implementation Guide

## Overview

The ANAGENT KPI Analysis V3 system provides a comprehensive solution for analyzing and comparing KPIs across Account Executives (AEs), Operating Units (OUs), industries, and geographies. This system follows the established "thin service, invocable handler" pattern for clean separation of concerns.

## Architecture

### Class Structure
- **ANAGENTKPIAnalysisServiceV3**: Service layer containing business logic and direct object manipulation
- **ANAGENTKPIAnalysisHandlerV3**: Handler layer providing invocable entry points for Salesforce Flows and GenAI functions

### Data Model
- **Primary Object**: `AGENT_OU_PIPELINE_V2__c`
- **Key Fields**: Employee ID, Name, Email, OU, Industry, Performance Metrics
- **KPI Categories**: Current Quarter (CQ), Previous Quarter (PQ), Ramp Status, Productivity Metrics

## Supported Actions

### 1. Search
Search for KPI records by name, email, or OU with optional filters.

**Handler Action**: `Search`

**Example Use Cases**:
- Find AEs in specific OU with performance criteria
- Search by manager name or industry
- Filter by ramp status or tenure

### 2. Count Field Values
Aggregate counts by a specific field value.

**Handler Action**: `CountFieldValues`

**Example Use Cases**:
- Count AEs by ramp status in a region
- Aggregate by industry within an OU
- Count performance tiers

### 3. Get Distinct Field Values
Retrieve unique values for any filterable field.

**Handler Action**: `GetDistinctFieldValues`

**Example Use Cases**:
- Populate dropdown lists
- Get available filter options
- Validate input values

### 4. Get Searchable Fields
Retrieve metadata about available filter fields.

**Handler Action**: `GetSearchableFields`

**Example Use Cases**:
- Dynamic UI generation
- Field documentation
- Filter discovery

## Field Reference

### Required Filters (At Least One Must Be Provided)
| Field Label | API Name | Description |
|-------------|----------|-------------|
| OU Name | `OU_NAME__c` | Operating Unit name (e.g., "AMER - FINS") |
| Work Location Country | `WORK_LOCATION_COUNTRY__c` | Country of primary work location |

### Optional Filters
| Field Label | API Name | Description |
|-------------|----------|-------------|
| Primary Industry | `PRIMARY_INDUSTRY__c` | Top-level industry classification |
| Emp Manager Name | `EMP_MGR_NM__c` | Direct manager's name |
| Ramp Status | `RAMP_STATUS__c` | Performance category (Fast Ramper, On Track, etc.) |
| Time Since Onboarding | `TIME_SINCE_ONBOARDING__c` | Tenure in months |
| Val Quota | `VAL_QUOTA__c` | Quota value for the AE |
| Coverage | `COVERAGE__c` | Ratio of open deals to quota |
| ACV Threshold | `ACV_THRESHOLD__c` | ACV threshold based on peer characteristics |
| Days to Productivity | `DAYS_TO_PRODUCTIVITY__c` | Days to meet peer ACV attainment |

### Current Quarter (CQ) Metrics
| Field Label | API Name | Description |
|-------------|----------|-------------|
| CQ Customer Meeting | `CQ_CUSTOMER_MEETING__c` | Customer meetings this quarter |
| CQ PG | `CQ_PG__c` | Pipeline generated this quarter |
| CQ ACV | `CQ_ACV__c` | ACV generated this quarter |
| CQ Call Connect | `CQ_CALL_CONNECT__c` | Call connects this quarter |
| CQ CC ACV | `CQ_CC_ACV__c` | Create & Close ACV this quarter |

### Previous Quarter (PQ) Metrics
| Field Label | API Name | Description |
|-------------|----------|-------------|
| PQ Customer Meeting | `PQ_CUSTOMER_MEETING__c` | Customer meetings last quarter |
| PQ PG | `PQ_PG__c` | Pipeline generated last quarter |
| PQ ACV | `PQ_ACV__c` | ACV generated last quarter |
| PQ Call Connect | `PQ_CALL_CONNECT__c` | Call connects last quarter |
| PQ CC ACV | `PQ_CC_ACV__c` | Create & Close ACV last quarter |

### Additional Metrics
| Field Label | API Name | Description |
|-------------|----------|-------------|
| AOV | `AOV__c` | Average Order Value |
| Call AI Mention | `CALL_AI_MENTION__c` | AI mentions in customer calls |

## Usage Examples

### Example 1: Search AEs in Financial Services
```apex
ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
req.action = 'Search';
req.OuName = 'AMER - FINS';
req.PrimaryIndustry = 'Financial Services';
req.RampStatus = 'Fast Ramper';

List<ANAGENTKPIAnalysisHandlerV3.Response> responses = 
    ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
```

### Example 2: Count AEs by Ramp Status
```apex
ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
req.action = 'CountFieldValues';
req.countValuesForField = 'RAMP_STATUS__c';
req.WorkLocationCountry = 'USA';

List<ANAGENTKPIAnalysisHandlerV3.Response> responses = 
    ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
```

### Example 3: Get Available Industries
```apex
ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
req.action = 'GetDistinctFieldValues';
req.fieldNameForValues = 'Primary Industry';

List<ANAGENTKPIAnalysisHandlerV3.Response> responses = 
    ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
```

## Sample Agent Utterances

The system supports natural language queries through the following patterns:

### Performance Analysis
- "Show me all AEs in AMER – FINS with the highest coverage this quarter."
- "Find AEs in Japan with coverage greater than 3 and more than 20 customer meetings this quarter."
- "In US for HLS, which AEs are Fast Ramper vs Slow Ramper with their Days to Productivity?"

### Comparative Analysis
- "For UKI, show AEs with CQ Call Connects ≥ 20 and their CQ ACV performance."
- "In APAC – INDIA, compare Coverage for new hires by Time Since Onboarding buckets (0–3, 4–6, 7–12 months)."
- "For AMER REG in Travel, Transportation & Hospitality, list AEs with PQ C&C ACV up but CQ C&C ACV down (flag variance > 20%)."

### Team Performance
- "In Canada, which managers have teams with median CQ Customer Meetings ≥ 6/week and above-median CQ PG?"
- "For SMB – EMEA SMB, show AEs where CQ PG Participation Days improved vs PQ PG Participation Days by at least 15 days."

### Aggregation Queries
- "Count how many AEs in Public Sector have a ramp status of 'Fast Ramper'."
- "Show me the distribution of ramp statuses across all AMER OUs."

## Security & Permissions

### Permission Set
The classes are included in the `AEAE_AN_Agents_CRUD` permission set, which provides:
- Read access to `AGENT_OU_PIPELINE_V2__c` records
- Execute access to both service and handler classes
- Access to all required fields for filtering and analysis

### Data Access Control
- **Row-Level Security**: Inherits from `FRAGENTGeneralService`
- **Field-Level Security**: Respects field-level permissions
- **Object Permissions**: Requires read access to the target object

## Performance Considerations

### Query Optimization
- **Required Filters**: Always requires at least one of OU Name or Work Location Country to prevent excessive row returns
- **Indexed Fields**: Queries are optimized for commonly filtered fields
- **Pagination**: Supports record limits and offsets for large result sets

### Governor Limits
- **SOQL Queries**: Optimized to minimize query count
- **Record Processing**: Bulkified operations for large datasets
- **Memory Usage**: Efficient data structures for result handling

## Testing

### Test Script
A comprehensive test script is provided at `scripts/testing/test_kpi_analysis_v3.apex` that covers:
- Service method testing
- Handler action testing
- Error handling validation
- Response structure verification

### Mock Data Support
Both classes include `@TestVisible` mock data support for unit testing:
- `mockResults`: Mock `AGENT_OU_PIPELINE_V2__c` records
- `mockCountResult`: Mock count query results

## Deployment

### Prerequisites
1. **Object Access**: Ensure `AGENT_OU_PIPELINE_V2__c` is accessible
2. **Field Access**: Verify all required fields are accessible
3. **Permission Set**: Assign `AEAE_AN_Agents_CRUD` to users

### Deployment Order
1. Deploy `ANAGENTKPIAnalysisServiceV3.cls`
2. Deploy `ANAGENTKPIAnalysisHandlerV3.cls`
3. Update permission set assignments
4. Run test script for validation

## Support & Troubleshooting

### Common Issues
1. **Missing Required Filter**: Ensure at least one of OU Name or Work Location Country is provided
2. **Field Access**: Verify field-level permissions are correctly set
3. **Query Limits**: Check for governor limit violations with large datasets

### Debug Information
- All methods include comprehensive error messages
- Response objects include success indicators and descriptive messages
- Debug logs provide detailed execution information

## Future Enhancements

### Planned Features
- Advanced filtering with range queries
- Comparative analysis tools
- Trend analysis capabilities
- Export functionality for large datasets

### Integration Points
- Einstein Analytics integration
- Tableau connector support
- Real-time dashboard updates
- Automated reporting workflows

---

For additional support or questions, refer to the Salesforce developer documentation or contact the development team. 