# Enhanced Open Pipe Analysis - Troubleshooting Guide

## 🚨 Common Issues & Solutions

### 1. "No Data Found" Errors

#### Issue: Agent returns "No data found for AMER ACC"
**Symptoms**:
- Analysis returns 0 records
- Suggests alternative OU names
- No data in output

**Root Causes**:
1. **Field Missing from SOQL Query**: `OPEN_PIPE_OPTY_DAYS_IN_STAGE__C` not included
2. **Incorrect Field Names**: Field API names don't match object schema
3. **Data Isolation**: Test data not accessible to service queries

**Solutions**:
```apex
// 1. Check if field exists in query
String query = 'SELECT Id, Name, OU_NAME__C, OPEN_PIPE_OPTY_DAYS_IN_STAGE__C FROM Agent_Open_Pipe__c WHERE OU_NAME__C = :ou';

// 2. Verify field API names
sf sobject describe -s Agent_Open_Pipe__c --target-org your-org

// 3. Test with real data
sf data query --query "SELECT COUNT(Id) FROM Agent_Open_Pipe__c WHERE OU_NAME__C = 'AMER ACC'"
```

**Prevention**:
- Always include all referenced fields in SOQL queries
- Use `sf sobject describe` to verify field names
- Test with production data, not just test data

### 2. Apex Class Size Limit Exceeded

#### Issue: "Apex class size exceeds 6MB limit"
**Symptoms**:
- Deployment fails with size limit error
- Class file is too large
- Compilation succeeds but deployment fails

**Root Causes**:
1. **Excessive Comments**: Too much documentation in code
2. **Large Methods**: Methods exceed recommended size
3. **Duplicate Code**: Repeated logic instead of utility methods

**Solutions**:
```apex
// 1. Reduce comments (keep essential ones)
/**
 * @description Brief description only
 */
public static String methodName() {
    // Essential comments only
}

// 2. Split large methods
private static String buildAnalysisMessage() {
    String summary = buildExecutiveSummary();
    String results = buildResults();
    return summary + results;
}

// 3. Use utility classes
String normalized = ANAgentNamingNormalizer.normalizeOU(input);
```

**Prevention**:
- Keep comments concise but informative
- Split methods over 50 lines
- Extract common logic to utility classes

### 3. Governor Limit Exceeded

#### Issue: "Too many SOQL queries: 101"
**Symptoms**:
- Analysis fails with governor limit error
- Performance degradation
- Timeout errors

**Root Causes**:
1. **Multiple Queries**: Too many SOQL queries in single transaction
2. **Inefficient Queries**: Queries not optimized
3. **Large Datasets**: Processing too many records

**Solutions**:
```apex
// 1. Optimize queries - combine where possible
String query = 'SELECT Id, Name, OU_NAME__C, OPEN_PIPE_PROD_NM__C FROM Agent_Open_Pipe__c WHERE OU_NAME__C = :ou AND WORK_LOCATION_COUNTRY__C = :country';

// 2. Use appropriate limits
if (analysisType == 'territory') {
    query += ' LIMIT 10000';
} else if (analysisType == 'ae') {
    query += ' LIMIT 2000';
}

// 3. Process in batches
List<Agent_Open_Pipe__c> batch = new List<Agent_Open_Pipe__c>();
for (Integer i = 0; i < records.size(); i += 1000) {
    batch = records.subList(i, Math.min(i + 1000, records.size()));
    processBatch(batch);
}
```

**Prevention**:
- Minimize SOQL queries per transaction
- Use bulk operations
- Implement query caching where appropriate

### 4. Field Reference Errors

#### Issue: "Variable does not exist: OPEN_PIPE_APM_L1__C"
**Symptoms**:
- Compilation errors
- Field not found in object
- Runtime errors when accessing field

**Root Causes**:
1. **Field Doesn't Exist**: Field not in object schema
2. **Wrong API Name**: Incorrect field name
3. **Missing from Query**: Field not selected in SOQL

**Solutions**:
```apex
// 1. Check if field exists
sf sobject describe -s Agent_Open_Pipe__c --target-org your-org | jq '.fields[] | select(.name | contains("APM_L1"))'

// 2. Use correct field name
// If OPEN_PIPE_APM_L1__C doesn't exist, use OPEN_PIPE_APM_L2__C

// 3. Include in SOQL query
String query = 'SELECT Id, OPEN_PIPE_APM_L2__C FROM Agent_Open_Pipe__c WHERE ...';
```

**Prevention**:
- Always verify field names with `sf sobject describe`
- Test field access before using in production
- Use field references consistently

### 5. Test Failures

#### Issue: Test methods failing with assertion errors
**Symptoms**:
- Test assertions failing
- Expected vs actual value mismatches
- Test data isolation issues

**Root Causes**:
1. **Data Isolation**: Test data not accessible to service
2. **Assertion Mismatches**: Expected values don't match actual
3. **Test Setup Issues**: Test data not properly created

**Solutions**:
```apex
// 1. Fix data isolation
@testSetup
static void setupTestData() {
    List<Agent_Open_Pipe__c> testData = new List<Agent_Open_Pipe__c>();
    // Create test data that service can access
    insert testData;
}

// 2. Fix assertions
// Instead of specific values, test for general patterns
System.assert(result.contains('Executive Summary'), 'Should contain Executive Summary');
System.assert(result.contains('Analysis Summary'), 'Should contain Analysis Summary');

// 3. Use realistic test data
Agent_Open_Pipe__c testRecord = new Agent_Open_Pipe__c(
    OU_NAME__C = 'AMER ACC',
    OPEN_PIPE_PROD_NM__C = 'Tableau Server',
    OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C = 100000
);
```

**Prevention**:
- Use `@testSetup` for test data
- Test with realistic data patterns
- Focus on testing logic, not specific output

## 🔍 Debugging Techniques

### 1. Enable Debug Logging
```apex
// Add debug statements
System.debug('Analysis params: ' + params);
System.debug('Query: ' + query);
System.debug('Records found: ' + records.size());
System.debug('Analysis result: ' + result);
```

### 2. Check Salesforce Debug Logs
```bash
# Get recent logs
sf apex get log --target-org your-org

# Get specific log
sf apex get log --log-id 07L000000000000 --target-org your-org
```

### 3. Test Individual Components
```apex
// Test naming normalizer
String normalized = ANAgentNamingNormalizer.normalizeOU('amer-acc');
System.debug('Normalized OU: ' + normalized);

// Test data quality
Map<String, Decimal> quality = assessDataQuality(records);
System.debug('Data quality: ' + quality);

// Test outlier detection
Map<String, Object> outliers = detectStagnationOutliers(records);
System.debug('Outliers: ' + outliers);
```

### 4. Verify Data Access
```bash
# Check record count
sf data query --query "SELECT COUNT(Id) FROM Agent_Open_Pipe__c WHERE OU_NAME__C = 'AMER ACC'"

# Check field values
sf data query --query "SELECT OU_NAME__C, COUNT(Id) FROM Agent_Open_Pipe__c GROUP BY OU_NAME__C"
```

## 🛠️ Performance Optimization

### 1. Query Optimization
```apex
// Use indexed fields first
String query = 'SELECT Id, Name FROM Agent_Open_Pipe__c WHERE OU_NAME__C = :ou AND WORK_LOCATION_COUNTRY__C = :country';

// Select only required fields
String query = 'SELECT Id, OU_NAME__C, OPEN_PIPE_PROD_NM__C FROM Agent_Open_Pipe__c WHERE ...';

// Use appropriate limits
if (analysisType == 'territory') {
    query += ' LIMIT 10000';
}
```

### 2. Memory Management
```apex
// Clear large variables
List<Agent_Open_Pipe__c> records = queryOpenPipeData(params, analysisType);
// Process records
records.clear(); // Clear when done

// Use efficient collections
Map<String, List<Agent_Open_Pipe__c>> groupedRecords = new Map<String, List<Agent_Open_Pipe__c>>();
```

### 3. Caching
```apex
// Cache expensive operations
private static Map<String, String> ouNormalizationCache = new Map<String, String>();

public static String normalizeOU(String input) {
    if (ouNormalizationCache.containsKey(input)) {
        return ouNormalizationCache.get(input);
    }
    
    String normalized = performNormalization(input);
    ouNormalizationCache.put(input, normalized);
    return normalized;
}
```

## 🔒 Security Issues

### 1. Field-Level Security
**Issue**: User can't access required fields
**Solution**: Check field permissions and sharing rules

### 2. Data Access
**Issue**: User can't see records
**Solution**: Verify sharing rules and record access

### 3. API Security
**Issue**: Input validation failures
**Solution**: Implement proper input validation

## 📊 Monitoring & Alerts

### 1. Key Metrics to Monitor
- **Query Performance**: SOQL execution time
- **Memory Usage**: Heap size consumption
- **Error Rates**: Exception frequency
- **Data Quality**: Missing field percentages

### 2. Alert Thresholds
- **Query Time**: > 5 seconds
- **Memory Usage**: > 80% of limit
- **Error Rate**: > 5% of requests
- **Data Quality**: < 70% field completion

### 3. Monitoring Tools
```bash
# Check org health
sf org display --target-org your-org

# Monitor API usage
sf data query --query "SELECT COUNT(Id) FROM Agent_Open_Pipe__c"

# Check performance
sf apex get log --target-org your-org
```

## 🚀 Best Practices

### 1. Development
- Always test with production data patterns
- Use realistic test data
- Implement proper error handling
- Follow Salesforce coding standards

### 2. Deployment
- Deploy in dependency order
- Run tests before deployment
- Monitor deployment logs
- Have rollback plan ready

### 3. Maintenance
- Regular performance monitoring
- Update documentation
- Review error logs
- Optimize based on usage patterns

## 📞 Support Escalation

### When to Escalate
- **Critical Errors**: System completely down
- **Data Loss**: Missing or corrupted data
- **Security Issues**: Unauthorized access
- **Performance**: Severe degradation

### Information to Provide
1. **Error Messages**: Complete error text
2. **Debug Logs**: Relevant log entries
3. **Steps to Reproduce**: Exact sequence
4. **Environment**: Org details and version
5. **Impact**: Business impact assessment

### Contact Information
- **Internal Support**: [Your support contact]
- **Salesforce Support**: [If needed]
- **Documentation**: This troubleshooting guide

---

**Last Updated**: October 2024  
**Version**: 3.0 Enhanced  
**Maintained By**: [Your team name]
