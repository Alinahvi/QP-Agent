# UAT Test Pack for Future Pipeline Analysis Intelligence

## Test Overview
This UAT pack contains 24 test utterances (8 per analysis type) to validate the enhanced Future Pipeline Analysis with intelligence capabilities.

## Test Categories

### 1. Renewal Analysis Tests (8 utterances)

#### Basic Renewal Analysis
1. **"Show me renewal opportunities in AMER ACC"**
   - Expected: Basic renewal analysis with intelligence features if enabled
   - Flags: `includeRenewalRisk: true, includeAEPerf: true, includeHealthScore: true`

2. **"What are the renewal risks for Data Cloud in EMEA ENTR?"**
   - Expected: Renewal risk analysis with risk scoring and recommendations
   - Flags: `includeRenewalRisk: true`

3. **"Give me AE performance for renewals in UKI"**
   - Expected: AE performance analysis with coaching recommendations
   - Flags: `includeAEPerf: true`

#### Renewal Risk Analysis
4. **"Show me high-risk renewals in AMER ACC with coaching opportunities"**
   - Expected: Renewal risk analysis + AE performance analysis
   - Flags: `includeRenewalRisk: true, includeAEPerf: true`

5. **"What's the renewal probability for Service Cloud in EMEA Central?"**
   - Expected: Renewal risk analysis with probability scoring
   - Flags: `includeRenewalRisk: true`

#### Missing Data Scenarios
6. **"Analyze renewal risks for Platform Cloud in APAC"**
   - Expected: Graceful degradation with explainability for missing data
   - Flags: `includeRenewalRisk: true`

7. **"Show me renewal health score for AMER SMB"**
   - Expected: Health score analysis with fallback explanations
   - Flags: `includeHealthScore: true`

#### Previous Quarter Analysis
8. **"Compare renewal performance this quarter vs last quarter in EMEA ENTR"**
   - Expected: Time-based analysis with intelligence features
   - Flags: `includeRenewalRisk: true, includeAEPerf: true`

### 2. Upsell Analysis Tests (8 utterances)

#### Basic Upsell Analysis
1. **"Show me upsell opportunities in AMER ACC"**
   - Expected: Basic upsell analysis with intelligence features if enabled
   - Flags: `includePMF: true, includeHealthScore: true`

2. **"What's the product-market fit for Tableau in EMEA ENTR?"**
   - Expected: PMF analysis with efficiency scoring
   - Flags: `includePMF: true`

3. **"Give me AE performance for upsell in UKI"**
   - Expected: AE performance analysis for upsell context
   - Flags: `includeAEPerf: true`

#### PMF Analysis
4. **"Show me PMF analysis for Marketing Cloud across all segments"**
   - Expected: PMF analysis with segment performance
   - Flags: `includePMF: true`

5. **"What products fit best in enterprise segment for AMER ACC?"**
   - Expected: PMF analysis with product recommendations
   - Flags: `includePMF: true`

#### Health Score Analysis
6. **"Give me pipeline health score for upsell in EMEA Central"**
   - Expected: Health score analysis with contributing factors
   - Flags: `includeHealthScore: true`

7. **"Show me comprehensive upsell analysis for Data Cloud in AMER ACC"**
   - Expected: All intelligence features enabled
   - Flags: `includePMF: true, includeAEPerf: true, includeHealthScore: true`

#### OU Variations
8. **"Analyze upsell opportunities in AMERACC"**
   - Expected: OU alias resolution with intelligence features
   - Flags: `includePMF: true, includeHealthScore: true`

### 3. Cross-Sell Analysis Tests (8 utterances)

#### Basic Cross-Sell Analysis
1. **"Show me cross-sell opportunities in AMER ACC"**
   - Expected: Basic cross-sell analysis with intelligence features if enabled
   - Flags: `includePMF: true, includeAEPerf: true`

2. **"What's the PMF for MuleSoft in EMEA ENTR?"**
   - Expected: PMF analysis for cross-sell products
   - Flags: `includePMF: true`

3. **"Give me AE coaching opportunities for cross-sell in UKI"**
   - Expected: AE performance analysis with coaching flags
   - Flags: `includeAEPerf: true`

#### AE Performance Analysis
4. **"Show me AE performance rankings for cross-sell in AMER ACC"**
   - Expected: AE performance analysis with percentile rankings
   - Flags: `includeAEPerf: true`

5. **"What AEs need coaching for cross-sell in EMEA Central?"**
   - Expected: AE performance analysis with coaching recommendations
   - Flags: `includeAEPerf: true`

#### PMF Analysis
6. **"Show me product-market fit for cross-sell products in AMER SMB"**
   - Expected: PMF analysis with segment performance
   - Flags: `includePMF: true`

7. **"What's the best cross-sell product for healthcare industry in UKI?"**
   - Expected: PMF analysis with industry-specific recommendations
   - Flags: `includePMF: true`

#### Country Filter
8. **"Analyze cross-sell opportunities in Germany with health score"**
   - Expected: Country-filtered analysis with health scoring
   - Flags: `includePMF: true, includeAEPerf: true, includeHealthScore: true`

## Expected Test Results

### Success Criteria
- All 24 utterances should be successfully routed to the enhanced handler
- Intelligence features should be enabled based on utterance context
- Responses should include appropriate intelligence sections
- Graceful degradation should occur when data is missing
- Explainability should be provided for all intelligence features

### Error Handling
- Missing data should not cause exceptions
- Feature toggles should work correctly
- OU aliases should be resolved properly
- Country filters should work as expected

### Performance Criteria
- Response time should be < 2 seconds for basic analysis
- Response time should be < 5 seconds for full intelligence analysis
- CPU usage should be within governor limits
- SOQL queries should be within limits

## Test Execution

### Pre-requisites
1. Deploy all enhanced classes and metadata
2. Enable feature toggles in `FPA_Intelligence_Features__mdt`
3. Configure scoring weights in `FPA_Scoring_Weights__mdt`
4. Ensure test data is available

### Execution Steps
1. Run each utterance through the MCP server
2. Verify correct tool detection and parameter extraction
3. Check that intelligence features are enabled appropriately
4. Validate response format and content
5. Verify explainability and graceful degradation

### Success Metrics
- **Tool Detection**: 100% success rate for correct tool routing
- **Parameter Extraction**: 100% success rate for required parameters
- **Intelligence Features**: 90% success rate for enabled features
- **Graceful Degradation**: 100% success rate for missing data scenarios
- **Performance**: 95% of responses within time limits

## Troubleshooting

### Common Issues
1. **Missing Data**: Check data audit report for field availability
2. **Feature Toggles**: Verify metadata configuration
3. **OU Aliases**: Check OU resolution logic
4. **Performance**: Monitor governor limits and query optimization

### Debug Information
- Check debug logs for feature toggle status
- Verify metadata retrieval
- Monitor SOQL query performance
- Review explainability messages
