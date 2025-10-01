# Open Pipe Analysis V3 Intelligence Capabilities

## Overview

The Open Pipe Analysis V3 has been enhanced with five new intelligence capabilities that provide actionable insights and explainability for pipeline analysis. These capabilities are feature-toggled via Custom Metadata Type `OPA_V3_Features__mdt` and can be enabled/disabled independently.

## Intelligence Capabilities

### 1. AE Scorecard → Closure Probability

**Purpose**: Convert AE deal scores into closure probabilities and surface them per AE and per product.

**Key Fields**:
- `OPEN_PIPE_AE_SCORE__c` (0–5 scale) from `Agent_Open_Pipe__c`
- `PRODUCT_L2__c` (primary product field)

**Implementation**:
- **Utility Class**: `AEScoreToProbability`
- **Method**: `map(scoreDecimal)` with piecewise mapping:
  - 0.0–1.0 → 0–20%
  - 1.01–2.0 → 20–40%
  - 2.01–3.0 → 40–60%
  - 3.01–4.0 → 60–80%
  - 4.01–5.0 → 80–95%
- **Aggregation**: Per AE × product with AVG(AE score), COUNT(opps), SUM(Amount)
- **Output**: `aeEmail`, `ou`, `product`, `avgScore`, `closureProbability`, `oppCount`, `totalAmount`, `explanation`

**Feature Toggle**: `EnableScoreProb__c` (boolean)

### 2. Stage Bottleneck Detection

**Purpose**: Identify stages with abnormal dwell time and compare across OUs/segments.

**Key Fields**:
- `OPEN_PIPE_OPTY_STG_NM_*__c` (stage names)
- `OPEN_PIPE_OPTY_DAYS_IN_STAGE_*__c` (dwell time)
- `OU_NAME__c` (operating unit)
- `MACROSEGMENT__c`, `PRIMARY_INDUSTRY__c` (segment/vertical)

**Implementation**:
- **Reference Cohort**: Same segment and industry across peer OUs
- **Analysis**: Mean/median `daysInStage` by Stage 2–5
- **Outlier Detection**: Z-score or 75th percentile vs reference cohort
- **Output**: `bottlenecks[]` with `{stageName, avgDays, p75Days, deltaVsPeer, affectedOppCount, explanation}`

**Feature Toggle**: `EnableStageBottleneck__c` (boolean)

### 3. Product-Market Fit (PMF) Signals

**Purpose**: Correlate product performance with market segments/verticals to recommend "where product wins".

**Key Fields**:
- `PRODUCT_L2__c` (primary product)
- `MACROSEGMENT__c`, `PRIMARY_INDUSTRY__c` (cohort fields)
- `WORK_LOCATION_COUNTRY__c`, `OU_NAME__c` (geography)

**Metrics**:
- **Win Proxy**: Sum of `Amount` for post-Stage-4 opps × closureProbability
- **Volume Proxy**: Count of opps post-Stage-4
- **Efficiency**: Win proxy / volume (or per-AE normalization)

**Output**: `pmfFindings[]` per product × segment × industry with `{product, segment, industry, oppCount, weightedAmount, efficiency, explanation}`

**Feature Toggle**: `EnablePMF__c` (boolean)

### 4. AE Performance Benchmarking

**Purpose**: Place each AE in percentile ranks vs peer cohort to identify coaching opportunities.

**Cohorts**:
- **Primary**: Same OU + product
- **Secondary**: Same segment/industry (cross-OU)

**Metrics**:
- `avgAEOpenScore` (from closure probability)
- `oppCount`, `sumAmount`
- `stage2→3 conversion`
- `avgDaysInStage2/3`

**Output**: `aeBenchmarks[]` with `{aeEmail, product, pctlScore, pctlConversion, pctlVelocity, explanation}`

**Feature Toggle**: `EnableAEBenchmark__c` (boolean)

### 5. Pipeline Health Scoring

**Purpose**: Single composite score 0–10 with rationale and next best actions.

**Components** (configurable weights via `HealthScoreWeights__c` JSON field):
- **Deal Mix** (post-Stage-4 weight vs early stage) – 25%
- **Stage Bottlenecks Penalty** (from bottleneck detection) – 25%
- **AE Score → Closure Probability** (from closure probability) – 25%
- **PMF Alignment** (top-N products aligned to strong segments) – 15%
- **Coverage vs Target** (if available) – 10%

**Implementation**:
- **Normalization**: Each component to 0–1; weighted sum × 10
- **Explainability**: `explain[]` list with contributions and deltas
- **Next Actions**: `nextBestActions[]` with specific recommendations

**Output**: `healthScore` (decimal 0–10), `explain[]` strings, `nextBestActions[]`

**Feature Toggle**: `EnableHealthScore__c` (boolean)

## Custom Metadata Type: OPA_V3_Features__mdt

### Fields

| Field Name | Type | Description | Default |
|------------|------|-------------|---------|
| `EnableScoreProb__c` | Boolean | Enable AE closure probability analysis | true |
| `EnableStageBottleneck__c` | Boolean | Enable stage bottleneck detection | true |
| `EnablePMF__c` | Boolean | Enable product-market fit analysis | true |
| `EnableAEBenchmark__c` | Boolean | Enable AE performance benchmarking | true |
| `EnableHealthScore__c` | Boolean | Enable pipeline health scoring | true |
| `HealthScoreWeights__c` | Text | JSON weights for health score components | See below |

### Default Health Score Weights

```json
{
  "dealMix": 0.25,
  "stageBottlenecks": 0.25,
  "aeScore": 0.25,
  "pmfAlignment": 0.15,
  "coverage": 0.10
}
```

## Utility Classes

### AEScoreToProbability

**Purpose**: Map AE scores to closure probabilities with explainability.

**Key Methods**:
- `map(scoreDecimal)`: Convert score to probability (0.0-1.0)
- `generateExplanation(avgScore, closureProbability, oppCount, totalAmount)`: Generate human-readable explanation
- `toPercentage(probability)`: Format probability as percentage

### StatsUtil

**Purpose**: Statistical calculations for benchmarking and analysis.

**Key Methods**:
- `calculateMedian(values)`: Calculate median value
- `calculatePercentile(values, percentile)`: Calculate specific percentile
- `calculateMean(values)`: Calculate mean value
- `calculateZScore(value, mean, stdDev)`: Calculate z-score

### ExplainBuilder

**Purpose**: Build explainability strings and next best actions.

**Key Methods**:
- `buildHealthScoreExplanation(components, weights)`: Build health score explanation
- `buildNextBestActions(insights)`: Generate next best actions
- `formatPercentage(value)`: Format as percentage with sign

## Handler Integration

### ANAgentOpenPipeAnalysisV3Handler

**New Request Fields** (all optional, default false):
- `includeClosureProb`: Include AE closure probability analysis
- `includeStageBottlenecks`: Include stage bottleneck detection
- `includePMF`: Include product-market fit analysis
- `includeAEBenchmarks`: Include AE performance benchmarking
- `includeHealthScore`: Include pipeline health scoring

### ANAgentOpenPipeAnalysisV3Service

**New Method Signature**:
```apex
public static String analyzeOpenPipe(
    String ouName, 
    String workLocationCountry, 
    String groupBy, 
    String filterCriteria, 
    String restrictInValuesCsv, 
    Boolean perAENormalize, 
    Integer limitN, 
    String aggregationType, 
    String analysisType,
    Boolean includeClosureProb,      // NEW
    Boolean includeStageBottlenecks, // NEW
    Boolean includePMF,              // NEW
    Boolean includeAEBenchmarks,     // NEW
    Boolean includeHealthScore       // NEW
)
```

## MCP Integration

### Tool Schema Updates

The `open_pipe_analyze` tool now accepts these additional parameters:

```json
{
  "includeClosureProb": {"type": "boolean"},
  "includeStageBottlenecks": {"type": "boolean"},
  "includePMF": {"type": "boolean"},
  "includeAEBenchmarks": {"type": "boolean"},
  "includeHealthScore": {"type": "boolean"}
}
```

### Router Examples

1. **"Open pipe for AMER-ACC this quarter; where's the bottleneck?"**
   → `{"includeStageBottlenecks": true}`

2. **"Give me pipeline health score for AMER-ACC Data Cloud"**
   → `{"includeHealthScore": true, "productListCsv": "Data Cloud"}`

3. **"Benchmark AEs for Service Cloud in UKI"**
   → `{"includeAEBenchmarks": true, "productListCsv": "Service Cloud"}`

4. **"What's the close probability for Data Cloud in AMER-ACC?"**
   → `{"includeClosureProb": true, "productListCsv": "Data Cloud"}`

5. **"Which products fit best in ENTR segment across OUs?"**
   → `{"includePMF": true, "segment": "enterprise"}`

## Performance Considerations

### Governor Limits
- **CPU Time**: p95 < 7,000 ms for default scope (≤ 100 AEs)
- **SOQL Queries**: ≤ 40 queries per execution
- **Query Rows**: ≤ 30,000 rows per execution
- **Heap Size**: < 5.5MB for default scope

### Optimization Strategies
- **Aggregate SOQL**: Use aggregate queries for cross-AE analytics
- **Feature Toggles**: Disable unused capabilities to reduce processing
- **Batch Processing**: Process large datasets in batches if needed
- **Caching**: Leverage Platform Cache for frequently accessed data

## Testing

### Unit Test Coverage
- **Target**: ≥ 90% for new code paths
- **Test Classes**: 
  - `AEScoreToProbabilityTest`
  - `StatsUtilTest`
  - `ExplainBuilderTest`
  - `ANAgentOpenPipeAnalysisV3IntelligenceTest`

### Test Scenarios
1. **Score Bands**: Validate probability mapping for all score ranges
2. **Bottleneck Detection**: Test with synthetic data where one stage is inflated
3. **PMF Analysis**: Verify 3× signal detection in contrived data
4. **Benchmarking**: Test percentile calculations with edge cases (≤ 5 AEs)
5. **Health Score**: Validate deterministic scoring with additive explanations

## Usage Examples

### Enable All Features
```apex
// In OPA_V3_Features__mdt Default_Features record
EnableScoreProb__c = true
EnableStageBottleneck__c = true
EnablePMF__c = true
EnableAEBenchmark__c = true
EnableHealthScore__c = true
```

### Disable Specific Features
```apex
// Disable only PMF analysis
EnablePMF__c = false
```

### Custom Health Score Weights
```json
{
  "dealMix": 0.30,
  "stageBottlenecks": 0.20,
  "aeScore": 0.30,
  "pmfAlignment": 0.15,
  "coverage": 0.05
}
```

## Troubleshooting

### Common Issues

1. **Feature Not Working**: Check `OPA_V3_Features__mdt` record exists and feature is enabled
2. **Performance Issues**: Disable unused features or reduce scope
3. **Missing Data**: Verify required fields are populated in `Agent_Open_Pipe__c`
4. **SOQL Errors**: Check field API names and object relationships

### Debug Mode
Enable debug logging in `ANAgentOpenPipeAnalysisV3Service` to trace execution flow and identify bottlenecks.

## Future Enhancements

1. **Machine Learning Integration**: Replace static mappings with ML models
2. **Real-time Updates**: Implement streaming updates for live dashboards
3. **Advanced Analytics**: Add trend analysis and forecasting capabilities
4. **Custom Metrics**: Allow users to define custom scoring components
5. **API Integration**: Expose intelligence capabilities via REST APIs

---

**Version**: 1.0  
**Last Updated**: December 2024  
**Maintainer**: Salesforce Development Team
