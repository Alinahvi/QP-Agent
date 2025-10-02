# Enhanced Open Pipe Analysis - Deployment Guide

## Prerequisites

### Salesforce Org Requirements
- **API Version**: 58.0 or higher
- **Edition**: Enterprise, Unlimited, or Developer
- **Custom Objects**: `Agent_Open_Pipe__c` with 58K+ records
- **Lookup Objects**: `Learner_Profile__c` for OU/Country/Segment data

### Required Permissions
- **System Administrator** or **Customize Application** permission
- **Modify All Data** permission for deployment
- **View All Data** permission for testing

## 🚀 Step-by-Step Deployment

### Step 1: Pre-Deployment Validation

#### 1.1 Verify Object Exists
```bash
# Check if Agent_Open_Pipe__c exists
sf sobject describe -s Agent_Open_Pipe__c --target-org your-org-alias
```

#### 1.2 Verify Data Volume
```bash
# Check record count
sf data query --query "SELECT COUNT(Id) FROM Agent_Open_Pipe__c" --target-org your-org-alias
```

#### 1.3 Check Required Fields
```bash
# Verify key fields exist
sf sobject describe -s Agent_Open_Pipe__c --target-org your-org-alias | jq '.fields[] | select(.name | contains("OPEN_PIPE")) | .name'
```

### Step 2: Deploy Apex Classes

#### 2.1 Deploy Core Classes
```bash
# Deploy in dependency order
sf project deploy start --source-dir force-app/main/default/classes/ANAgentNamingNormalizer.cls --target-org your-org-alias
sf project deploy start --source-dir force-app/main/default/classes/ANAgentOpenPipeAnalysisV3ServiceEnhanced.cls --target-org your-org-alias
sf project deploy start --source-dir force-app/main/default/classes/ANAgentOpenPipeAnalysisV3Handler.cls --target-org your-org-alias
```

#### 2.2 Deploy Test Classes
```bash
# Deploy test classes
sf project deploy start --source-dir force-app/main/default/classes/ANAgentNamingNormalizerTest.cls --target-org your-org-alias
sf project deploy start --source-dir force-app/main/default/classes/OpenPipeTestEnhanced1.cls --target-org your-org-alias
```

### Step 3: Run Tests

#### 3.1 Unit Tests
```bash
# Test naming normalizer
sf apex run test --class-names ANAgentNamingNormalizerTest --target-org your-org-alias

# Test enhanced service
sf apex run test --class-names OpenPipeTestEnhanced1 --target-org your-org-alias
```

#### 3.2 Integration Tests
```bash
# Test with real data
sf apex run --file test_integration.apex --target-org your-org-alias
```

### Step 4: Configure Permissions

#### 4.1 Create Permission Set
```xml
<!-- Create permission set for Open Pipe Analysis -->
<PermissionSet>
    <label>Open Pipe Analysis Access</label>
    <description>Access to Open Pipe Analysis features</description>
    <objectPermissions>
        <object>Agent_Open_Pipe__c</object>
        <allowRead>true</allowRead>
        <allowCreate>false</allowCreate>
        <allowEdit>false</allowEdit>
        <allowDelete>false</allowDelete>
    </objectPermissions>
    <classAccesses>
        <apexClass>ANAgentOpenPipeAnalysisV3Handler</apexClass>
        <enabled>true</enabled>
    </classAccesses>
</PermissionSet>
```

#### 4.2 Assign to Users
```bash
# Assign permission set to users
sf data create record --sobject PermissionSetAssignment --values "PermissionSetId=0PS000000000000,AssigneeId=005000000000000" --target-org your-org-alias
```

### Step 5: Verify Deployment

#### 5.1 Test Basic Functionality
```apex
// Test basic analysis
Map<String, Object> params = new Map<String, Object>{
    'ou' => 'AMER ACC',
    'analysisType' => 'territory'
};

String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
System.debug('Analysis result: ' + result);
```

#### 5.2 Test Context Resolution
```apex
// Test naming normalizer
String normalizedOU = ANAgentNamingNormalizer.normalizeOU('amer-acc');
String normalizedStage = ANAgentNamingNormalizer.normalizeStage('stage 2');
System.debug('Normalized OU: ' + normalizedOU);
System.debug('Normalized Stage: ' + normalizedStage);
```

## 🔧 Configuration

### Environment Variables
```bash
# Set org alias
export SF_ORG_ALIAS="your-org-alias"

# Set API version
export SF_API_VERSION="58.0"
```

### Custom Settings (Optional)
```apex
// Configure analysis limits
OpenPipeAnalysisSettings__c settings = new OpenPipeAnalysisSettings__c();
settings.MaxRecords__c = 10000;
settings.EnableOutlierDetection__c = true;
settings.StagnationThreshold__c = 30;
insert settings;
```

## 🚨 Troubleshooting

### Common Deployment Issues

#### Issue 1: Apex Class Size Limit
**Error**: `Apex class size exceeds 6MB limit`
**Solution**: 
- Reduce comments in service class
- Split large methods into smaller ones
- Use utility classes for common functions

#### Issue 2: Missing Field References
**Error**: `Variable does not exist: OPEN_PIPE_APM_L1__C`
**Solution**:
- Verify field exists in object schema
- Update field references in code
- Check field API names

#### Issue 3: Governor Limits
**Error**: `Too many SOQL queries: 101`
**Solution**:
- Optimize SOQL queries
- Use bulk operations
- Implement query caching

### Debug Commands
```bash
# Check deployment status
sf project deploy report --target-org your-org-alias

# View debug logs
sf apex get log --log-id 07L000000000000 --target-org your-org-alias

# Test specific method
sf apex run --file test_method.apex --target-org your-org-alias
```

## 📊 Performance Optimization

### Query Optimization
- **Use Indexed Fields**: Filter on indexed fields first
- **Limit Results**: Use appropriate LIMIT clauses
- **Selective Fields**: Only select required fields

### Memory Management
- **Bulk Processing**: Process records in batches
- **Variable Cleanup**: Clear large variables when done
- **Collection Optimization**: Use appropriate collection types

## 🔒 Security Considerations

### Data Access
- **Field-Level Security**: Respects FLS settings
- **Sharing Rules**: Follows org sharing model
- **User Context**: Runs in user's security context

### API Security
- **Input Validation**: Validates all input parameters
- **SQL Injection**: Uses parameterized queries
- **XSS Protection**: Sanitizes output data

## 📈 Monitoring

### Key Metrics
- **Query Performance**: Monitor SOQL execution time
- **Memory Usage**: Track heap size usage
- **Error Rates**: Monitor exception frequency

### Logging
```apex
// Enable debug logging
System.debug(LoggingLevel.INFO, 'Analysis started for OU: ' + ou);
System.debug(LoggingLevel.INFO, 'Records found: ' + records.size());
System.debug(LoggingLevel.INFO, 'Analysis completed in: ' + (System.currentTimeMillis() - startTime) + 'ms');
```

## 🔄 Rollback Plan

### If Deployment Fails
1. **Check Logs**: Review deployment logs for errors
2. **Fix Issues**: Address compilation or test failures
3. **Redeploy**: Attempt deployment again
4. **Rollback**: If necessary, revert to previous version

### If System Issues Occur
1. **Disable Features**: Turn off problematic features
2. **Check Data**: Verify data integrity
3. **Monitor Performance**: Watch for performance issues
4. **Contact Support**: Escalate if needed

## ✅ Post-Deployment Checklist

- [ ] All Apex classes deployed successfully
- [ ] All tests passing
- [ ] Permission sets configured
- [ ] Basic functionality tested
- [ ] Context resolution working
- [ ] Error handling verified
- [ ] Performance acceptable
- [ ] Security settings correct
- [ ] Documentation updated
- [ ] Team trained on new features

---

**Deployment Date**: ___________  
**Deployed By**: ___________  
**Org Alias**: ___________  
**Version**: 3.0 Enhanced
