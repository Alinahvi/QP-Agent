# 🚀 Salesforce MCP Integration - Deployment Guide

## Overview

This guide walks you through deploying the Salesforce MCP integration to a sandbox and running it live with your local MCP server behind ngrok.

## Prerequisites

- Salesforce sandbox org
- Local MCP server running
- ngrok installed and configured
- Admin access to Salesforce org

## Step 1: Deploy Components to Sandbox

### Deploy Apex Classes
```bash
# Deploy the main Invocable class
sfdx force:source:deploy -p force-app/main/default/classes/ANAgentOpenPipeViaMCPV1.cls

# Deploy the test class
sfdx force:source:deploy -p force-app/main/default/classes/ANAgentOpenPipeViaMCPV1Test.cls
```

### Deploy Custom Metadata Type
```bash
# Deploy the Custom Metadata Type
sfdx force:source:deploy -p force-app/main/default/objects/MCP_Config__mdt
```

### Deploy Flow
```bash
# Deploy the Flow
sfdx force:source:deploy -p force-app/main/default/flows/OpenPipeAnalysisViaMCP.flow-meta.xml
```

### Run Tests
```bash
# Run the test class
sfdx force:apex:test:run -n ANAgentOpenPipeViaMCPV1Test -r human
```

## Step 2: Setup Local MCP Server

### Start MCP Server
```bash
# In your local terminal
cd /Users/anahvi/Public/Salesforce-vscode/salesforce-dx-project
python3 mcp_server.py --port 8787
```

### Start ngrok Tunnel
```bash
# In another terminal
ngrok http 8787
```

### Note the ngrok URL
Copy the HTTPS URL from ngrok output (e.g., `https://abc123.ngrok.io`)

## Step 3: Configure Salesforce Sandbox

### Create Named Credential
1. **Navigate to Named Credentials**
   - Go to Setup → Named Credentials
   - Click "New Named Credential"

2. **Configure Named Credential**
   - **Label**: `MCP_OpenPipe`
   - **Name**: `MCP_OpenPipe`
   - **URL**: `https://abc123.ngrok.io` (your ngrok URL)
   - **Identity Type**: `Anonymous`
   - **Authentication Protocol**: `No Authentication`
   - **Generate Authorization Header**: `No`
   - **Allow Merge Fields in HTTP Header**: `Yes`
   - **Allow Merge Fields in HTTP Body**: `Yes`

3. **Save the Named Credential**

### Create Permission Set
1. **Navigate to Permission Sets**
   - Go to Setup → Permission Sets
   - Click "New Permission Set"

2. **Configure Permission Set**
   - **Label**: `MCP Open Pipe Analysis`
   - **API Name**: `MCP_Open_Pipe_Analysis`
   - **Description**: `Permission set for MCP Open Pipe Analysis integration`

3. **Add Named Credential Access**
   - Go to the Permission Set → Named Credentials
   - Click "Add Named Credential"
   - Select `MCP_OpenPipe`
   - Click "Save"

4. **Add Apex Class Access**
   - Go to the Permission Set → Apex Class Access
   - Click "Add Apex Class"
   - Select `ANAgentOpenPipeViaMCPV1`
   - Click "Save"

5. **Add Flow Access**
   - Go to the Permission Set → Flows
   - Click "Add Flow"
   - Select `OpenPipeAnalysisViaMCP`
   - Click "Save"

### Assign Permission Set
1. **Navigate to Permission Set Assignments**
   - Go to Setup → Permission Set Assignments
   - Click "Manage Assignments" for `MCP Open Pipe Analysis`
   - Click "Add Assignments"
   - Select your user
   - Click "Assign"

## Step 4: Configure Custom Metadata (Optional)

### For Development (ngrok tunnel):
1. **Navigate to Custom Metadata Types**
   - Go to Setup → Custom Metadata Types
   - Find `MCP Configuration`

2. **Edit Default Record**
   - **Base URL**: (leave empty - uses Named Credential)
   - **Mode**: `ROUTE`
   - **Timeout**: `10`
   - **Retry Count**: `2`
   - **Is Active**: `true`

3. **Save the Configuration**

## Step 5: Test the Integration

### Test Health Endpoint
```bash
curl https://abc123.ngrok.io/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "open-pipe-mcp",
  "dry_run": true,
  "sf_configured": true
}
```

### Test Route Endpoint
```bash
curl -X POST https://abc123.ngrok.io/route \
  -H "Content-Type: application/json" \
  -d '{"text": "Open pipe passed stage 4 in AMER ACC, country = US, top 20."}'
```

### Test in Salesforce
1. **Navigate to Agent Actions**
   - Go to Setup → Agent Actions
   - Find "Open Pipe Analysis (via MCP)"

2. **Test the Flow**
   - Click "Test" or "Run"
   - Enter utterance: "Open pipe passed stage 4 in AMER ACC, country = US, top 20."
   - Click "Run"

3. **Verify Response**
   - Should return structured analysis
   - Check debug logs for request details

## Step 6: Monitor and Debug

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

## Step 7: Production Deployment

### When Ready for Production

#### Option 1: Update Named Credential
1. **Update Named Credential URL**
   - Go to Setup → Named Credentials
   - Edit `MCP_OpenPipe`
   - Change URL to production MCP server
   - Save

#### Option 2: Use Custom Metadata
1. **Update Custom Metadata**
   - Go to Setup → Custom Metadata Types → MCP Configuration
   - Edit the active record
   - Set **Base URL**: `https://your-production-mcp.example.com`
   - Set **Mode**: `ANALYZE` (for direct analysis)
   - Set **Auth Header Name**: `X-API-Key`
   - Set **Auth Header Value**: `your-production-api-key`
   - Save

### Deploy to Production
```bash
# Deploy all components to production
sfdx force:source:deploy -p force-app/main/default/classes/ANAgentOpenPipeViaMCPV1.cls
sfdx force:source:deploy -p force-app/main/default/classes/ANAgentOpenPipeViaMCPV1Test.cls
sfdx force:source:deploy -p force-app/main/default/objects/MCP_Config__mdt
sfdx force:source:deploy -p force-app/main/default/flows/OpenPipeAnalysisViaMCP.flow-meta.xml

# Run tests
sfdx force:apex:test:run -n ANAgentOpenPipeViaMCPV1Test -r human
```

## Troubleshooting

### Common Issues

1. **Named Credential Not Found**
   - Verify the Named Credential name is exactly `MCP_OpenPipe`
   - Check that the URL is correct and accessible

2. **Permission Denied**
   - Ensure users have the `MCP Open Pipe Analysis` permission set
   - Verify Named Credential access is granted

3. **MCP Server Not Responding**
   - Check that ngrok is running and accessible
   - Verify the MCP server is running on port 8787
   - Test the health endpoint: `https://your-ngrok-url.ngrok.io/health`

4. **Custom Metadata Not Working**
   - Check that Custom Metadata record is active
   - Verify the Base URL is correct
   - Check debug logs for configuration usage

### Debug Commands

```bash
# Check ngrok status
ngrok status

# Test local server
curl http://localhost:8787/health

# Test ngrok tunnel
curl https://your-ngrok-url.ngrok.io/health

# Check Salesforce logs
sfdx force:apex:log:tail
```

## Security Considerations

### Development (ngrok)
- **HTTPS Only**: Always use HTTPS URLs
- **Temporary URLs**: ngrok URLs change when restarted
- **Local Access**: Only accessible when your laptop is running

### Production
- **Stable URLs**: Use production MCP server with stable URL
- **Authentication**: Use proper API keys and authentication
- **Monitoring**: Set up monitoring and alerting

## Performance Optimization

### Local Development
- **Connection Pooling**: Named Credential handles connection pooling
- **Retry Logic**: Built-in exponential backoff for 5xx errors
- **Timeout**: 10-second timeout prevents hanging requests

### Production
- **CDN**: Use CDN for MCP server if possible
- **Load Balancing**: Multiple MCP server instances
- **Caching**: Consider caching responses for better performance

## Maintenance

### Regular Tasks
1. **Monitor ngrok tunnels**: Ensure they're running and accessible
2. **Update URLs**: Update Named Credential if ngrok URL changes
3. **Test connectivity**: Regular health checks
4. **Review logs**: Check for errors and performance issues

### Backup and Recovery
1. **Export configuration**: Backup Named Credential and Custom Metadata
2. **Document setup**: Keep this guide updated
3. **Test procedures**: Regular testing of the integration

## Support

For issues with:
- **MCP Server**: Check local server logs and health endpoint
- **Salesforce Integration**: Review debug logs and permission sets
- **Network Issues**: Test connectivity between Salesforce and ngrok

The integration is now ready for live testing in your sandbox! 🎉
