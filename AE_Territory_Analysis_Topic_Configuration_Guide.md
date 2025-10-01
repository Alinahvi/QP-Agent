# AE Territory Analysis Topic Configuration Guide

## Overview
This guide provides comprehensive instructions for configuring the AE Territory Analysis topic in QP-Agent. The system provides deep insights into Account Executive territories including pipeline status, KPIs, new hire performance, and pipeline generation opportunities.

## System Architecture

### Apex Classes
- **`ANAgentAETerritoryAnalysisHandler`** - Main entry point for QP-Agent (add this to your topic)
- **`ANAgentAETerritoryAnalysisService`** - Core business logic and data processing
- **`ANAgentAETerritoryAnalysisBatch`** - Handles large datasets (>50k records)

### Data Source
- **`AGENT_OU_PIPELINE_V2__c`** - Flat data structure containing all AE territory information

## Topic Configuration

### 1. Add Handler to Topic
Add `ANAgentAETerritoryAnalysisHandler` to your QP-Agent topic configuration.

### 2. Available Actions
The system supports the following analysis types:

#### **OPEN_PIPELINE_STATUS**
- Analyzes opportunities across all 5 pipeline stages
- Shows ACV, AE health scores, and aging by stage
- Identifies top products and accounts per stage

#### **PIPELINE_GENERATION_OPPORTUNITIES**
- **Off-sell**: Existing customer expansion opportunities
- **Cross-sell**: New product opportunities for existing customers  
- **Renewals**: Contract renewal opportunities with values

#### **TERRITORY_KPIS**
- Current vs previous quarter performance comparison
- Pipeline generation, ACV, meetings, calls, create & close metrics
- Trend analysis (UP/DOWN/STABLE)

#### **NEW_HIRE_ANALYSIS**
- Configurable time windows (3, 6, or 12 months)
- Days to productivity and ACV participation
- Ramp status distribution and peer comparisons

#### **COMPREHENSIVE_ANALYSIS**
- Combines all analysis types for complete territory insights
- Best for executive summaries and strategic planning

## Filtering Options

### Geographic Filters
- **Operating Unit**: AMER ACC, AMER ICE, LATAM, EMEA, APAC
- **Country**: US, Brazil, Canada, UK, Germany, Japan, Australia
- **Segment**: ENTR, ESMB, SMB, Enterprise

### Business Filters
- **Vertical/Industry**: HLS, FINS, CMT, Manufacturing, Technology, Retail
- **Product Family**: APM L2 taxonomy (Field Service, Sales Cloud, Data Cloud, etc.)

### Time Filters
- **New Hire Months**: 1-60 months since onboarding (default: 12)

## Sample User Queries

### Pipeline Analysis
```
"Show me the open pipeline status for AMER ACC AEs"
"Analyze pipeline stages for AEs in the FINS vertical"
"What's the pipeline coverage for US-based AEs?"
"Show pipeline breakdown by stage for LATAM territory"
```

### Pipeline Generation
```
"What are the top off-sell opportunities in the Technology industry?"
"Show me cross-sell opportunities for AMER ICE AEs"
"List renewal opportunities with values over $100k"
"Pipeline generation opportunities in the EMEA region"
```

### Performance Analysis
```
"Compare current vs previous quarter KPIs for ENTR segment"
"Show ACV performance for new hires in the last 6 months"
"What's the pipeline generation trend for AMER AEs?"
"KPI analysis for AEs in the Healthcare vertical"
```

### New Hire Analysis
```
"Analyze new hire performance for AEs onboarded in the last 3 months"
"Show ramp status distribution for LATAM new hires"
"Days to productivity for FINS vertical new AEs"
"New hire performance comparison: US vs Global average"
```

### Comprehensive Analysis
```
"Give me a comprehensive territory analysis for all AEs in the US"
"Complete territory overview for AMER ACC segment"
"Strategic territory analysis for the Technology industry"
"Executive summary for all territories"
```

## Response Format

### Chat Response
- **Summary**: High-level insights and key metrics
- **Sample Results**: First N results (configurable, default: 10)
- **CSV Available**: Notification if CSV export was requested

### CSV Export
- **All Records**: Complete dataset for detailed analysis
- **Formatted**: Proper CSV structure with headers
- **Filename**: Timestamped for easy identification

## Advanced Features

### Batch Processing
- Automatically handles datasets >50k records
- Progress tracking via Apex Jobs
- Email notifications upon completion

### Smart Filtering
- Field mapping between user-friendly names and API names
- Intelligent query building with proper escaping
- Support for partial matches and wildcards

### Performance Optimization
- Efficient SOQL queries with minimal field selection
- Batch processing for large datasets
- Configurable result limits

## Error Handling

### Validation Errors
- Invalid analysis types are rejected with clear messages
- Parameter validation (e.g., new hire months 1-60)
- Required field validation

### Data Errors
- Graceful handling of missing or null data
- Detailed error logging for debugging
- User-friendly error messages

## Best Practices

### Query Optimization
1. **Use Specific Filters**: Narrow down results for better performance
2. **Limit Results**: Use maxResults parameter to control chat output
3. **CSV for Large Datasets**: Enable CSV export for detailed analysis

### User Experience
1. **Clear Instructions**: Guide users on available analysis types
2. **Progressive Disclosure**: Show summary first, then detailed results
3. **CSV Integration**: Provide data for external analysis tools

### Performance
1. **Batch Processing**: Automatically handles large datasets
2. **Efficient Queries**: Minimal field selection and smart filtering
3. **Result Limiting**: Configurable limits to prevent timeouts

## Troubleshooting

### Common Issues

#### "No Results Found"
- Check filter parameters (OU, vertical, country)
- Verify data exists in AGENT_OU_PIPELINE_V2__c
- Try broader filters or different analysis types

#### "Batch Processing Required"
- Dataset exceeds 50k records
- Check Apex Jobs for progress
- Monitor email notifications for completion

#### "Invalid Analysis Type"
- Use only supported types from getAvailableAnalysisTypes()
- Check spelling and case sensitivity
- Refer to sample queries for guidance

### Debug Information
- Use `getFieldMappingInfo()` for field reference
- Check `getSupportedFilters()` for valid options
- Review `getAnalysisCapabilities()` for feature overview

## Integration Examples

### With Other ANAgents
```apex
// Example: Combine with Content Search for enablement
"Show me new hire performance and recommend relevant training courses"

// Example: Integrate with APM Nomination
"Analyze territory performance and identify APM nomination candidates"
```

### With External Systems
- CSV export for BI tools (Tableau, Power BI)
- Data integration with HR systems
- Performance reporting dashboards

## Security Considerations

### Data Access
- Respects Salesforce sharing rules
- Uses `with sharing` keyword for proper access control
- Field-level security compliance

### User Permissions
- Requires access to AGENT_OU_PIPELINE_V2__c object
- Apex class execution permissions
- CSV generation capabilities

## Monitoring and Maintenance

### Performance Monitoring
- Monitor batch job execution times
- Track query performance and optimization
- Review error logs and user feedback

### Data Quality
- Regular validation of AGENT_OU_PIPELINE_V2__c data
- Monitor field completeness and accuracy
- Update field mappings as needed

### System Updates
- Monitor Salesforce releases for compatibility
- Update API versions as needed
- Test functionality after org changes

## Support and Resources

### Documentation
- Class documentation in Apex code
- Field definitions and data dictionary
- Sample queries and use cases

### Testing
- Comprehensive test script: `scripts/testing/test_territory_analysis_system.apex`
- Deployment verification: `scripts/deploy/deploy_territory_analysis_system.sh`
- Unit tests for all classes

### Contact
- Review debug logs for detailed error information
- Check Apex Jobs for batch processing status
- Monitor system performance and user feedback

---

## Quick Start Checklist

- [ ] Deploy all Apex classes and metadata
- [ ] Add `ANAgentAETerritoryAnalysisHandler` to QP-Agent topic
- [ ] Test basic functionality with sample queries
- [ ] Verify CSV generation capabilities
- [ ] Test batch processing with large datasets
- [ ] Configure user permissions and access
- [ ] Train users on available analysis types
- [ ] Monitor system performance and usage

**🎯 Your AE Territory Analysis topic is now ready for production use!** 