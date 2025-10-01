# ✅ Salesforce MCP Integration - Deployment Checklist

## 📋 Pre-Deployment Checklist

### ✅ **Environment Setup**
- [ ] Salesforce sandbox org available
- [ ] Salesforce CLI (sfdx) installed and configured
- [ ] Local MCP server code ready
- [ ] ngrok installed and configured
- [ ] Admin access to Salesforce org

### ✅ **Authentication**
- [ ] Authenticated to sandbox: `sfdx auth:web:login -a MySandbox -r https://test.salesforce.com`
- [ ] Or JWT configured: `sfdx auth:jwt:grant -i <clientId> -f <server.key> -u <username> -r https://test.salesforce.com -a MySandbox`

## 🚀 Deployment Checklist

### ✅ **Step 1: Deploy Components**
```bash
# Run deployment script
./scripts/deploy.sh
```

**Expected Results:**
- [ ] Source deployment successful
- [ ] Tests pass with 100% success rate
- [ ] Permission set assigned successfully
- [ ] No deployment errors

### ✅ **Step 2: Start Local MCP Server**
```bash
# Terminal 1: Start MCP server
python3 mcp_server.py --port 8787 --live
```

**Expected Results:**
- [ ] Server starts on localhost:8787
- [ ] Dry run mode: False
- [ ] Salesforce configured: True
- [ ] No startup errors

### ✅ **Step 3: Start ngrok Tunnel**
```bash
# Terminal 2: Start ngrok
ngrok http 8787
```

**Expected Results:**
- [ ] ngrok tunnel active
- [ ] HTTPS URL generated (e.g., https://abc123.ngrok.io)
- [ ] Web interface accessible at http://127.0.0.1:4040
- [ ] No tunnel errors

### ✅ **Step 4: Update Configuration**

#### Option A: Update Named Credential
- [ ] Navigate to Setup → Named Credentials
- [ ] Find `MCP_OpenPipe`
- [ ] Update URL to ngrok HTTPS URL
- [ ] Save changes

#### Option B: Update Custom Metadata
- [ ] Navigate to Setup → Custom Metadata Types
- [ ] Find `MCP Configuration`
- [ ] Edit `OpenPipe UAT` record
- [ ] Set Base URL to ngrok HTTPS URL
- [ ] Set Mode to ROUTE or ANALYZE
- [ ] Save changes

### ✅ **Step 5: Run Smoke Tests**
```bash
sfdx force:apex:execute -u MySandbox -f scripts/smoke_tests.apex
```

**Expected Results:**
- [ ] ROUTE Test: PASSED
- [ ] ANALYZE Test: PASSED
- [ ] Error Handling Test: PASSED
- [ ] No test failures

## 🧪 UAT Testing Checklist

### ✅ **Test Case 1: ROUTE Mode (Pattern 2)**
**Input**: "Open pipe passed stage 4 in AMER ACC, country = US, top 10."

**Expected Results:**
- [ ] MCP routes to `open_pipe_analyze` tool
- [ ] Returns normalized args: `{ouName: "AMER ACC", minStage: 4, country: "United States", timeFrame: "CURRENT", limitN: 10}`
- [ ] Calls existing Open Pipe Apex with these args
- [ ] Returns structured analysis
- [ ] Response time under 10 seconds

### ✅ **Test Case 2: ANALYZE Mode (Pattern 1)**
**Input**: "AMER ACC, stage 4, current quarter, top 5"

**Expected Results:**
- [ ] MCP analyzes directly
- [ ] Returns analysis results
- [ ] Shows structured summary
- [ ] Response time under 10 seconds

### ✅ **Test Case 3: Error Handling**
**Input**: "Generate pipeline for UKI next quarter"

**Expected Results:**
- [ ] MCP identifies as PipeGen request
- [ ] Returns guidance: "This appears to be a PipeGen or Renewals request. Please use the PipeGen action instead."
- [ ] No exceptions thrown

### ✅ **Test Case 4: Sales Coach/Agent UI**
**Input**: Various natural language queries

**Expected Results:**
- [ ] Agent Action appears in UI
- [ ] Natural language processing works
- [ ] Responses are user-friendly
- [ ] No UI errors

## 🔍 Monitoring Checklist

### ✅ **Debug Logs**
- [ ] Debug logs enabled for user
- [ ] Apex Code: DEBUG
- [ ] System: DEBUG
- [ ] Database: DEBUG

### ✅ **Health Checks**
```bash
# Test MCP server health
curl https://abc123.ngrok.io/health
```

**Expected Results:**
- [ ] Status: healthy
- [ ] Service: open-pipe-mcp
- [ ] dry_run: false
- [ ] sf_configured: true

### ✅ **Network Connectivity**
```bash
# Test route endpoint
curl -X POST https://abc123.ngrok.io/route \
  -H "Content-Type: application/json" \
  -d '{"text": "Open pipe passed stage 4 in AMER ACC"}'
```

**Expected Results:**
- [ ] HTTP 200 response
- [ ] JSON response with tool and args
- [ ] No timeout errors

## 🚨 Troubleshooting Checklist

### ✅ **Common Issues**

#### 401/403 Errors
- [ ] Named Credential URL is correct
- [ ] ngrok tunnel is running
- [ ] MCP server is accessible
- [ ] Network connectivity is good

#### Timeout Errors
- [ ] MCP server is running
- [ ] Network connectivity is good
- [ ] Custom Metadata timeout settings are appropriate
- [ ] No firewall blocking requests

#### Permission Errors
- [ ] Permission set is assigned to user
- [ ] Named Credential access is granted
- [ ] User has Apex class access
- [ ] Flow access is granted

#### ngrok URL Changes
- [ ] Update Named Credential URL
- [ ] Or update Custom Metadata Base URL
- [ ] Restart ngrok if needed
- [ ] Test new URL is accessible

## 📊 Success Criteria

### ✅ **Deployment Success**
- [ ] All components deployed without errors
- [ ] Tests pass with 100% success rate
- [ ] Permission set assigned successfully
- [ ] No deployment warnings

### ✅ **Integration Success**
- [ ] MCP server responds to health checks
- [ ] ngrok tunnel is stable and accessible
- [ ] Named Credential URL is correct
- [ ] Network connectivity is good

### ✅ **UAT Success**
- [ ] ROUTE mode returns normalized args
- [ ] ANALYZE mode returns analysis results
- [ ] Error handling works correctly
- [ ] Sales Coach/Agent UI shows proper responses
- [ ] All test cases pass

### ✅ **Performance Success**
- [ ] Response times under 10 seconds
- [ ] No timeout errors
- [ ] Retry logic works for 5xx errors
- [ ] No memory leaks or performance issues

## 🎯 Post-Deployment Actions

### ✅ **Documentation**
- [ ] Update deployment documentation
- [ ] Record any custom configurations
- [ ] Document troubleshooting steps
- [ ] Update runbooks

### ✅ **Monitoring Setup**
- [ ] Set up monitoring for MCP server
- [ ] Configure alerting for failures
- [ ] Set up logging for audit trail
- [ ] Test monitoring systems

### ✅ **Production Readiness**
- [ ] Update configuration for production
- [ ] Plan production deployment
- [ ] Set up production monitoring
- [ ] Prepare production runbooks

## 🆘 Emergency Procedures

### ✅ **Rollback Plan**
- [ ] Disable Custom Metadata (set IsActive__c = false)
- [ ] Or update Named Credential to fallback URL
- [ ] Test rollback procedures
- [ ] Document rollback steps

### ✅ **Support Contacts**
- [ ] MCP server support contact
- [ ] Salesforce admin contact
- [ ] Network team contact
- [ ] Emergency escalation procedures

## 📝 Final Sign-off

### ✅ **Deployment Sign-off**
- [ ] All deployment steps completed
- [ ] All tests passing
- [ ] UAT completed successfully
- [ ] Documentation updated
- [ ] Monitoring configured

### ✅ **Technical Sign-off**
- [ ] Code review completed
- [ ] Security review completed
- [ ] Performance review completed
- [ ] Architecture review completed

### ✅ **Business Sign-off**
- [ ] UAT completed successfully
- [ ] User acceptance criteria met
- [ ] Business requirements satisfied
- [ ] Go-live approval received

---

## 🎉 Deployment Complete!

**Congratulations!** The Salesforce MCP integration has been successfully deployed and tested. The system is now ready for production use.

**Next Steps:**
1. Monitor system performance
2. Plan production deployment
3. Set up production monitoring
4. Train end users

**Support:**
- For technical issues: Check debug logs and troubleshooting guide
- For business issues: Contact product owner
- For emergency issues: Follow emergency procedures

**Documentation:**
- README_DEPLOY_UAT.md - Complete UAT guide
- SETUP_SALESFORCE_MCP.md - Setup instructions
- DEPLOYMENT_GUIDE.md - Deployment guide
