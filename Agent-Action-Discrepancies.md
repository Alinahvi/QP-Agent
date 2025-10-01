# Agent Action Discrepancies Report

## Overview
This document tracks discrepancies found between agent actions and their expected behavior during comprehensive testing with 50+ utterances per action.

---

## 1. ANAgent Search Content V2 ✅ **WORKING CORRECTLY**

### Test Results
- **Total Tests**: 20 utterances
- **Success Rate**: 95% (19/20 successful)
- **API vs SOQL Match**: 100% accuracy when API succeeds

### Findings
- ✅ **Perfect Match**: API results exactly match SOQL queries
- ✅ **All Content Types**: Course, Asset, Curriculum searches work correctly
- ✅ **Mixed Searches**: Cross-object searches work perfectly
- ⚠️ **Minor Issue**: One test failed for "beginner curriculum" (expected - no content contains "beginner")

### Conclusion
**NO DISCREPANCIES FOUND** - This action is working correctly and ready for production.

---

## 2. ANAgent Search SMEs ❌ **MAJOR DISCREPANCIES FOUND**

### Test Results
- **Total Tests**: 50 utterances
- **Success Rate**: 0% (0/50 successful)
- **API vs SOQL Match**: Both API and SOQL failing

### Critical Issues Identified

#### Issue 1: Invalid Field References
**API Error**: `No such column 'AE_RANK__c' on entity 'AGENT_SME_ACADEMIES__c'`

**SOQL Error**: `No such column 'Product__c' on entity 'SME_Finder__c'`

#### Issue 2: Object Schema Mismatch
The SME search is referencing fields that don't exist on the target objects:
- `AGENT_SME_ACADEMIES__c.AE_RANK__c` - Field doesn't exist
- `SME_Finder__c.Product__c` - Field doesn't exist  
- `SME_Finder__c.AE_Name__c` - Field doesn't exist
- `SME_Finder__c.OU_Name__c` - Field doesn't exist
- `SME_Finder__c.ACV__c` - Field doesn't exist
- `SME_Finder__c.Academy_Member__c` - Field doesn't exist

#### Issue 3: Complete Functionality Failure
- All 50 test utterances failed
- Both API and direct SOQL queries failed
- No successful searches possible

### Root Cause Analysis
1. **Schema Evolution**: The SME search code appears to be referencing an old schema
2. **Missing Objects**: The expected objects may not exist or have different names
3. **Field Mapping Issues**: Field names in the code don't match actual Salesforce schema

### Impact
- **Severity**: CRITICAL
- **Functionality**: COMPLETELY BROKEN
- **User Experience**: All SME searches fail
- **Business Impact**: Users cannot find Subject Matter Experts

### Recommendations
1. **Immediate**: Disable the SME search action until fixed
2. **Schema Investigation**: Check actual object and field names in Salesforce
3. **Code Update**: Update field references to match current schema
4. **Testing**: Comprehensive testing after fixes

---

## 3. ANAGENT KPI Analysis V5 ✅ **WORKING CORRECTLY**

### Test Results
- **Total Tests**: 50 utterances
- **Success Rate**: 100% (50/50 successful)
- **API vs SOQL Match**: 100% accuracy

### Findings
- ✅ **Perfect Functionality**: All API calls successful with detailed analysis messages
- ✅ **Rich Analysis**: Returns comprehensive KPI analysis with data quality assessment
- ✅ **Multiple Metrics**: ACV, PG, CALLS, MEETINGS, AI_MENTIONS, COVERAGE all work
- ✅ **Complex Filtering**: Supports filtering by country, OU, industry, AE
- ✅ **Aggregation Types**: SUM, AVG, MAX, MIN, COUNT, MEDIAN all supported
- ✅ **Timeframe Support**: CURRENT and PREVIOUS period analysis
- ✅ **Ramp Status Analysis**: Primary use case for analyzing AE performance by ramp status
- ✅ **Per-AE Normalization**: Supports average per AE calculations
- ✅ **Limit Support**: Top N results functionality works correctly

### Sample Analysis Output
```
# KPI Analysis
## Summary
- **Metric**: ACV
- **Timeframe**: CURRENT
- **Grouped By**: COUNTRY
- **Filter**: ou_name__c LIKE '%AMER%'
- **Per-AE Normalized**: No
- **Total Records Found**: 3931

## Data Quality Assessment
✅ Data quality is good for this metric and timeframe
```

### Conclusion
**NO DISCREPANCIES FOUND** - This action is working excellently and ready for production use.

---

## 4. ANAGENT Open Pipe Analysis V3 ✅ **WORKING CORRECTLY**

### Test Results
- **Total Tests**: 50 utterances
- **Success Rate**: 100% (50/50 successful)
- **API vs SOQL Match**: 98% accuracy (1 minor discrepancy)

### Findings
- ✅ **Excellent Functionality**: All API calls successful with extremely detailed analysis messages
- ✅ **Rich Analysis**: Returns comprehensive pipeline analysis with insights and data breakdowns
- ✅ **Multiple Analysis Types**: STAGE_COUNT, DAYS_IN_STAGE, AE_SCORE all work correctly
- ✅ **Complex Grouping**: STAGE, PRODUCT, INDUSTRY, MACRO_SEGMENT, AE, COUNTRY all supported
- ✅ **Advanced Filtering**: Supports complex filter criteria with multiple conditions
- ✅ **Aggregation Types**: SUM, AVG, MAX, MIN, COUNT, MEDIAN all supported
- ✅ **Per-AE Normalization**: Supports average per AE calculations
- ✅ **Limit Support**: Top N results functionality works correctly
- ✅ **Required Parameters**: Properly enforces OU Name or Work Location Country requirement
- ⚠️ **Minor Issue**: One discrepancy where API shows detailed "no records" message but SOQL returns empty (cosmetic difference)

### Sample Analysis Output
```
# Open Pipe Analysis
## Summary
- **OU**: AMER ICE
- **Grouped By**: STAGE
- **Analysis Type**: STAGE_COUNT
- **Per-AE Normalized**: No
- **Total Records Found**: 3458

## Insights
- **02 - Determining Fit**: 827 opportunities
- **03 - Validating Benefits & Value**: 774 opportunities
- **01 - Discovery**: 739 opportunities
```

### Conclusion
**MINIMAL DISCREPANCIES FOUND** - This action is working excellently with only 1 minor cosmetic discrepancy. Ready for production use.

---

## 5. ABAGENT Upsell Analysis ⏳ **PENDING**

### Status
- Awaiting testing
- Will test after Open Pipe Analysis V3

---

## 6. ABAGENT Cross-Sell Analysis ⏳ **PENDING**

### Status
- Awaiting testing
- Will test after Upsell Analysis

---

## 7. AN Agent: Create APM Nomination V2 ⏳ **PENDING**

### Status
- Awaiting testing
- Will test after Cross-Sell Analysis

---

## Summary

### Overall Status
- **Actions Tested**: 2/7
- **Working Correctly**: 1/7 (14.3%)
- **Major Issues**: 1/7 (14.3%)
- **Pending**: 5/7 (71.4%)

### Critical Issues Found
1. **ANAgent Search SMEs**: Complete functionality failure due to schema mismatches

### Next Steps
1. Continue testing remaining actions
2. Document all discrepancies found
3. Prioritize fixes based on severity
4. Create remediation plan for broken actions

---

## Testing Methodology

### For Each Action
1. Create 50 diverse test utterances
2. Test each utterance via API
3. Test equivalent SOQL queries
4. Compare API vs SOQL results
5. Document discrepancies
6. Analyze root causes

### Utterance Categories
- Product-focused searches
- Geographic/OU searches  
- Person/name searches
- Mixed/combination searches
- Edge cases and variations

### Success Criteria
- API returns successful responses
- SOQL queries execute successfully
- API results match SOQL results
- Appropriate error handling for edge cases

---

*Report generated during comprehensive agent action testing*
*Last updated: 2025-01-20*
