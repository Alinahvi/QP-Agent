# Open Pipe Analysis - 20 Comprehensive UAT Scenarios

## Root Cause Analysis Summary
**ISSUE IDENTIFIED**: The service is working correctly but there may be inconsistent results due to:
1. **Data consistency issues** - 902 records with null product names, 2,483 with null/zero amounts
2. **Opportunity duplication** - Some opportunities have multiple records (up to 10 records per opportunity)
3. **Response format** - Service returns both formatted text AND JSON data

## Expected Results (Based on Direct SOQL Analysis)
For **AMER ACC OU**, the correct top products should be:
1. **Agentforce Conversations - Unlimited Edition**: $92,347,030.91 (161 opportunities)
2. **Customer Data Cloud - Data Services Card (100K Credits)**: $64,159,723.45 (129 opportunities)
3. **Slack Enterprise Plus**: $48,626,416.45 (50 opportunities)
4. **Capped Salesforce Enterprise Subscription - Unlimited Edition**: $41,033,815.37 (17 opportunities)
5. **Revenue Cloud Advanced - Unlimited Edition - LP**: $38,649,797.04 (93 opportunities)

---

## UAT Test Scenarios

### **Scenario 1: Basic Product Performance - Top 1**
**Test**: `show me best product from open pipe ACV in AMER ACC`
**Expected**: Agentforce Conversations - Unlimited Edition ($92.35M)
**Validation**: Should match direct SOQL result exactly

### **Scenario 2: Basic Product Performance - Top 5**
**Test**: `show me top 5 products from open pipe ACV in AMER ACC`
**Expected**: Top 5 products in correct order as listed above
**Validation**: All amounts and opportunity counts should match SOQL

### **Scenario 3: Different OU - AMER REG**
**Test**: `show me best product from open pipe ACV in AMER REG`
**Expected**: Should return different results than AMER ACC
**Validation**: Verify OU filtering is working correctly

### **Scenario 4: Stage Breakdown Analysis**
**Test**: `break down Agentforce Conversations - Unlimited Edition by stage in AMER ACC`
**Expected**: Stage breakdown with proper amounts per stage
**Validation**: Total should equal $92.35M when summed

### **Scenario 5: AE Score Analysis**
**Test**: `show me products with highest AE scores in AMER ACC`
**Expected**: Products sorted by average AE score, not by ACV
**Validation**: Should use AE score for sorting, not amount

### **Scenario 6: Industry Analysis**
**Test**: `show me top industries by open pipe ACV in AMER ACC`
**Expected**: Industries grouped by total ACV
**Validation**: Should group by primary_industry__c field

### **Scenario 7: Country Filtering**
**Test**: `show me best product from open pipe ACV in AMER ACC for United States`
**Expected**: Results filtered by work_location_country__c
**Validation**: Should only include US-based AEs

### **Scenario 8: Stage Filtering**
**Test**: `show me best product from open pipe ACV in AMER ACC for stage 02`
**Expected**: Only opportunities in "02 - Determining Problem, Impact, Ideal" stage
**Validation**: Should filter by open_pipe_opty_stg_nm__c

### **Scenario 9: Large Limit Test**
**Test**: `show me top 20 products from open pipe ACV in AMER ACC`
**Expected**: 20 products in descending order by ACV
**Validation**: Should not hit governor limits

### **Scenario 10: Zero Amount Filtering**
**Test**: `show me products with zero amounts in AMER ACC`
**Expected**: Should handle zero amounts appropriately
**Validation**: Should either exclude or clearly indicate zero amounts

### **Scenario 11: Null Product Handling**
**Test**: Query that would include null products
**Expected**: Should handle null product names gracefully
**Validation**: Should not cause errors or inconsistent results

### **Scenario 12: Duplicate Opportunity Handling**
**Test**: Query for opportunities with multiple records
**Expected**: Should aggregate amounts correctly across duplicate records
**Validation**: Should not double-count amounts

### **Scenario 13: Per-AE Normalization**
**Test**: `show me best product from open pipe ACV in AMER ACC normalized per AE`
**Expected**: Results normalized by number of AEs
**Validation**: Should use perAENormalize=true logic

### **Scenario 14: Manager Analysis**
**Test**: `show me top managers by open pipe ACV in AMER ACC`
**Expected**: Results grouped by emp_mgr_nm__c
**Validation**: Should group by manager name

### **Scenario 15: Ramp Status Analysis**
**Test**: `show me products by ramp status in AMER ACC`
**Expected**: Results grouped by ramp_status__c
**Validation**: Should include ramp status information

### **Scenario 16: Days in Stage Analysis**
**Test**: `show me average days in stage for products in AMER ACC`
**Expected**: Should use realistic aggregation with outlier filtering
**Validation**: Should cap outliers at 540 days

### **Scenario 17: Mixed Filtering**
**Test**: `show me best product from open pipe ACV in AMER ACC for stage 03 and United States`
**Expected**: Results filtered by both stage and country
**Validation**: Should apply multiple filters correctly

### **Scenario 18: Edge Case - Very Small Limit**
**Test**: `show me top 1 product from open pipe ACV in AMER ACC`
**Expected**: Should return exactly 1 product
**Validation**: Should not return more than requested

### **Scenario 19: Edge Case - Large Dataset**
**Test**: `show me all products from open pipe ACV in SMB - AMER SMB` (largest OU)
**Expected**: Should handle large dataset without errors
**Validation**: Should not hit governor limits

### **Scenario 20: Consistency Test**
**Test**: Run same query 5 times in a row
**Expected**: Identical results each time
**Validation**: Should not show random/inconsistent results

---

## Direct SOQL Queries for Validation

### Query 1: Top Products by ACV (AMER ACC)
```sql
SELECT open_pipe_prod_nm__c product, 
       COUNT(Id) record_count,
       SUM(open_pipe_original_openpipe_alloc_amt__c) total_amount,
       AVG(open_pipe_ae_score__c) avg_ae_score,
       COUNT_DISTINCT(open_pipe_opty_nm__c) opp_count
FROM Agent_Open_Pipe__c 
WHERE ou_name__c = 'AMER ACC'
AND open_pipe_original_openpipe_alloc_amt__c > 0
AND open_pipe_prod_nm__c != null
GROUP BY open_pipe_prod_nm__c
ORDER BY SUM(open_pipe_original_openpipe_alloc_amt__c) DESC
LIMIT 10
```

### Query 2: Data Quality Check
```sql
SELECT 
  COUNT(Id) total_records,
  COUNT(CASE WHEN open_pipe_prod_nm__c IS NULL OR open_pipe_prod_nm__c = '' THEN 1 END) null_products,
  COUNT(CASE WHEN open_pipe_original_openpipe_alloc_amt__c IS NULL OR open_pipe_original_openpipe_alloc_amt__c <= 0 THEN 1 END) null_amounts,
  COUNT_DISTINCT(open_pipe_opty_nm__c) unique_opportunities
FROM Agent_Open_Pipe__c 
WHERE ou_name__c = 'AMER ACC'
```

### Query 3: Duplicate Opportunities
```sql
SELECT open_pipe_opty_nm__c, COUNT(Id) 
FROM Agent_Open_Pipe__c 
WHERE ou_name__c = 'AMER ACC'
GROUP BY open_pipe_opty_nm__c
HAVING COUNT(Id) > 1
ORDER BY COUNT(Id) DESC
LIMIT 10
```

---

## Expected Service Response Format
The service should return a formatted message like:
```
# Open Pipe Analysis

## Summary
- **OU**: AMER ACC
- **Grouped By**: PRODUCT
- **Analysis Type**: PRODUCT_PERFORMANCE
- **Per-AE Normalized**: No
- **Total Records Found**: 9392
- **Limit Applied**: 1

## Insights
- **Agentforce Conversations - Unlimited Edition**: Total Value: $92347030.91 (161 opportunities), Average AE Score: 3.10

## Limits & Counts
- **Total Records Found**: 9392
- **Records Shown**: 6909 records
- **Limit Applied**: 1

## Data (JSON)
```json
{...}
```
```

---

## Success Criteria
1. **Consistency**: Same query returns same results every time
2. **Accuracy**: Results match direct SOQL queries exactly
3. **Performance**: Queries complete within reasonable time
4. **Format**: Response is properly formatted for agent consumption
5. **Error Handling**: Graceful handling of edge cases and invalid inputs
