# MCP Agent Utterance Integration - Complete Setup Guide

## Overview

This integration enables real **Agentforce** utterances to be routed by **MCP** and executed either as **Apex actions** or **MCP tools**, with a Flow in the middle. It provides true "utterance → action" behavior **in Salesforce**, with MCP doing the intent detection, argument extraction, and guardrails.

## Architecture

```
Agent UI → Prompt-Triggered Flow → MCP (ROUTE) → Tool Detection
    ↓
MCP returns {tool, args} → Flow branches to appropriate Apex adapter
    ↓
Apex adapter calls mapped Invocable class → Result returned to agent
    ↓
Log entire exchange for UAT/analytics
```

## Components Created

### 1. MCP Configuration
- **MCP_Config__mdt**: Custom metadata type for MCP server configuration
- **Named Credential**: `MCP_Core` for MCP server endpoint
- **Remote Site Setting**: `MCP_Localhost` for local development

### 2. Core Classes
- **ANAgentUtteranceRouterViaMCP**: Main MCP client for routing utterances
- **ANAgentUtteranceLogger**: Utility for logging interactions
- **AN_EBPUATRunner**: UAT testing framework

### 3. Apex Adapters (6 total)
- **AN_OpenPipeV3_FromMCP**: Maps to `ANAgentOpenPipeAnalysisV3Handler`
- **AN_KPI_FromMCP**: Maps to `ANAGENTKPIAnalysisHandlerV3`
- **AN_FuturePipeline_FromMCP**: Maps to `ANAgentFuturePipelineAnalysisHandler`
- **AN_SearchContent_FromMCP**: Maps to `ANAgentConsensusContentSearchHandler`
- **AN_SearchSME_FromMCP**: Maps to `ANAgentSMESearchHandler`
- **AN_Workflow_FromMCP**: Maps to various workflow services

### 4. Flow
- **AgentUtteranceRouterViaMCP**: Prompt-triggered flow for utterance routing

### 5. Analytics
- **Agent_Utterance_Log__c**: Custom object for tracking interactions

### 6. UAT Resources
- **Static Resources**: 6 JSON files with test utterances for each tool type

## Setup Instructions

### Step 1: Deploy Components

1. **Deploy the metadata**:
   ```bash
   sfdx force:source:deploy -p force-app/main/default
   ```

2. **Run tests**:
   ```bash
   sfdx force:apex:test:run -n ANAgentUtteranceRouterViaMCPTest
   ```

### Step 2: Configure MCP Server

1. **Update Named Credential**:
   - Go to Setup → Named Credentials
   - Edit `MCP_Core`
   - Set endpoint to your MCP server URL (e.g., `https://your-ngrok-url.ngrok.io`)

2. **Configure MCP_Config__mdt**:
   - Go to Setup → Custom Metadata Types
   - Click "Manage Records" for `MCP_Config__mdt`
   - Create/Edit records:
     - **DEV**: `https://your-ngrok-url.ngrok.io`, Mode: `BOTH`
     - **PROD**: `https://your-production-mcp.com`, Mode: `BOTH`

### Step 3: MCP Server Endpoints

Your MCP server must expose these endpoints:

#### POST /route
```json
{
  "utterance": "Show me all products that passed stage 4 within AMER ACC"
}
```

Response:
```json
{
  "tool": "open_pipe_analyze",
  "args": {
    "ouName": "AMER ACC",
    "country": "United States",
    "minStage": 4,
    "timeFrame": "CURRENT",
    "limitN": 20
  },
  "confidence": 0.95
}
```

#### POST /analyze
```json
{
  "tool": "open_pipe_analyze",
  "args": {
    "ouName": "AMER ACC",
    "minStage": 4,
    "timeFrame": "CURRENT",
    "limitN": 20
  }
}
```

Response:
```json
{
  "result": "Analysis completed successfully",
  "summary": "Found 15 opportunities in stage 4+ for AMER ACC"
}
```

### Step 4: Tool Mappings

The system maps MCP tools to Apex classes as follows:

| MCP Tool | Apex Adapter | Target Class |
|----------|--------------|--------------|
| `open_pipe_analyze` | `AN_OpenPipeV3_FromMCP` | `ANAgentOpenPipeAnalysisV3Handler` |
| `kpi_analyze` | `AN_KPI_FromMCP` | `ANAGENTKPIAnalysisHandlerV3` |
| `future_pipeline_analyze` | `AN_FuturePipeline_FromMCP` | `ANAgentFuturePipelineAnalysisHandler` |
| `search_content` | `AN_SearchContent_FromMCP` | `ANAgentConsensusContentSearchHandler` |
| `search_sme` | `AN_SearchSME_FromMCP` | `ANAgentSMESearchHandler` |
| `execute_workflow` | `AN_Workflow_FromMCP` | Various workflow services |

### Step 5: Wire Flow to Agent

1. **Update Agent Prompt**:
   Add this to your Sales Coach/Copilot prompt:
   ```
   When users ask questions, route them through the "AgentUtteranceRouterViaMCP" flow.
   Pass the user's utterance as input and display the flow's output as the response.
   ```

2. **Test Integration**:
   - Open your agent interface
   - Try: "Show me all products that passed stage 4 within AMER ACC"
   - Verify it routes through MCP and executes the correct Apex action

## UAT Testing

### Run UAT Tests

```apex
// Test Open Pipe Analysis
AN_EBPUATRunner.UATSummary summary = AN_EBPUATRunner.runViaMCP('open_pipe', 'uat_open_pipe_utterances', 10);

// Test KPI Analysis
AN_EBPUATRunner.UATSummary summary = AN_EBPUATRunner.runViaMCP('kpi', 'uat_kpi_utterances', 10);

// Test Future Pipeline
AN_EBPUATRunner.UATSummary summary = AN_EBPUATRunner.runViaMCP('future_pipeline', 'uat_future_pipeline_utterances', 10);

// Test Content Search
AN_EBPUATRunner.UATSummary summary = AN_EBPUATRunner.runViaMCP('search_content', 'uat_search_content_utterances', 10);

// Test SME Search
AN_EBPUATRunner.UATSummary summary = AN_EBPUATRunner.runViaMCP('search_sme', 'uat_search_sme_utterances', 10);

// Test Workflow Execution
AN_EBPUATRunner.UATSummary summary = AN_EBPUATRunner.runViaMCP('workflow', 'uat_workflow_utterances', 10);
```

### Export Results

```apex
// Export UAT results to CSV
Id csvId = AN_EBPUATRunner.exportResultsToCSV(summary);
System.debug('CSV exported with ID: ' + csvId);
```

## Example Utterances

### Open Pipe Analysis
- "Show me all products that passed stage 4 within AMER ACC (US), top 20"
- "Compare last quarter open pipe post stage 4 for AMER ACC"
- "Find opportunities in stage 3 or higher for EMEA SMB"

### KPI Analysis
- "KPI compare AMER ACC vs EMEA ACC for current quarter"
- "Show me KPI analysis for UKI region"
- "What are the top performing AEs by KPI in AMER SMB"

### Future Pipeline
- "Top renewal products for UKI next quarter (pipe gen)"
- "Show me future pipeline analysis for AMER ACC"
- "What are the top cross-sell opportunities for EMEA SMB"

### Content Search
- "Find recent ACT courses on Data Cloud (top 5)"
- "Search for Consensus content about Salesforce CRM"
- "Find ACT articles on AI and machine learning"

### SME Search
- "Find SMEs for Data Cloud in AMER ACC (Excellence Academy only)"
- "Search for SMEs on Salesforce CRM in EMEA"
- "Find SMEs for Service Cloud in UKI region"

### Workflow Execution
- "Schedule a call with John Smith for next Tuesday at 2 PM"
- "Export pipeline data to TSV for AMER ACC region"
- "Send email to team about Q4 targets"

## Monitoring and Analytics

### View Logs

```apex
// Get recent logs
List<Agent_Utterance_Log__c> logs = ANAgentUtteranceLogger.getRecentLogs(50);

// Get logs by correlation ID
List<Agent_Utterance_Log__c> logs = ANAgentUtteranceLogger.getLogsByCorrelationId('MCP_1234567890_12345');

// Get logs by tool
List<Agent_Utterance_Log__c> logs = ANAgentUtteranceLogger.getLogsByTool('open_pipe_analyze', 20);
```

### Reports and Dashboards

Create reports on `Agent_Utterance_Log__c` to track:
- Success rates by tool
- Average response times
- Error patterns
- User adoption

## Troubleshooting

### Common Issues

1. **MCP Server Not Responding**:
   - Check Named Credential endpoint
   - Verify Remote Site Setting
   - Check MCP server logs

2. **Tool Not Detected**:
   - Verify MCP server is returning correct tool names
   - Check tool mapping in Flow
   - Review MCP server configuration

3. **Apex Adapter Errors**:
   - Check target Apex class exists and is accessible
   - Verify parameter mapping
   - Review Apex logs

4. **Flow Errors**:
   - Check Flow debug logs
   - Verify all subflows are accessible
   - Review Flow permissions

### Debug Mode

Enable debug logging:
1. Go to Setup → Debug Logs
2. Create new trace flag for your user
3. Set Apex Code to DEBUG level
4. Monitor logs for detailed error information

## Security Considerations

1. **MCP Server Security**:
   - Use HTTPS for production
   - Implement authentication (API keys, OAuth)
   - Rate limiting and request validation

2. **Salesforce Security**:
   - Review permission sets
   - Limit Named Credential access
   - Monitor log data for sensitive information

3. **Data Privacy**:
   - Truncate large fields in logs
   - Implement data retention policies
   - Consider PII handling requirements

## Performance Optimization

1. **Caching**:
   - Implement MCP response caching
   - Cache frequently used configurations

2. **Async Processing**:
   - Use Queueable for long-running operations
   - Implement batch processing for bulk operations

3. **Monitoring**:
   - Set up alerts for high error rates
   - Monitor response times
   - Track resource usage

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Salesforce debug logs
3. Check MCP server logs
4. Contact your system administrator

## Version History

- **v1.0**: Initial implementation with all 6 tool mappings
- Complete UAT framework with 300+ test utterances
- Comprehensive logging and analytics
- Production-ready configuration management
