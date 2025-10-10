# V2 Removal Instructions

## ⚠️ **IMPORTANT: Remove V2 Action from Agent Builder First**

V2 cannot be deleted from the org while it's still referenced by an Agent Builder action.

---

## 🔴 **Error Encountered**

```
Error: ANAgentContentSearchHandlerV2 is referenced elsewhere in Salesforce.
Remove the usage and try again.
Referenced by: Generative AI Function Definition - ANAgent_Search_Content_V2_3
```

**Reason**: The Agent Builder action is still using V2 handler.

---

## ✅ **Step-by-Step Removal Process**

### **Step 1: Remove V2 Action from Agent Builder** (REQUIRED)

1. Open **Agent Builder** (Setup → Einstein → Agent Builder)
2. Select your agent
3. Navigate to **Actions** tab
4. Find `ANAgent Search Content V2` (or similar name)
5. Click **Remove** or **Delete**
6. Click **Save**
7. **Close the Agent Builder tab completely**

### **Step 2: Add V3 Action**

1. **Reopen Agent Builder** (important for schema refresh)
2. Navigate to **Actions** tab
3. Click **+ Add Action**
4. Select **Apex Action**
5. Search for `ANAgent Search Content V3`
6. Click **Add**
7. Configure parameters:
   - `searchTerm` → Required: Yes
   - `contentType` → Required: No
   - `searchMode` → Required: No (defaults to AUTO)
   - `userUtterance` → Required: No
8. Click **Save**

### **Step 3: Test V3 Action in Agent**

Test with these utterances:
- "Show me Tableau courses"
- "Find Data Cloud demos"
- "Do lifecycle analysis on Sales Cloud content"

Verify agent receives formatted message with all sections.

### **Step 4: Remove V2 from Salesforce Org**

Once V2 action is removed from Agent Builder:

```bash
# Delete V2 from org
cd /Users/anahvi/Public/Salesforce-vscode/salesforce-dx-project

sf project delete source \
  --metadata ApexClass:ANAgentContentSearchHandlerV2,ApexClass:ANAgentContentSearchServiceV2 \
  --no-prompt \
  --target-org anahvi@readiness.salesforce.com.innovation
```

**Expected Output**:
```
Status: Succeeded
Deleted Source:
- ANAgentContentSearchHandlerV2
- ANAgentContentSearchHandlerV2.cls-meta.xml
- ANAgentContentSearchServiceV2
- ANAgentContentSearchServiceV2.cls-meta.xml
```

### **Step 5: Remove V2 Files from Local Repository**

```bash
# Delete V2 files locally
rm force-app/main/default/classes/ANAgentContentSearchHandlerV2.cls
rm force-app/main/default/classes/ANAgentContentSearchHandlerV2.cls-meta.xml
rm force-app/main/default/classes/ANAgentContentSearchServiceV2.cls
rm force-app/main/default/classes/ANAgentContentSearchServiceV2.cls-meta.xml

# Verify deletion
ls force-app/main/default/classes/ANAgentContentSearch*V2*
# Should return: No such file or directory
```

### **Step 6: Verify V3 Dependencies Still Work**

```apex
// Test that V3 still works after V2 removal

ANAgentContentSearchHandlerV3.ContentSearchRequest req = 
    new ANAgentContentSearchHandlerV3.ContentSearchRequest();
req.searchTerm = 'Test';
req.searchMode = 'ACT';

List<ANAgentContentSearchHandlerV3.ContentSearchResponse> responses = 
    ANAgentContentSearchHandlerV3.searchContent(
        new List<ANAgentContentSearchHandlerV3.ContentSearchRequest>{req}
    );

System.assert(responses[0].message.contains('ACT LEARNING CONTENT'));
System.debug('✅ V3 still working after V2 removal');
```

---

## 🔒 **Classes to KEEP** (V3 Dependencies)

Do **NOT** remove these classes - V3 depends on them:

| Class | Why V3 Needs It |
|-------|----------------|
| `ANAgentConsensusContentSearchService` | ✅ V3 uses this for Consensus search |
| `Course__c`, `Asset__c`, `Curriculum__c` | ✅ Data objects |
| `Assigned_Course__c` | ✅ Enrollment tracking |
| `Agent_Consensu__c` | ✅ Consensus demos |

---

## ⚠️ **Troubleshooting**

### **"Cannot delete - still referenced"**
- **Cause**: Action still in Agent Builder
- **Fix**: Complete Step 1 above (remove action from Agent Builder)

### **"Agent not finding V3 action"**
- **Cause**: Schema cache not refreshed
- **Fix**: Remove old action → Save → Close tab → Reopen → Add V3

### **"V3 broken after V2 removal"**
- **Cause**: Dependency deleted
- **Fix**: Check ANAgentConsensusContentSearchService still exists
  ```bash
  sf data query --query "SELECT Name FROM ApexClass WHERE Name = 'ANAgentConsensusContentSearchService'"
  ```

---

## 📋 **V2 Removal Checklist**

- [ ] V3 deployed and tested
- [ ] V3 action tested in Agent Builder
- [ ] V2 action removed from Agent Builder
- [ ] Agent Builder saved and closed
- [ ] V3 action added to Agent Builder
- [ ] V3 tested in agent chat
- [ ] V2 deleted from Salesforce org
- [ ] V2 files deleted from local repository
- [ ] V3 re-tested to ensure dependencies intact
- [ ] Documentation updated

---

## 🎯 **Expected State After Removal**

### **In Salesforce Org**
```
ApexClass:
✅ ANAgentContentSearchHandlerV3
✅ ANAgentContentSearchServiceV3
✅ ANAgentConsensusContentSearchService (dependency - keep!)
❌ ANAgentContentSearchHandlerV2 (removed)
❌ ANAgentContentSearchServiceV2 (removed)
```

### **In Local Repository**
```
force-app/main/default/classes/
✅ ANAgentContentSearchHandlerV3.cls
✅ ANAgentContentSearchServiceV3.cls
✅ ANAgentConsensusContentSearchService.cls (dependency - keep!)
❌ ANAgentContentSearchHandlerV2.cls (deleted)
❌ ANAgentContentSearchServiceV2.cls (deleted)
```

### **In GitHub**
```
qp-agent-content-search-v2/  (archived - keep for reference)
qp-agent-content-search-v3/  (active - latest version)
```

---

## 📞 **Need Help?**

If V2 removal fails:
1. Check Agent Builder for any references
2. Search for V2 usage: Setup → Search → "ANAgentContentSearchHandlerV2"
3. Remove all references
4. Try deletion again

---

**Document**: V2 Removal Instructions  
**Version**: 1.0  
**Created**: October 9, 2025  
**Status**: Manual steps required

