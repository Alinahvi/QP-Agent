# MCP Integration Rollback Guide

## Quick Rollback (Immediate)

### 1. Disable MCP Integration
```sql
-- Set MCP_Config__mdt.IsActive__c = false
UPDATE MCP_Config__mdt SET IsActive__c = false WHERE DeveloperName = 'DEV_Config';
```

### 2. Disable Shadow Mode
```sql
-- Set MCP_Config__mdt.ShadowMode__c = false
UPDATE MCP_Config__mdt SET ShadowMode__c = false WHERE DeveloperName = 'DEV_Config';
```

### 3. Verify Rollback
- All agent utterances will now route through the **Direct path only**
- No MCP server calls will be made
- No performance impact from MCP processing
- All existing functionality preserved

## Complete Rollback (Full Removal)

### 1. Remove Permission Sets
```bash
sf project deploy start --source-dir force-app/main/default/permissionsets/MCP_Integration.permissionset-meta.xml --delete-destructive
```

### 2. Remove MCP Adapter Classes
```bash
sf project deploy start --source-dir force-app/main/default/classes/AN_FuturePipeline_FromMCP.cls --delete-destructive
sf project deploy start --source-dir force-app/main/default/classes/AN_OpenPipeV3_FromMCP.cls --delete-destructive
sf project deploy start --source-dir force-app/main/default/classes/AN_KPI_FromMCP.cls --delete-destructive
sf project deploy start --source-dir force-app/main/default/classes/AN_SearchContent_FromMCP.cls --delete-destructive
sf project deploy start --source-dir force-app/main/default/classes/AN_SearchSME_FromMCP.cls --delete-destructive
sf project deploy start --source-dir force-app/main/default/classes/AN_Workflow_FromMCP.cls --delete-destructive
```

### 3. Remove MCP Router
```bash
sf project deploy start --source-dir force-app/main/default/classes/ANAgentUtteranceRouterViaMCP.cls --delete-destructive
```

### 4. Remove Flows
```bash
sf project deploy start --source-dir force-app/main/default/flows/AgentUtteranceRouterViaMCP_ShadowMode.flow-meta.xml --delete-destructive
sf project deploy start --source-dir force-app/main/default/flows/ShadowModeExecution.flow-meta.xml --delete-destructive
sf project deploy start --source-dir force-app/main/default/flows/ANAgentUtteranceLogger.flow-meta.xml --delete-destructive
```

### 5. Remove Custom Objects
```bash
sf project deploy start --source-dir force-app/main/default/objects/Agent_Utterance_Log__c --delete-destructive
```

### 6. Remove Custom Metadata
```bash
sf project deploy start --source-dir force-app/main/default/objects/MCP_Config__mdt --delete-destructive
```

### 7. Remove Static Resources
```bash
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_FuturePipeline.json --delete-destructive
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_OpenPipeV3.json --delete-destructive
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_KPI.json --delete-destructive
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_Workflow.json --delete-destructive
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_Content.json --delete-destructive
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_SME.json --delete-destructive
```

### 8. Remove Named Credentials
```bash
sf project deploy start --source-dir force-app/main/default/namedCredentials/MCP_Core.namedCredential-meta.xml --delete-destructive
```

## Rollback Verification

### 1. Test Agent Functionality
- Verify all agent utterances work as before
- Check that no MCP-related errors appear in logs
- Confirm performance is back to baseline

### 2. Check System Health
- Review debug logs for any MCP-related errors
- Verify no orphaned records in Agent_Utterance_Log__c
- Confirm all flows are working correctly

### 3. Clean Up Data (Optional)
```sql
-- Delete any MCP-related log records
DELETE FROM Agent_Utterance_Log__c WHERE Execution_Path__c = 'MCP';

-- Delete MCP configuration records
DELETE FROM MCP_Config__mdt WHERE DeveloperName = 'DEV_Config';
```

## Emergency Contacts

- **MCP Integration Team**: [Contact Information]
- **Salesforce Admin**: [Contact Information]
- **On-Call Engineer**: [Contact Information]

## Rollback Timeline

- **Quick Rollback**: < 5 minutes (CMDT change only)
- **Complete Rollback**: 15-30 minutes (full metadata removal)
- **Verification**: 10-15 minutes (testing and validation)

## Notes

- Quick rollback preserves all MCP components for future re-enablement
- Complete rollback removes all MCP components permanently
- Always test rollback in sandbox before production
- Keep rollback documentation updated with any changes