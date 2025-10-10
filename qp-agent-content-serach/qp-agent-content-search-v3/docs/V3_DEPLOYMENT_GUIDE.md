# V3 Deployment Guide

## 📋 Pre-Deployment Checklist

### **1. Environment Verification**
```bash
# Verify SF CLI installation
sf --version

# Verify org connection
sf org display --target-org <your-org-alias>

# Check current user permissions
sf data query --query "SELECT Id, Name, Profile.Name FROM User WHERE Id = '$User.Id'"
```

### **2. Object Verification**
```bash
# Verify required objects exist
sf data query --query "SELECT COUNT() FROM Course__c LIMIT 1"
sf data query --query "SELECT COUNT() FROM Asset__c LIMIT 1"
sf data query --query "SELECT COUNT() FROM Curriculum__c LIMIT 1"
sf data query --query "SELECT COUNT() FROM Assigned_Course__c LIMIT 1"
sf data query --query "SELECT COUNT() FROM Agent_Consensu__c LIMIT 1"
```

### **3. Field Verification**
```bash
# Verify CSAT field (optional but recommended)
sf data query --query "SELECT CSAT__c FROM Course__c LIMIT 1"

# Verify Status fields
sf data query --query "SELECT Status__c FROM Course__c WHERE Status__c = 'Active' LIMIT 1"
```

### **4. Dependencies Check**
```bash
# Verify ANAgentConsensusContentSearchService exists
sf apex run --file check_dependencies.apex

# Contents of check_dependencies.apex:
# System.debug('Checking dependencies...');
# try {
#     List<ANAgentConsensusContentSearchService.ConsensusContent> test = 
#         ANAgentConsensusContentSearchService.searchBasic('test', 1);
#     System.debug('✅ Consensus service available');
# } catch (Exception e) {
#     System.debug('❌ Consensus service NOT available: ' + e.getMessage());
# }
```

---

## 🚀 Deployment Steps

### **Step 1: Backup V2 (if exists)**
```bash
# Create backup directory
mkdir -p backup/v2-$(date +%Y%m%d)

# Copy V2 files
cp force-app/main/default/classes/ANAgentContentSearchHandlerV2.cls backup/v2-$(date +%Y%m%d)/
cp force-app/main/default/classes/ANAgentContentSearchServiceV2.cls backup/v2-$(date +%Y%m%d)/

# Commit backup to git
git add backup/
git commit -m "Backup V2 before deploying V3"
```

### **Step 2: Deploy Service (Required First)**
```bash
# Deploy service class first (handler depends on it)
sf project deploy start \
  --source-dir force-app/main/default/classes \
  --metadata ApexClass:ANAgentContentSearchServiceV3 \
  --test-level NoTestRun \
  --wait 10

# Verify deployment
sf data query --query "SELECT Name, ApiVersion, Status FROM ApexClass WHERE Name = 'ANAgentContentSearchServiceV3'"
```

**Expected Output**:
```
Deploying... Done
Status: Succeeded
Component Deployed: 1
```

### **Step 3: Deploy Handler**
```bash
# Deploy handler class
sf project deploy start \
  --source-dir force-app/main/default/classes \
  --metadata ApexClass:ANAgentContentSearchHandlerV3 \
  --test-level NoTestRun \
  --wait 10

# Verify deployment
sf data query --query "SELECT Name, ApiVersion, Status FROM ApexClass WHERE Name = 'ANAgentContentSearchHandlerV3'"
```

### **Step 4: Verify Invocable Method**
```bash
# Create test file: test_v3_invocable.apex
cat > test_v3_invocable.apex << 'EOF'
ANAgentContentSearchHandlerV3.ContentSearchRequest req = 
    new ANAgentContentSearchHandlerV3.ContentSearchRequest();
req.searchTerm = 'Test';
req.searchMode = 'AUTO';

List<ANAgentContentSearchHandlerV3.ContentSearchResponse> responses = 
    ANAgentContentSearchHandlerV3.searchContent(
        new List<ANAgentContentSearchHandlerV3.ContentSearchRequest>{req}
    );

System.debug('✅ V3 Invocable Method Response:');
System.debug(responses[0].message);
EOF

# Run test
sf apex run --file test_v3_invocable.apex
```

**Expected Output**: Message with formatted content (HEADER → SUMMARY → INSIGHTS → etc.)

---

## 🔧 Agent Builder Configuration

### **Step 5: Remove Old Action (if V2 exists)**
1. Open Agent Builder
2. Navigate to Actions
3. Find `ANAgent Search Content V2` action
4. Click **Remove**
5. Click **Save**
6. **Close the tab completely** (force cache refresh)

### **Step 6: Add V3 Action**
1. **Reopen Agent Builder** (important for schema refresh)
2. Navigate to Actions
3. Click **+ Add Action**
4. Select **Apex**
5. Search for `ANAgent Search Content V3`
6. Click **Add**
7. Configure parameters:
   - `searchTerm` → Required: Yes, User can edit: Yes
   - `contentType` → Required: No, User can edit: Yes
   - `searchMode` → Required: No, User can edit: Yes
   - `userUtterance` → Required: No, User can edit: Yes
8. Click **Save**

### **Step 7: Update Agent Instructions (Optional)**
```markdown
When users ask about courses, training, content, or demos:

1. Use the "ANAgent Search Content V3" action
2. Extract the main product/topic from their question as searchTerm
3. Let AUTO mode handle routing (or use explicit modes if requested)
4. Present the formatted message directly to the user

Examples:
- "Show me Tableau courses" → searchTerm: "Tableau", searchMode: "AUTO"
- "Find Data Cloud demos" → searchTerm: "Data Cloud", searchMode: "CONSENSUS"
- "Do lifecycle analysis on Sales Cloud content" → searchTerm: "Sales Cloud", searchMode: "ACT"
```

---

## 🧪 Testing & Validation

### **Step 8: Unit Testing**
```apex
// Test file: test_v3_comprehensive.apex

System.debug('=== TEST 1: ACT Search ===');
ANAgentContentSearchHandlerV3.ContentSearchRequest req1 = 
    new ANAgentContentSearchHandlerV3.ContentSearchRequest();
req1.searchTerm = 'Sales Cloud';
req1.searchMode = 'ACT';
List<ANAgentContentSearchHandlerV3.ContentSearchResponse> resp1 = 
    ANAgentContentSearchHandlerV3.searchContent(new List<ANAgentContentSearchHandlerV3.ContentSearchRequest>{req1});
System.assert(resp1[0].message.contains('ACT LEARNING CONTENT'));

System.debug('\n=== TEST 2: AUTO Routing ===');
ANAgentContentSearchHandlerV3.ContentSearchRequest req2 = 
    new ANAgentContentSearchHandlerV3.ContentSearchRequest();
req2.searchTerm = 'Demo';
req2.searchMode = 'AUTO';
req2.userUtterance = 'Show me demo videos';
List<ANAgentContentSearchHandlerV3.ContentSearchResponse> resp2 = 
    ANAgentContentSearchHandlerV3.searchContent(new List<ANAgentContentSearchHandlerV3.ContentSearchRequest>{req2});
System.debug(resp2[0].message);

System.debug('\n=== TEST 3: Lifecycle Analysis ===');
ANAgentContentSearchHandlerV3.ContentSearchRequest req3 = 
    new ANAgentContentSearchHandlerV3.ContentSearchRequest();
req3.searchTerm = 'Tableau';
req3.searchMode = 'ACT';
req3.userUtterance = 'Do lifecycle analysis on Tableau courses';
List<ANAgentContentSearchHandlerV3.ContentSearchResponse> resp3 = 
    ANAgentContentSearchHandlerV3.searchContent(new List<ANAgentContentSearchHandlerV3.ContentSearchRequest>{req3});
System.assert(resp3[0].message.contains('INSIGHTS'));
System.assert(resp3[0].message.contains('Lifecycle Analysis'));

System.debug('\n✅ All tests passed!');
```

### **Step 9: Agent Testing**
1. Open Agent chat interface
2. Test utterances:
   - "Show me Tableau courses"
   - "Find Data Cloud demos"
   - "Do a lifecycle analysis on Sales Cloud content"
   - "Search for Marketing Cloud training"
3. Verify agent response contains formatted content
4. Check that all sections are present (SUMMARY, INSIGHTS, DETAILS, etc.)

---

## 📊 Post-Deployment Verification

### **Step 10: Performance Check**
```apex
// Test file: test_v3_performance.apex

Long startTime = System.currentTimeMillis();

ANAgentContentSearchHandlerV3.ContentSearchRequest req = 
    new ANAgentContentSearchHandlerV3.ContentSearchRequest();
req.searchTerm = 'Cloud';
req.searchMode = 'BOTH';

List<ANAgentContentSearchHandlerV3.ContentSearchResponse> responses = 
    ANAgentContentSearchHandlerV3.searchContent(new List<ANAgentContentSearchHandlerV3.ContentSearchRequest>{req});

Long endTime = System.currentTimeMillis();
Long executionTime = endTime - startTime;

System.debug('Execution time: ' + executionTime + 'ms');
System.debug('Response size: ' + responses[0].message.length() + ' characters');
System.assert(executionTime < 5000, 'Should complete in <5 seconds');
```

### **Step 11: Governor Limits Check**
```apex
// Test file: test_v3_governor_limits.apex

Limits.startTest();

ANAgentContentSearchHandlerV3.ContentSearchRequest req = 
    new ANAgentContentSearchHandlerV3.ContentSearchRequest();
req.searchTerm = 'Test';
req.searchMode = 'BOTH';

List<ANAgentContentSearchHandlerV3.ContentSearchResponse> responses = 
    ANAgentContentSearchHandlerV3.searchContent(new List<ANAgentContentSearchHandlerV3.ContentSearchRequest>{req});

System.debug('SOQL Queries Used: ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
System.debug('CPU Time Used: ' + Limits.getCpuTime() + ' / ' + Limits.getLimitCpuTime());
System.debug('Heap Size Used: ' + Limits.getHeapSize() + ' / ' + Limits.getLimitHeapSize());

Limits.stopTest();
```

### **Step 12: Security Check**
```bash
# Verify stripInaccessible is being used
sf data query --query "SELECT Body FROM ApexClass WHERE Name = 'ANAgentContentSearchServiceV3'" | grep -i "stripInaccessible"

# Expected: Should find "Security.stripInaccessible"
```

---

## 🔄 Rollback Procedure

### **If Issues Occur**
```bash
# Option 1: Quick rollback to V2
sf project deploy start \
  --metadata ApexClass:ANAgentContentSearchHandlerV2 \
  --test-level NoTestRun

# Update Agent Builder to use V2 action

# Option 2: Delete V3
sf project delete source \
  --metadata ApexClass:ANAgentContentSearchHandlerV3,ApexClass:ANAgentContentSearchServiceV3 \
  --no-prompt

# Option 3: Restore from backup
cp backup/v2-YYYYMMDD/* force-app/main/default/classes/
sf project deploy start --source-dir force-app/main/default/classes
```

---

## 🔐 Permission Set Configuration

### **Step 13: Add Classes to Permission Set**
```bash
# If you have an Agent Integration User permission set
sf data query --query "SELECT Id, Name FROM PermissionSet WHERE Name LIKE '%Agent%'"

# Add classes to permission set via Setup UI or metadata
```

**Permission Set XML** (if using metadata):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <classAccesses>
        <apexClass>ANAgentContentSearchHandlerV3</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>ANAgentContentSearchServiceV3</apexClass>
        <enabled>true</enabled>
    </classAccesses>
</PermissionSet>
```

---

## 📈 Monitoring

### **Step 14: Setup Monitoring**
```apex
// Create custom log object or use Debug Logs

// Add logging in service (already included):
System.debug('Error searching ' + objectName + ': ' + e.getMessage());
System.debug('Error populating learner count data: ' + e.getMessage());
```

### **Dashboard Metrics** (optional)
- Number of searches per day
- Average execution time
- Most searched terms
- Error rate

---

## ✅ Deployment Checklist

- [ ] Prerequisites verified
- [ ] Objects and fields confirmed
- [ ] Dependencies checked
- [ ] V2 backed up (if exists)
- [ ] Service deployed successfully
- [ ] Handler deployed successfully
- [ ] Invocable method tested
- [ ] Agent Builder updated
- [ ] Old action removed (if V2)
- [ ] New V3 action added
- [ ] Unit tests passed
- [ ] Agent tests passed
- [ ] Performance validated (<5s execution)
- [ ] Governor limits checked
- [ ] Security verified (stripInaccessible)
- [ ] Permission sets updated
- [ ] Monitoring setup
- [ ] Documentation updated

---

## 🎯 Success Criteria

✅ **Deployment Successful If**:
1. Both classes deploy without errors
2. Invocable method appears in Agent Builder
3. Agent successfully calls the action
4. Response contains formatted message with all sections
5. Performance <5 seconds for typical searches
6. Governor limits well within bounds (<10 SOQL queries)
7. Security checks pass (stripInaccessible used)

---

## 📞 Support

### **Deployment Issues**
- Check SF CLI version: `sf --version`
- Verify org connection: `sf org display`
- Review deployment logs
- Check debug logs for errors

### **Agent Issues**
- Force schema refresh: Remove action → Save → Close tab → Reopen → Add action
- Clear browser cache
- Check agent permissions
- Review agent debug logs

---

**Deployment Guide**: ANAgent Search Content V3  
**Version**: 1.0  
**Last Updated**: October 9, 2025  
**Status**: Production Ready ✅

