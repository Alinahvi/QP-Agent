# KPI Outlier Analysis Documentation

## Overview

The KPI Analysis action has been enhanced with advanced outlier detection capabilities using statistical methods (Z-score and IQR) to identify high-performing and underperforming Account Executives.

## Features

### 1. Outlier Detection Methods

#### Z-Score Method
- **Threshold**: Configurable via `KPI_ZScore_Threshold__c` (default: 2.5)
- **Logic**: Values with |z-score| > threshold are considered outliers
- **Formula**: `z = (value - mean) / standard_deviation`

#### IQR (Interquartile Range) Method
- **Multiplier**: Configurable via `KPI_IQR_Multiplier__c` (default: 1.5)
- **Logic**: Values outside [Q1 - k*IQR, Q3 + k*IQR] are outliers
- **Formula**: `IQR = Q3 - Q1`, bounds = Q1 - k*IQR to Q3 + k*IQR

### 2. Supported Metrics

The system can detect outliers for the following KPI metrics:
- `CQ_CUSTOMER_MEETING__c` - Customer meetings
- `CQ_CALL_CONNECT__c` - Call connects
- `CQ_ACV__c` - Annual Contract Value
- `CQ_PG__c` - Pipeline Generated
- `Coverage__c` - Coverage ratio
- `AE_Score__c` - AE Score

### 3. Configuration

Outlier detection is controlled via Custom Metadata Type `KPI_Config__mdt`:

```apex
KPI_Enable_Outliers__c     // Enable/disable outlier detection
KPI_MaxRows__c            // Maximum rows to process (default: 2000)
KPI_ZScore_Threshold__c   // Z-score threshold (default: 2.5)
KPI_IQR_Multiplier__c     // IQR multiplier (default: 1.5)
```

## API Usage

### Request Parameters

```json
{
  "ouName": "AMER ACC",                    // Organizational Unit
  "workLocationCountry": "United States",  // Optional country filter
  "timeFrame": "CURRENT",                  // CURRENT or PREVIOUS
  "analysisType": "MEETINGS",              // Analysis type
  "enableOutliers": true,                  // Enable outlier detection
  "metrics": ["CQ_CUSTOMER_MEETING__c"],   // Specific metrics to analyze
  "limitN": 100,                          // Max records to process
  "maxResults": 1000,                     // Max results to return
  "includeLearnerProfile": true,          // Include learner profile data
  "fuzzySearchEnabled": true              // Enable fuzzy search
}
```

### Response Structure

```json
{
  "success": true,
  "message": "Formatted human-readable message",
  "formattedMessage": "Enhanced markdown-formatted message",
  "totalRecordCount": 150,
  "totalAEs": 150,
  "avgCoverage": 2.3,
  "totalMeetings": 1250,
  "outlierResults": {
    "CQ_CUSTOMER_MEETING__c": {
      "method": "Z-Score",
      "metric": "CQ_CUSTOMER_MEETING__c",
      "statistics": {
        "mean": 15.2,
        "median": 14.0,
        "stdDev": 5.1,
        "q1": 10.0,
        "q3": 20.0
      },
      "highOutliers": [
        {
          "recordId": "a001234567890",
          "aeName": "John High Performer",
          "aeEmail": "john.high@company.com",
          "learnerProfileId": "LP001",
          "ou": "AMER ACC",
          "country": "United States",
          "value": 35,
          "zScore": 3.9,
          "deltaFromMedian": 21.0,
          "outlierType": "HIGH"
        }
      ],
      "lowOutliers": [
        {
          "recordId": "a001234567891",
          "aeName": "Jane Needs Support",
          "aeEmail": "jane.support@company.com",
          "learnerProfileId": "LP002",
          "ou": "AMER ACC",
          "country": "United States",
          "value": 3,
          "zScore": -2.4,
          "deltaFromMedian": -11.0,
          "outlierType": "LOW"
        }
      ]
    }
  },
  "warnings": ["2 AEs missing meeting data"],
  "learnerProfiles": [...],
  "fuzzyMatches": ["AMER ACC"]
}
```

## Sample Requests

### 1. Basic Outlier Analysis
```bash
curl -X POST "{{baseUrl}}/services/apexrest/mcp/agent/kpi-analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "ouName": "AMER ACC",
    "timeFrame": "CURRENT",
    "enableOutliers": true
  }'
```

### 2. Specific Metrics Analysis
```bash
curl -X POST "{{baseUrl}}/services/apexrest/mcp/agent/kpi-analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "ouName": "UKI",
    "timeFrame": "PREVIOUS",
    "enableOutliers": true,
    "metrics": ["CQ_CUSTOMER_MEETING__c", "Coverage__c"],
    "limitN": 50
  }'
```

### 3. Revenue Outliers
```bash
curl -X POST "{{baseUrl}}/services/apexrest/mcp/agent/kpi-analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "ouName": "EMEA SMB",
    "timeFrame": "CURRENT",
    "enableOutliers": true,
    "metrics": ["CQ_ACV__c", "CQ_PG__c"]
  }'
```

## Response Formatting

The enhanced response includes:

### 1. KPI Health Summary
- Key metrics overview
- Total AEs analyzed
- Average coverage and activity metrics
- Outlier counts

### 2. Outlier Analysis Section
- **High Performers**: AEs with unusually high values
- **Underperformers**: AEs with unusually low values
- Detection method explanation
- Delta from median calculations

### 3. Benchmarks Section
- Percentile breakdowns (25th, 50th, 75th)
- Median and average comparisons
- Statistical context

### 4. Team Composition
- Learner profile insights
- Manager hierarchy
- Geographic distribution

### 5. Data Quality Notes
- Missing data warnings
- Data completeness indicators

### 6. Recommendations
- Analysis-specific suggestions
- Outlier-based coaching recommendations
- Data quality improvements

## Performance Considerations

### Governor Limits
- **SOQL Queries**: Optimized field selection, minimal queries
- **Heap Size**: Limited to 2000 records by default
- **CPU Time**: Efficient statistical calculations

### Caching
- Configuration values cached per request
- Statistics calculated once per metric
- Learner profile data batched

### Memory Management
- Outlier detection on aggregated data
- Pagination for large datasets
- Response truncation for UI limits

## Error Handling

### Common Scenarios
1. **No Data**: Returns empty outlier results with appropriate messaging
2. **Invalid Metrics**: Skips invalid fields, continues with valid ones
3. **Configuration Missing**: Uses default values with warnings
4. **Governor Limits**: Graceful degradation with error messages

### Validation
- Metric field existence checked before analysis
- Data type validation for numeric fields
- Null value handling in statistical calculations

## Testing

### Unit Tests
- `ANAgentKPIOutlierServiceTest` - Core outlier detection logic
- `ANAgentKPIResponseFormatterTest` - Response formatting
- `ANAgentKPIAnalysisServiceTest` - Integration testing

### UAT Scenarios
- See `uat/kpi_outliers.http` for comprehensive test cases
- Covers various OU, country, and metric combinations
- Tests edge cases and error conditions

## Deployment

### Prerequisites
1. Custom Metadata Type `KPI_Config__mdt` deployed
2. Default configuration record created
3. Feature flag initially set to `false`

### Rollout Strategy
1. **Sandbox Testing**: Enable outliers, run UAT
2. **Pilot Users**: Limited rollout with monitoring
3. **Full Deployment**: Enable for all users

### Monitoring
- Response time tracking
- Error rate monitoring
- Governor limit usage
- User feedback collection

## Troubleshooting

### Common Issues

#### No Outliers Detected
- Check if data has sufficient variation
- Verify metric field values are populated
- Review Z-score/IQR thresholds

#### Performance Issues
- Reduce `limitN` parameter
- Limit metrics to essential ones
- Check governor limit usage

#### Configuration Errors
- Verify `KPI_Config__mdt` record exists
- Check field API names are correct
- Ensure proper permissions

### Debug Information
- Enable debug logs for detailed processing
- Check `outlierResults` for detection details
- Review `warnings` array for data quality issues

## Future Enhancements

### Planned Features
1. **Machine Learning Integration**: Advanced anomaly detection
2. **Trend Analysis**: Historical outlier patterns
3. **Predictive Analytics**: Risk scoring for AEs
4. **Custom Thresholds**: Per-OU configuration
5. **Real-time Alerts**: Automated outlier notifications

### API Improvements
1. **Batch Processing**: Multiple OU analysis
2. **Export Options**: CSV/Excel download
3. **Visualization Data**: Chart-ready formats
4. **Webhook Integration**: Real-time notifications
