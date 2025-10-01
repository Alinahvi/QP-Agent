# Future Pipeline Analysis Intelligence

## Overview
The Future Pipeline Analysis Intelligence module extends the basic Future Pipeline Analysis with advanced intelligence capabilities including renewal risk scoring, AE performance analysis, product-market fit analysis, and pipeline health scoring.

## Intelligence Modules

### 1. Renewal Risk Scoring
**Purpose**: Assess renewal probability and risk tiers for renewal opportunities.

**Input Fields**:
- `renewal_opty_amt__c` - Renewal opportunity amount
- `renewal_prod_nm__c` - Renewal product name
- `ou_name__c` - Operating Unit
- `full_name__c` - AE name

**Scoring Logic**:
- Amount-based risk (larger amounts = higher risk)
- Product complexity (enterprise products = higher risk)
- OU performance (EMEA/APAC = higher risk than AMER)

**Output**:
- `renewalRisk` (0-1 scale)
- `renewalProbability` (0-1 scale)
- `riskTier` (LOW, MEDIUM, HIGH)
- `topFactors` (list of risk factors)
- `why` (explanation)

**Feature Toggle**: `EnableRenewalRisk__c`

### 2. AE Performance Analysis
**Purpose**: Benchmark AE performance and provide coaching recommendations.

**Input Fields**:
- `AE_Score__c` - AE performance score (0-5 scale)
- `Coverage__c` - Coverage ratio
- `full_name__c` - AE name
- `ou_name__c` - Operating Unit

**Scoring Logic**:
- Performance score = (AE_Score * 0.7) + (Coverage * 0.3)
- Percentile ranking based on performance score
- Coaching flags for underperforming AEs

**Output**:
- `performancePercentile` (0-100%)
- `performanceTier` (Top Performer, Above Average, Average, Below Average, Needs Improvement)
- `coachingFlags` (list of coaching needs)
- `recommendations` (list of actionable recommendations)
- `why` (explanation)

**Feature Toggle**: `EnableAEPerf__c`

### 3. Product-Market Fit Analysis
**Purpose**: Analyze product performance across segments and industries.

**Input Fields**:
- `renewal_prod_nm__c` / `cross_sell_next_best_product__c` / `upsell_sub_category__c` - Product names
- `ou_name__c` - Operating Unit
- `primary_industry__c` - Industry

**Scoring Logic**:
- Efficiency = weighted amount per opportunity
- Segment performance analysis
- Industry performance analysis

**Output**:
- `product` - Product name
- `segment` - Market segment
- `industry` - Industry
- `oppCount` - Number of opportunities
- `weightedAmount` - Weighted revenue amount
- `efficiency` - Efficiency score (0-1 scale)
- `why` - explanation

**Feature Toggle**: `EnablePMF__c`

### 4. Pipeline Health Scoring
**Purpose**: Calculate composite health score for pipeline assessment.

**Input Fields**:
- All available pipeline data
- AE performance metrics
- Product performance metrics

**Scoring Logic**:
- Weighted combination of:
  - Renewal risk score (30%)
  - AE performance score (25%)
  - PMF score (20%)
  - Concentration risk score (15%)
  - Time to renewal score (10%)

**Output**:
- `healthScore` (0-10 scale)
- `healthTier` (Healthy, Moderate, At Risk)
- `contributingFactors` (list of factors)
- `nextBestActions` (list of recommendations)
- `why` (explanation)

**Feature Toggle**: `EnableHealthScore__c`

## Configuration

### Custom Metadata Types

#### FPA_Intelligence_Features__mdt
Feature toggles for intelligence capabilities:
- `EnableRenewalRisk__c` (boolean) - Enable renewal risk scoring
- `EnableAEPerf__c` (boolean) - Enable AE performance analysis
- `EnablePMF__c` (boolean) - Enable product-market fit analysis
- `EnableHealthScore__c` (boolean) - Enable pipeline health scoring
- `EnableExplain__c` (boolean) - Enable explainability (default: true)
- `EnableLearnerEnrichment__c` (boolean) - Enable Learner Profile enrichment

#### FPA_Scoring_Weights__mdt
Configurable weights and thresholds:
- `RenewalRiskWeight__c` (0.3) - Weight for renewal risk in health score
- `AEPerformanceWeight__c` (0.25) - Weight for AE performance in health score
- `PMFWeight__c` (0.2) - Weight for PMF in health score
- `ConcentrationRiskWeight__c` (0.15) - Weight for concentration risk in health score
- `TimeToRenewalWeight__c` (0.1) - Weight for time to renewal in health score
- `RenewalRiskThreshold__c` (0.7) - Threshold for high renewal risk
- `AEScoreThreshold__c` (3.0) - Threshold for on-track AE performance
- `CoverageThreshold__c` (2.0) - Threshold for healthy coverage
- `HealthScoreThreshold__c` (7.0) - Threshold for healthy pipeline

## Usage

### Basic Usage
```apex
// Basic Future Pipeline Analysis
ABAgentFuturePipeAnalysisHandler.analyzePipeline(requests);
```

### Enhanced Usage with Intelligence
```apex
// Enhanced Future Pipeline Analysis with Intelligence
ABAgentFuturePipeAnalysisHandlerEnhanced.analyzePipelineEnhanced(enhancedRequests);
```

### MCP Integration
The MCP server automatically detects intelligence capabilities from natural language utterances:

```
"Show me renewal risks for Data Cloud in AMER ACC"
→ includeRenewalRisk: true

"Give me AE coaching opportunities for EMEA ENTR"
→ includeAEPerf: true

"What's the product-market fit for Tableau in UKI?"
→ includePMF: true

"Rate the health of our pipeline in AMER ACC"
→ includeHealthScore: true
```

## Data Requirements

### Required Fields
- `Id` - Record ID
- `full_name__c` - AE name
- `ou_name__c` - Operating Unit
- `work_location_country__c` - Work location country

### Optional Fields (for enhanced intelligence)
- `renewal_opty_amt__c` - Renewal amount (for renewal risk scoring)
- `AE_Score__c` - AE performance score (for AE performance analysis)
- `Coverage__c` - Coverage ratio (for AE performance analysis)
- `CloseDate` - Close date (for renewal risk scoring)
- `PRODUCT_L2__c` / `PRODUCT_L3__c` - Product hierarchy (for PMF analysis)

### Missing Data Handling
When required fields are missing, the system gracefully degrades:
- Returns basic aggregation without intelligence features
- Provides explainability messages about missing capabilities
- Suggests data improvements

## Performance Considerations

### Governor Limits
- CPU time: < 7,000 ms (p95)
- SOQL queries: ≤ 40
- Query rows: ≤ 30,000
- Heap size: < 5.5 MB

### Optimization Strategies
- Use aggregate queries to prevent heap issues
- Implement feature toggles to disable expensive calculations
- Cache scoring weights and thresholds
- Graceful degradation for missing data

## Testing

### Unit Tests
- `FPADataAuditTest.cls` - Tests data audit and graceful degradation
- Individual module tests for each intelligence capability
- Integration tests for enhanced service

### UAT Tests
- 24 test utterances covering all analysis types
- Intelligence feature validation
- Error handling and graceful degradation
- Performance validation

## Troubleshooting

### Common Issues

#### Missing Data
**Problem**: Intelligence features not working
**Solution**: Check data audit report for missing fields
**Action**: Add missing fields or enable graceful degradation

#### Feature Toggles
**Problem**: Intelligence features not enabled
**Solution**: Check `FPA_Intelligence_Features__mdt` configuration
**Action**: Enable required features in metadata

#### Performance Issues
**Problem**: Slow response times
**Solution**: Check governor limits and query optimization
**Action**: Enable feature toggles to disable expensive calculations

### Debug Information
- Check debug logs for feature toggle status
- Verify metadata retrieval
- Monitor SOQL query performance
- Review explainability messages

## Known Limitations

### Data Gaps
- `CloseDate` field missing on Renewals object
- `AE_Score__c` and `Coverage__c` fields missing on all objects
- `PRODUCT_L2__c` and `PRODUCT_L3__c` fields missing on all objects

### Workarounds
- Use amount-based risk scoring for renewals
- Implement heuristic-based AE performance analysis
- Use existing product fields for PMF analysis
- Provide explainability for missing capabilities

## Future Enhancements

### Phase 1: Data Model Improvements
- Add missing fields to all objects
- Implement proper product hierarchy
- Add AE performance metrics

### Phase 2: Advanced Intelligence
- Machine learning-based scoring
- Predictive analytics
- Real-time recommendations

### Phase 3: Integration
- Integration with other intelligence modules
- Cross-pipeline analysis
- Executive dashboards

## Support

For issues or questions:
1. Check the data audit report
2. Review feature toggle configuration
3. Check debug logs for errors
4. Contact the development team

## Changelog

### Version 1.0
- Initial implementation of intelligence capabilities
- Basic renewal risk scoring
- AE performance analysis
- Product-market fit analysis
- Pipeline health scoring
- Graceful degradation for missing data
- MCP integration
- Comprehensive testing suite
