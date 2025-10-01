# Salesforce MCP Integration Setup Guide

## Overview

This guide explains how to set up the Salesforce integration with the MCP Open Pipe Analysis server for both Pattern 1 (Salesforce → MCP /analyze) and Pattern 2 (Salesforce → MCP /route → Apex).

## Prerequisites

- Salesforce org with appropriate permissions
- MCP Open Pipe Analysis server running locally
- ngrok or similar tunneling service for HTTPS access
- Admin access to create Named Credentials and Permission Sets

## Step 1: Setup ngrok for HTTPS Access

### Install ngrok
```bash
# Download and install ngrok
# Visit https://ngrok.com/download

# Start ngrok tunnel to your local MCP server
ngrok http 8787
```

### Note the HTTPS URL
ngrok will provide an HTTPS URL like: `https://abc123.ngrok.io`

## Step 2: Create Named Credential

### In Salesforce Setup:

1. **Navigate to Named Credentials**
   - Go to Setup → Named Credentials
   - Click "New Named Credential"

2. **Configure Named Credential**
   - **Label**: `MCP_OpenPipe`
   - **Name**: `MCP_OpenPipe`
   - **URL**: `https://your-ngrok-url.ngrok.io` (from Step 1)
   - **Identity Type**: `Anonymous`
   - **Authentication Protocol**: `No Authentication`
   - **Generate Authorization Header**: `No`
   - **Allow Merge Fields in HTTP Header**: `Yes`
   - **Allow Merge Fields in HTTP Body**: `Yes`

3. **Save the Named Credential**

## Step 2.5: Configure Custom Metadata (Optional)

### For SOX-Friendly Environment Switching:

1. **Navigate to Custom Metadata Types**
   - Go to Setup → Custom Metadata Types
   - Find `MCP Configuration`

2. **Create/Edit MCP Configuration Record**
   - **Base URL**: Leave empty to use Named Credential, or enter custom URL
   - **Auth Header Name**: Optional (e.g., `X-API-Key`, `Authorization`)
   - **Auth Header Value**: Optional (e.g., `your-api-key`, `Bearer your-token`)
   - **Mode**: `ROUTE` (route then call Apex) or `ANALYZE` (direct analysis)
   - **Timeout**: Seconds for HTTP timeout (default: 10)
   - **Retry Count**: Number of retries for 5xx errors (default: 2)
   - **Is Active**: `true`

3. **Save the Configuration**

### Environment Switching Examples:

#### Development (ngrok tunnel):
```
Base URL: (empty - uses Named Credential)
Mode: ROUTE
```

#### Production (cloud-hosted MCP):
```
Base URL: https://your-production-mcp.example.com
Auth Header Name: X-API-Key
Auth Header Value: your-production-api-key
Mode: ANALYZE
Timeout: 15
Retry Count: 3
```

#### Staging (different endpoint):
```
Base URL: https://staging-mcp.example.com
Mode: ROUTE
Timeout: 20
```

## Step 3: Create Permission Set

### Create Permission Set for MCP Access

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

## Step 4: Assign Permission Set

### Assign to Users

1. **Navigate to Permission Set Assignments**
   - Go to Setup → Permission Set Assignments
   - Click "Manage Assignments" for `MCP Open Pipe Analysis`
   - Click "Add Assignments"
   - Select users who need access
   - Click "Assign"

## Step 5: Deploy Components

### Deploy Apex Class
```bash
# Deploy the Apex class
sfdx force:source:deploy -p force-app/main/default/classes/ANAgentOpenPipeViaMCPV1.cls
```

### Deploy Flow
```bash
# Deploy the Flow
sfdx force:source:deploy -p force-app/main/default/flows/OpenPipeAnalysisViaMCP.flow-meta.xml
```

## Step 6: Configure Agent Action

### Add Flow as Agent Action

1. **Navigate to Agent Actions**
   - Go to Setup → Agent Actions
   - Click "New Agent Action"

2. **Configure Agent Action**
   - **Name**: `Open Pipe Analysis (via MCP)`
   - **Description**: `Analyze open pipe data using MCP integration`
   - **Flow**: Select `OpenPipeAnalysisViaMCP`
   - **Input Variables**: Map `utterance` to user input
   - **Output Variables**: Map `result` to response

3. **Save the Agent Action**

## Step 7: Test the Integration

### Test Pattern 1 (Direct Analysis)
```bash
# Test with direct analysis
curl -X POST https://your-ngrok-url.ngrok.io/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "ouName": "AMER ACC",
    "minStage": 4,
    "timeFrame": "CURRENT",
    "limitN": 10
  }'
```

### Test Pattern 2 (Route + Apex)
```bash
# Test with natural language routing
curl -X POST https://your-ngrok-url.ngrok.io/route \
  -H "Content-Type: application/json" \
  -d '{"text": "Open pipe passed stage 4 in AMER ACC, country = US, top 20."}'
```

### Test in Salesforce
1. **Navigate to Agent Actions**
2. **Test the Flow** with sample utterances:
   - "Open pipe passed stage 4 in AMER ACC, country = US, top 20."
   - "Generate pipeline for UKI next quarter."

## Step 8: Admin Configuration Management

### Switching Environments Without Code Deploy

#### Development → Production
1. **Update Custom Metadata**:
   - Go to Setup → Custom Metadata Types → MCP Configuration
   - Edit the active record
   - Set **Base URL**: `https://your-production-mcp.example.com`
   - Set **Mode**: `ANALYZE` (for direct analysis)
   - Set **Auth Header Name**: `X-API-Key`
   - Set **Auth Header Value**: `your-production-api-key`
   - Save

2. **No code deployment required** - changes take effect immediately

#### Production → Staging
1. **Update Custom Metadata**:
   - Set **Base URL**: `https://staging-mcp.example.com`
   - Set **Mode**: `ROUTE` (for route + Apex pattern)
   - Clear auth headers if not needed
   - Save

#### Fallback to Named Credential
1. **Clear Custom Metadata**:
   - Set **Base URL**: (empty)
   - Set **Is Active**: `false`
   - Save

2. **System will automatically use Named Credential**

### Monitoring Configuration Changes

#### Debug Logs
Enable debug logs to see configuration usage:
```
MCP Using Custom Metadata URL: https://production-mcp.example.com/route
MCP Using Named Credential URL: callout:MCP_OpenPipe/route
MCP Using custom auth header: X-API-Key
```

#### Health Checks
Test configuration changes:
1. **Test with current config**: Use Agent Action
2. **Check debug logs**: Verify URL and headers
3. **Monitor performance**: Check timeout and retry settings

### SOX Compliance Features

#### Audit Trail
- **Custom Metadata changes** are tracked in Setup Audit Trail
- **No code changes** required for environment switching
- **Immediate effect** without deployment windows

#### Security Controls
- **Environment isolation**: Different URLs for different environments
- **Access control**: Permission set required for Custom Metadata changes
- **Encrypted storage**: Auth header values are encrypted at rest

#### Change Management
- **Zero downtime**: Configuration changes don't require system restart
- **Rollback capability**: Can quickly revert to previous configuration
- **Testing**: Can test new configurations before going live

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

4. **Timeout Errors**
   - The Apex class has a 10-second timeout
   - Check network connectivity between Salesforce and ngrok
   - Verify the MCP server is responding quickly

### Debug Logs

Enable debug logs to see detailed information:
1. Go to Setup → Debug Logs
2. Create a new debug log for your user
3. Set log level to `DEBUG` for `ANAgentOpenPipeViaMCPV1`
4. Test the integration and review the logs

### Log Messages to Look For

- `MCP Request - RequestId: XXX, CorrelationId: XXX, Mode: ROUTE/ANALYZE`
- `MCP Route Response - Tool: open_pipe_analyze, Args: {...}`
- `MCP Analyze Response: {...}`
- `MCP Retry X - Status: XXX, Delay: XXXms`

## Security Considerations

1. **HTTPS Only**: Always use HTTPS for the Named Credential URL
2. **Access Control**: Limit permission set assignments to necessary users
3. **Monitoring**: Monitor usage and performance
4. **Credentials**: Keep ngrok URLs secure and rotate as needed

## Performance Optimization

1. **Connection Pooling**: The Named Credential handles connection pooling
2. **Retry Logic**: Built-in exponential backoff for 5xx errors
3. **Timeout**: 10-second timeout prevents hanging requests
4. **Caching**: Consider caching responses for repeated requests

## Maintenance

### Regular Tasks
1. **Monitor ngrok tunnels**: Ensure they're running and accessible
2. **Update URLs**: If ngrok URLs change, update the Named Credential
3. **Review logs**: Check for errors and performance issues
4. **Test connectivity**: Regular health checks

### Backup and Recovery
1. **Export Named Credential**: Backup the configuration
2. **Document setup**: Keep this guide updated
3. **Test procedures**: Regular testing of the integration

## Support

For issues with:
- **MCP Server**: Check the local server logs and health endpoint
- **Salesforce Integration**: Review debug logs and permission sets
- **Network Issues**: Test connectivity between Salesforce and ngrok

The integration is now ready for use with both Pattern 1 and Pattern 2 workflows!
