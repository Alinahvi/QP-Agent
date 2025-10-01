# 🚀 Salesforce MCP Integration - UAT Deployment Guide

## Overview

This guide walks you through deploying the Salesforce MCP integration to a sandbox and running comprehensive UAT (User Acceptance Testing) with your local MCP server exposed via ngrok.

## Prerequisites

- ✅ Salesforce sandbox org
- ✅ Local MCP server code
- ✅ ngrok installed and configured
- ✅ Admin access to Salesforce org
- ✅ Salesforce CLI (sfdx) installed

## Step 1: Authentication

### Option A: Web Login (Recommended)
```bash
sfdx auth:web:login -a MySandbox -r https://test.salesforce.com
```

### Option B: JWT (For CI/CD)
```bash
sfdx auth:jwt:grant -i <clientId> -f <server.key> -u <username> -r https://test.salesforce.com -a MySandbox
```

## Step 2: Deploy Components

### Run the deployment script:
```bash
./scripts/deploy.sh
```

This script will:
- ✅ Deploy all Apex classes, flows, permission sets, and metadata
- ✅ Run comprehensive tests
- ✅ Assign permission sets
- ✅ Provide next steps

### Manual deployment (if needed):
```bash
# Deploy source
sfdx force:source:deploy -u MySandbox -p force-app

# Run tests
sfdx force:apex:test:run -u MySandbox -r human -w 20 -c -t ANAgentOpenPipeViaMCPV1Test

# Assign permission set
sfdx force:user:permset:assign -u MySandbox -n MCP_OpenPipe_Analysis
```

## Step 3: Start Local MCP Server

### Terminal 1: Start MCP Server
```bash
# Navigate to project directory
cd /Users/anahvi/Public/Salesforce-vscode/salesforce-dx-project

# Start MCP server in live mode
python3 mcp_server.py --port 8787 --live
```

Expected output:
```
INFO:__main__:Starting MCP server on localhost:8787
INFO:__main__:Dry run mode: False
INFO:__main__:Salesforce configured: True
 * Serving Flask app 'mcp_server'
 * Running on http://localhost:8787
```

### Terminal 2: Start ngrok Tunnel
```bash
# Start ngrok tunnel
ngrok http 8787
```

Expected output:
```
Session Status                online
Account                       your-account
Version                       3.x.x
Region                       United States (us)
Latency                      -
Web Interface                http://127.0.0.1:4040
Forwarding                   https://abc123.ngrok.io -> http://localhost:8787
```

**📝 Note the HTTPS URL**: `https://abc123.ngrok.io` (replace with your actual URL)

## Step 4: Update Configuration

### Option A: Update Named Credential (Recommended)
1. **Navigate to Named Credentials**
   - Go to Setup → Named Credentials
   - Find `MCP_OpenPipe`
   - Click "Edit"

2. **Update URL**
   - Change URL from `https://REPLACE_ME_NGROK.example` to your ngrok URL
   - Example: `https://abc123.ngrok.io`
   - Click "Save"

### Option B: Update Custom Metadata
1. **Navigate to Custom Metadata Types**
   - Go to Setup → Custom Metadata Types
   - Find `MCP Configuration`
   - Click "Manage Records"
   - Click "Edit" on `OpenPipe UAT`

2. **Update Configuration**
   - **Base URL**: `https://abc123.ngrok.io` (your ngrok URL)
   - **Mode**: `ROUTE` (for route + Apex pattern) or `ANALYZE` (for direct analysis)
   - **Is Active**: `true`
   - Click "Save"

## Step 5: Run Smoke Tests

### Automated Smoke Tests
```bash
sfdx force:apex:execute -u MySandbox -f scripts/smoke_tests.apex
```

Expected output:
```
🧪 Starting MCP Open Pipe Analysis Smoke Tests
================================================

🔍 Test 1: ROUTE Mode
---------------------
📤 Sending ROUTE request: Open pipe passed stage 4 in AMER ACC, country = US, top 10.
📥 ROUTE Response:
   Success: true
   Message: Successfully routed to open_pipe_analyze
   Tool: open_pipe_analyze
   OU Name: AMER ACC
   Min Stage: 4
   Country: United States
   Time Frame: CURRENT
   Limit N: 10
✅ ROUTE Test: PASSED

🔍 Test 2: ANALYZE Mode
-----------------------
📤 Sending ANALYZE request: AMER ACC, stage 4, current quarter, top 5
📥 ANALYZE Response:
   Success: true
   Message: Successfully analyzed via MCP
   Response Body Length: 1234
   Response Preview: {"status": "success", "analysis": "..."}
✅ ANALYZE Test: PASSED

🔍 Test 3: Error Handling
-------------------------
📤 Sending invalid request with mode: INVALID_MODE
📥 Error Response:
   Success: false
   Message: Invalid mode. Must be ROUTE or ANALYZE.
✅ Error Handling Test: PASSED

📊 Smoke Test Summary
===================
✅ ROUTE Mode: Tested natural language routing
✅ ANALYZE Mode: Tested direct analysis
✅ Error Handling: Tested invalid input handling
```

## Step 6: Test in Sales Coach/Agent UI

### Navigate to Agent Actions
1. **Go to Sales Coach/Agent**
2. **Find "Open Pipe Analysis (via MCP)" action**
3. **Test with sample utterances**

### Test Cases

#### Test Case 1: ROUTE Mode (Pattern 2)
**Input**: "Open pipe passed stage 4 in AMER ACC, country = US, top 10."

**Expected Flow**:
1. ✅ MCP routes to `open_pipe_analyze` tool
2. ✅ Returns normalized args: `{ouName: "AMER ACC", minStage: 4, country: "United States", timeFrame: "CURRENT", limitN: 10}`
3. ✅ Calls existing Open Pipe Apex with these args
4. ✅ Returns structured analysis

#### Test Case 2: ANALYZE Mode (Pattern 1)
**Input**: "AMER ACC, stage 4, current quarter, top 5"

**Expected Flow**:
1. ✅ MCP analyzes directly
2. ✅ Returns analysis results
3. ✅ Shows structured summary

#### Test Case 3: Error Handling
**Input**: "Generate pipeline for UKI next quarter"

**Expected Flow**:
1. ✅ MCP identifies as PipeGen request
2. ✅ Returns guidance: "This appears to be a PipeGen or Renewals request. Please use the PipeGen action instead."

## Step 7: Monitor and Debug

### Enable Debug Logs
1. **Navigate to Debug Logs**
   - Go to Setup → Debug Logs
   - Click "New Debug Log"

2. **Configure Debug Log**
   - **User**: Select your user
   - **Apex Code**: `DEBUG`
   - **System**: `DEBUG`
   - **Database**: `DEBUG`

3. **Save and Test**

### Check Debug Logs
Look for these log entries:
```
MCP Request - RequestId: REQ_1234567890_12345, CorrelationId: CORR_1234567890_12345, Mode: ROUTE, Config Mode: ROUTE
MCP Using Named Credential URL: callout:MCP_OpenPipe/route
MCP Route Response - Tool: open_pipe_analyze, Args: {"ouName":"AMER ACC","minStage":4}
```

### Health Check
```bash
# Test MCP server health
curl https://abc123.ngrok.io/health

# Test route endpoint
curl -X POST https://abc123.ngrok.io/route \
  -H "Content-Type: application/json" \
  -d '{"text": "Open pipe passed stage 4 in AMER ACC"}'

# Test analyze endpoint
curl -X POST https://abc123.ngrok.io/analyze \
  -H "Content-Type: application/json" \
  -d '{"ouName": "AMER ACC", "minStage": 4, "timeFrame": "CURRENT", "limitN": 10}'
```

## Troubleshooting

### Common Issues

#### 1. **401/403 Errors**
- ✅ Check Named Credential URL is correct
- ✅ Verify ngrok tunnel is running
- ✅ Check MCP server is accessible

#### 2. **Timeout Errors**
- ✅ Check MCP server is running
- ✅ Verify network connectivity
- ✅ Check Custom Metadata timeout settings

#### 3. **Permission Errors**
- ✅ Verify permission set is assigned
- ✅ Check Named Credential access
- ✅ Ensure user has Apex class access

#### 4. **ngrok URL Changes**
- ✅ Update Named Credential URL
- ✅ Or update Custom Metadata Base URL
- ✅ Restart ngrok if needed

### Debug Commands

```bash
# Check ngrok status
ngrok status

# Test local server
curl http://localhost:8787/health

# Test ngrok tunnel
curl https://abc123.ngrok.io/health

# Check Salesforce logs
sfdx force:apex:log:tail -u MySandbox
```

## Success Criteria

### ✅ **Deployment Success**
- All components deployed without errors
- Tests pass with 100% success rate
- Permission set assigned successfully

### ✅ **Integration Success**
- MCP server responds to health checks
- ngrok tunnel is stable and accessible
- Named Credential URL is correct

### ✅ **UAT Success**
- ROUTE mode returns normalized args
- ANALYZE mode returns analysis results
- Error handling works correctly
- Sales Coach/Agent UI shows proper responses

### ✅ **Performance Success**
- Response times under 10 seconds
- No timeout errors
- Retry logic works for 5xx errors

## Next Steps

### Production Deployment
1. **Update configuration** for production MCP server
2. **Deploy to production** org
3. **Update Named Credential** URL
4. **Run production smoke tests**

### Monitoring Setup
1. **Set up monitoring** for MCP server
2. **Configure alerting** for failures
3. **Set up logging** for audit trail

## Support

For issues with:
- **MCP Server**: Check local server logs and health endpoint
- **Salesforce Integration**: Review debug logs and permission sets
- **Network Issues**: Test connectivity between Salesforce and ngrok

The integration is now ready for comprehensive UAT! 🎉

## Quick Reference

### Essential Commands
```bash
# Deploy
./scripts/deploy.sh

# Start MCP
python3 mcp_server.py --port 8787 --live

# Start ngrok
ngrok http 8787

# Update URL (replace with your ngrok URL)
sfdx force:apex:execute -u MySandbox -f scripts/postdeploy_set_url.apex

# Run tests
sfdx force:apex:execute -u MySandbox -f scripts/smoke_tests.apex
```

### Key URLs
- **MCP Server**: http://localhost:8787
- **ngrok Tunnel**: https://abc123.ngrok.io
- **ngrok Dashboard**: http://127.0.0.1:4040
- **Salesforce Setup**: Setup → Named Credentials
