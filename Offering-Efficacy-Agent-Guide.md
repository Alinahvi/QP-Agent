# Offering Efficacy Agent Quick Reference Guide

## Overview

The **ANAgentOfferingEfficacyHandler** and **ANAgentOfferingEfficacyService** provide comprehensive analysis of offering performance and effectiveness using APM outcome data from the `apm_outcome_v2__c` object.

## Key Capabilities

### 1. **Multi-Dimensional Analysis**
- **Region-based**: ANZ, EMEA North, AMER, etc.
- **Segment-based**: ESMB, PUBSEC, CMRCL
- **Program-based**: Fast Start, Training, etc.
- **KPI-based**: PIPE_QUALITY, ACV, PG, ACTIVITY_CALL_CONNECT, etc.
- **Product-based**: ALL, Einstein, Tableau, etc.

### 2. **Performance Metrics**
- **Mean Effectiveness**: Overall performance score (0-1 scale)
- **Calculated Lift**: Performance improvement over control
- **Total Influenced ACV**: Total Annual Contract Value influenced
- **Distinct Learners**: Number of unique participants
- **Significance Indicator**: Statistical significance (SIGNIFICANT/NON-SIGNIFICANT)

### 3. **Three Action Types**

#### **Search Action**
- Find specific offering efficacy data
- Filter by any combination of criteria
- Limited results for focused analysis

#### **Analyze Action**
- Comprehensive analysis across all dimensions
- Top performer identification
- Detailed breakdowns and insights

#### **Summary Action**
- High-level overview and trends
- Aggregated metrics and patterns
- Quick insights for decision-making

## Usage Examples

### Example 1: Search for Specific Offering
```apex
ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
request.action = 'Search';
request.offeringLabel = 'FY25 Fast Start - RKO - Einstein 1';
request.programType = 'Fast Start';
request.region = 'ANZ';
request.maxResults = 20;
```

### Example 2: Regional Performance Analysis
```apex
request.action = 'Analyze';
request.region = 'EMEA North';
request.programType = 'Fast Start';
request.fiscalQuarter = '2024-Q1';
```

### Example 3: KPI-Specific Summary
```apex
request.action = 'Summary';
request.kpiName = 'PIPE_QUALITY';
request.programType = 'Fast Start';
```

## Response Structure

### **EfficacyAnalysisResponse**
- `success`: Boolean indicating operation success
- `message`: Human-readable response message
- `totalRecordCount`: Number of records found
- `efficacyRecords`: Detailed record list
- `summaryMetrics`: Aggregated performance summary
- `topPerformers`: Top 10 performing offerings
- `regionalBreakdown`: Performance by region
- `segmentBreakdown`: Performance by segment
- `kpiBreakdown`: Performance by KPI type

### **Sample Response Message**
```
"Found 15 efficacy records. Summary Metrics: 15 records analyzed. 
Average Effectiveness: 63.55%, Average Lift: 1.84%, 
Total ACV: $2.34B, Total Learners: 42, 
Significant Results: 80.0%"
```

## Key Insights Available

### 1. **Effectiveness Rankings**
- Top performing offerings by effectiveness score
- Regional performance comparisons
- Segment-based performance analysis

### 2. **Business Impact**
- Total ACV influenced by offerings
- Per-learner ACV impact
- Statistical significance of results

### 3. **Trend Analysis**
- Performance by fiscal quarter
- Program type effectiveness
- KPI performance breakdowns

## Integration with Other Agents

This agent complements the existing ANAgent ecosystem:

- **Content Search Agents**: Find courses and then analyze their efficacy
- **APM Nomination Agents**: Create nominations and track outcomes
- **OpenPipe Agents**: Analyze sales pipeline effectiveness

## Best Practices

### 1. **Query Optimization**
- Use specific filters to reduce result sets
- Limit results for better performance
- Combine filters for targeted analysis

### 2. **Data Interpretation**
- Focus on SIGNIFICANT results for reliable insights
- Compare effectiveness across similar offerings
- Consider regional and segment context

### 3. **Action Selection**
- Use **Search** for specific queries
- Use **Analyze** for comprehensive insights
- Use **Summary** for high-level overviews

## Error Handling

The agent includes comprehensive error handling:
- Invalid filter combinations
- No data found scenarios
- Query execution errors
- Data processing exceptions

## Testing

Use the provided test script `scripts/apex/test_offering_efficacy_agent.apex` to verify functionality and test different scenarios.

## Performance Considerations

- Large datasets are automatically limited to 1000 records for summary operations
- Results are sorted by effectiveness for quick top-performer identification
- Efficient SOQL queries with proper indexing considerations

---

**Note**: This agent provides data-driven insights into offering effectiveness, enabling data-informed decisions about enablement investments and program improvements. 