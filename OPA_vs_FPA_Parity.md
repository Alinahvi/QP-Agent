# Open Pipe Analysis vs Future Pipeline Analysis Parity

## Overview
This document highlights the common utilities and patterns shared between Open Pipe Analysis (OPA) and Future Pipeline Analysis (FPA) to ensure consistency and maintainability.

## Shared Utilities

### 1. Probability Mapping
Both OPA and FPA use similar probability mapping utilities:

#### OPA: `AEScoreToProbability.cls`
```apex
public static Decimal map(Decimal scoreDecimal) {
    // Piecewise mapping for AE scores to closure probability
    if (scoreDecimal >= 0.0 && scoreDecimal <= 1.0) return 0.2;
    if (scoreDecimal > 1.0 && scoreDecimal <= 2.0) return 0.4;
    // ... etc
}
```

#### FPA: `FPARenewalRiskScorer.cls`
```apex
public static Decimal calculateAmountRisk(Decimal amount) {
    // Similar piecewise mapping for renewal risk
    if (amount >= 1000000) return 0.9;
    if (amount >= 500000) return 0.7;
    // ... etc
}
```

**Recommendation**: Create a shared `ProbabilityMapper` utility class.

### 2. Statistical Utilities
Both systems use statistical calculations:

#### OPA: `StatsUtil.cls`
```apex
public static Decimal calculatePercentile(Decimal value, List<Decimal> values) {
    // Percentile calculation for AE benchmarking
}
```

#### FPA: `FPAAEPerformanceAnalyzer.cls`
```apex
public static Decimal calculatePercentile(Decimal performanceScore, String ou, String product) {
    // Similar percentile calculation for AE performance
}
```

**Recommendation**: Extend `StatsUtil.cls` to support both use cases.

### 3. Explainability Builder
Both systems generate explanations for scored outputs:

#### OPA: `ExplainBuilder.cls`
```apex
public static String buildExplanation(String context, Map<String, Object> factors) {
    // Build human-readable explanations
}
```

#### FPA: Individual explain methods
```apex
private static String generateExplanation(RenewalRiskResult result, ...) {
    // Similar explanation generation
}
```

**Recommendation**: Create a shared `ExplanationBuilder` utility class.

## Common Patterns

### 1. Feature Toggle Pattern
Both systems use Custom Metadata Types for feature toggles:

#### OPA: `OPA_V3_Features__mdt`
- `EnableScoreProb__c`
- `EnableStageBottleneck__c`
- `EnablePMF__c`
- `EnableAEBenchmark__c`
- `EnableHealthScore__c`

#### FPA: `FPA_Intelligence_Features__mdt`
- `EnableRenewalRisk__c`
- `EnableAEPerf__c`
- `EnablePMF__c`
- `EnableHealthScore__c`

**Recommendation**: Standardize feature toggle naming and structure.

### 2. Scoring Weights Pattern
Both systems use configurable weights:

#### OPA: `OPA_V3_Features__mdt`
- `HealthScoreWeights__c` (JSON string)

#### FPA: `FPA_Scoring_Weights__mdt`
- Individual weight fields

**Recommendation**: Standardize weight configuration approach.

### 3. Graceful Degradation Pattern
Both systems handle missing data gracefully:

#### OPA
```apex
try {
    // Intelligence calculation
} catch (Exception e) {
    // Return basic analysis with explanation
}
```

#### FPA
```apex
try {
    // Intelligence calculation
} catch (Exception e) {
    // Return basic analysis with explanation
}
```

**Recommendation**: Create a shared `GracefulDegradation` utility class.

## Shared Data Dependencies

### 1. Learner Profile Integration
Both systems integrate with Learner Profile data:

#### OPA
- Uses `Learner_Profile__c` for AE roster data
- Matches via `LEARNER_PROFILE_ID__c` field

#### FPA
- Same integration pattern
- Same field mapping

**Recommendation**: Create a shared `LearnerProfileResolver` utility class.

### 2. OU Resolution
Both systems resolve OU aliases:

#### OPA
```apex
private static String resolveOUAlias(String ou) {
    // OU alias resolution logic
}
```

#### FPA
```apex
// Similar OU resolution needed
```

**Recommendation**: Create a shared `OUResolver` utility class.

## MCP Integration Patterns

### 1. Intelligence Flag Detection
Both systems detect intelligence capabilities from natural language:

#### OPA
```python
def extract_intelligence_flag(self, text: str, pattern: str) -> bool:
    # Pattern matching for intelligence flags
```

#### FPA
```python
def extract_fpa_intelligence_flags(self, text: str) -> Dict[str, bool]:
    # Similar pattern matching for FPA flags
```

**Recommendation**: Create a shared `IntelligenceFlagDetector` utility class.

### 2. Product Fuzzy Search
Both systems implement fuzzy product matching:

#### OPA
```python
def fuzzy_product_search(self, text: str) -> Optional[str]:
    # Fuzzy product matching logic
```

#### FPA
```python
# Similar fuzzy product matching needed
```

**Recommendation**: Create a shared `ProductFuzzyMatcher` utility class.

## Recommended Refactoring

### 1. Create Shared Utility Classes

#### `ProbabilityMapper.cls`
```apex
public class ProbabilityMapper {
    public static Decimal mapAEScoreToProbability(Decimal score) { ... }
    public static Decimal mapAmountToRisk(Decimal amount) { ... }
    public static Decimal mapScoreToPercentile(Decimal score, List<Decimal> values) { ... }
}
```

#### `ExplanationBuilder.cls`
```apex
public class ExplanationBuilder {
    public static String buildRenewalRiskExplanation(RenewalRiskResult result) { ... }
    public static String buildAEPerformanceExplanation(AEPerformanceResult result) { ... }
    public static String buildHealthScoreExplanation(HealthScoreResult result) { ... }
}
```

#### `GracefulDegradation.cls`
```apex
public class GracefulDegradation {
    public static String handleMissingData(String capability, String error) { ... }
    public static String buildFallbackResponse(String originalResponse, String explanation) { ... }
}
```

### 2. Standardize Feature Toggles

#### Create `Intelligence_Features__mdt`
```xml
<fields>
    <fullName>EnableClosureProbability__c</fullName>
    <label>Enable Closure Probability</label>
    <type>Checkbox</type>
</fields>
<fields>
    <fullName>EnableRenewalRisk__c</fullName>
    <label>Enable Renewal Risk</label>
    <type>Checkbox</type>
</fields>
<!-- etc -->
```

### 3. Standardize Scoring Weights

#### Create `Scoring_Weights__mdt`
```xml
<fields>
    <fullName>HealthScoreWeights__c</fullName>
    <label>Health Score Weights</label>
    <type>LongTextArea</type>
    <length>1000</length>
</fields>
```

### 4. Create Shared MCP Utilities

#### `IntelligenceFlagDetector.py`
```python
class IntelligenceFlagDetector:
    def detect_opa_flags(self, text: str) -> Dict[str, bool]:
        # OPA intelligence flag detection
    
    def detect_fpa_flags(self, text: str) -> Dict[str, bool]:
        # FPA intelligence flag detection
    
    def detect_common_flags(self, text: str) -> Dict[str, bool]:
        # Common intelligence flag detection
```

## Implementation Plan

### Phase 1: Extract Common Utilities
1. Create shared utility classes
2. Refactor OPA to use shared utilities
3. Refactor FPA to use shared utilities
4. Update tests

### Phase 2: Standardize Configuration
1. Create unified feature toggle metadata
2. Create unified scoring weights metadata
3. Update both systems to use unified configuration
4. Migrate existing configurations

### Phase 3: Enhance MCP Integration
1. Create shared MCP utilities
2. Update MCP server to use shared utilities
3. Improve pattern matching consistency
4. Add comprehensive testing

## Benefits of Parity

### 1. Consistency
- Unified user experience across both systems
- Consistent scoring and explanation patterns
- Standardized error handling

### 2. Maintainability
- Single source of truth for common logic
- Easier to update and enhance
- Reduced code duplication

### 3. Performance
- Shared caching mechanisms
- Optimized common operations
- Reduced memory footprint

### 4. Testing
- Shared test utilities
- Consistent test patterns
- Easier to maintain test coverage

## Conclusion

The OPA and FPA systems share many common patterns and utilities. By extracting these into shared classes and standardizing the configuration approach, we can improve consistency, maintainability, and performance while reducing code duplication.

The recommended refactoring should be implemented in phases to minimize disruption while maximizing the benefits of shared utilities and standardized patterns.
