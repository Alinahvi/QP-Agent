# UAT Playbook: Agent UI Testing with MCP Integration

## Overview
This playbook provides step-by-step instructions for testing the MCP integration through the actual Agent UI (Sales Coach/Copilot) to ensure end-to-end functionality.

## Prerequisites
- MCP server running and accessible
- Salesforce org with MCP integration deployed
- Agent UI access (Sales Coach/Copilot)
- Test user with appropriate permissions

## Test Setup

### 1. Configure MCP Settings
```apex
// Set MCP configuration for testing
MCP_Config__mdt config = [SELECT Id FROM MCP_Config__mdt LIMIT 1];
// Update via Custom Metadata Type records or Data Loader
```

### 2. Enable Shadow Mode (Optional)
- Set `ShadowMode__c = true` in MCP_Config__mdt
- This will run both MCP and direct paths for comparison

## Test Scenarios

### Future Pipeline Analysis (25 utterances)

#### Test Cases:
1. **Cross-sell Opportunities**
   - "How many cross-sell opportunities do we have in AMER-ACC for Data Cloud?"
   - "Show me cross-sell opportunities in EMEA ENTR for Sales Cloud"
   - "What cross-sell opportunities exist in UKI for Marketing Cloud?"

2. **Upsell Opportunities**
   - "Show upsell opportunities in AMER-ACC for Service Cloud"
   - "What upsell opportunities do we have in LATAM for Data Cloud?"
   - "Find upsell opportunities in EMEA ENTR for Marketing Cloud"

3. **Renewal Analysis**
   - "What is the most valuable renewal product in AMER-ACC?"
   - "Show renewal opportunities in UKI for Sales Cloud"
   - "Find renewal opportunities in EMEA ENTR for Data Cloud"

4. **Combined Analysis**
   - "Analyze future pipeline for AMER-ACC"
   - "Show all opportunities in EMEA ENTR for Sales Cloud"
   - "What's our pipeline look like in UKI?"

#### Expected Results:
- MCP correctly identifies `future_pipeline` tool
- Proper parameter extraction (ouName, product, opportunityType, segment)
- Handler returns structured data with counts and opportunities
- Response time < 3 seconds

### Open Pipe Analysis (25 utterances)

#### Test Cases:
1. **Stage-based Analysis**
   - "Show open pipe for AMER-ACC in Prospecting stage"
   - "What opportunities are in Negotiation stage in EMEA ENTR?"
   - "Find opportunities in Closed Won stage in UKI"

2. **Product-based Analysis**
   - "Show Sales Cloud opportunities in AMER-ACC"
   - "What Data Cloud opportunities exist in EMEA ENTR?"
   - "Find Marketing Cloud opportunities in UKI"

3. **Country-based Analysis**
   - "Show opportunities in USA for Sales Cloud"
   - "What opportunities exist in Germany for Data Cloud?"
   - "Find opportunities in UK for Marketing Cloud"

#### Expected Results:
- MCP correctly identifies `open_pipe_analyze` tool
- Proper parameter extraction (ouName, product, stage, country)
- Handler returns opportunity data with amounts and stages
- Response time < 3 seconds

### KPI Analysis (25 utterances)

#### Test Cases:
1. **Revenue Analysis**
   - "What's our total revenue in AMER-ACC?"
   - "Show revenue breakdown for EMEA ENTR"
   - "What's the revenue trend in UKI?"

2. **Performance Metrics**
   - "What's our win rate in AMER-ACC?"
   - "Show average deal size in EMEA ENTR"
   - "What's our pipeline value in UKI?"

3. **Time-based Analysis**
   - "Show Q4 revenue in AMER-ACC"
   - "What was our performance last quarter in EMEA ENTR?"
   - "Show year-to-date metrics in UKI"

#### Expected Results:
- MCP correctly identifies `kpi_analyze` tool
- Proper parameter extraction (ouName, timeFrame, kpiType, region)
- Handler returns KPI data with metrics and trends
- Response time < 3 seconds

### Content Search (25 utterances)

#### Test Cases:
1. **ACT Courses**
   - "Show me ACT courses related to Data Cloud"
   - "Find Sales Cloud ACT courses created this quarter"
   - "What ACT courses have completion rate > 60%?"

2. **Consensus Demos**
   - "Show Consensus demos for Data Cloud"
   - "Find Marketing Cloud demo videos from last month"
   - "What Consensus demos are available for Service Cloud?"

3. **Content Filtering**
   - "Show ACT assets tagged 'Data Cloud' created this year"
   - "Find Consensus demos with public preview links"
   - "What content is available for Sales Cloud training?"

#### Expected Results:
- MCP correctly identifies `content_search` tool
- Proper parameter extraction (topic, source, dateRange, limit)
- Handler returns content items with links and metadata
- Response time < 3 seconds

### SME Search (25 utterances)

#### Test Cases:
1. **Expertise-based Search**
   - "Find SMEs with Data Cloud expertise"
   - "Who are the Sales Cloud experts in AMER-ACC?"
   - "Show Marketing Cloud specialists in EMEA ENTR"

2. **Region-based Search**
   - "Find SMEs in USA with Service Cloud expertise"
   - "Who are the Data Cloud experts in Germany?"
   - "Show Marketing Cloud specialists in UK"

3. **Combined Search**
   - "Find Data Cloud experts in AMER-ACC"
   - "Who are the Sales Cloud specialists in EMEA ENTR?"
   - "Show Service Cloud experts in UKI"

#### Expected Results:
- MCP correctly identifies `sme_search` tool
- Proper parameter extraction (expertise, region, limit)
- Handler returns SME profiles with contact information
- Response time < 3 seconds

### Workflow Service (25 utterances)

#### Test Cases:
1. **Process Execution**
   - "Start the sales process for new opportunity"
   - "Execute the renewal workflow for existing customer"
   - "Run the onboarding process for new account"

2. **Step Navigation**
   - "What's the next step in the sales process?"
   - "Show current step in the renewal workflow"
   - "What's the progress on the onboarding process?"

3. **Context-based Workflow**
   - "Start workflow for Data Cloud opportunity"
   - "Execute process for enterprise customer"
   - "Run workflow for mid-market account"

#### Expected Results:
- MCP correctly identifies `workflow` tool
- Proper parameter extraction (process, context, step)
- Handler returns workflow steps and progress
- Response time < 3 seconds

## Test Execution

### 1. Launch Agent UI
- Open Sales Coach or Copilot in Salesforce
- Navigate to the agent interface
- Ensure you have appropriate permissions

### 2. Execute Test Cases
For each test case:
1. Enter the utterance in the Agent UI
2. Submit the request
3. Capture the response
4. Record timing and results

### 3. Data Collection
For each test, record:
- **Utterance**: The input text
- **Detected Tool**: Tool identified by MCP
- **Arguments**: Extracted parameters
- **Handler Class**: Which adapter was called
- **Latency MCP (ms)**: Time for MCP processing
- **Latency Handler (ms)**: Time for handler execution
- **Result Size**: Size of response data
- **Error**: Any errors encountered
- **Pass/Fail**: Whether results match expectations

### 4. Shadow Mode Testing
If shadow mode is enabled:
- Compare MCP results with direct handler results
- Verify parameter parity
- Check response consistency
- Measure performance difference

## Success Criteria

### Performance
- **MCP Latency**: < 500ms for tool detection
- **Handler Latency**: < 3 seconds for execution
- **Total Latency**: < 4 seconds end-to-end

### Accuracy
- **Tool Detection**: > 95% correct tool identification
- **Parameter Extraction**: > 90% accurate parameter extraction
- **Response Quality**: > 95% successful handler execution

### Reliability
- **Error Rate**: < 5% error rate
- **Timeout Rate**: < 2% timeout rate
- **Success Rate**: > 95% successful completion

## Troubleshooting

### Common Issues
1. **MCP Server Unavailable**
   - Check MCP server status
   - Verify network connectivity
   - Check MCP configuration

2. **Tool Detection Failures**
   - Review utterance patterns
   - Check MCP server logs
   - Verify tool configuration

3. **Handler Execution Errors**
   - Check handler class availability
   - Verify parameter mapping
   - Review handler logs

4. **Performance Issues**
   - Check MCP server performance
   - Review handler execution time
   - Verify network latency

### Debug Steps
1. Check MCP server logs
2. Review Salesforce debug logs
3. Verify correlation IDs
4. Check telemetry data
5. Review error messages

## Results Export

### CSV Format
```csv
utterance,detected_tool,args,handler_class,latency_mcp_ms,latency_handler_ms,result_size,error,pass_fail
"How many cross-sell opportunities...",future_pipeline,"{ouName:AMER-ACC,product:Data Cloud}",AN_FuturePipeline_FromMCP,250,1200,2048,,PASS
```

### Analysis
- Calculate success rates by tool type
- Measure performance metrics
- Identify common failure patterns
- Generate improvement recommendations

## Rollback Plan

If issues are encountered:
1. Set `MCP_Config__mdt.IsActive__c = false`
2. Verify direct routing still works
3. Check for any data corruption
4. Review error logs
5. Plan remediation steps

## Next Steps

After successful UAT:
1. Enable for pilot users
2. Monitor production metrics
3. Gather user feedback
4. Plan full rollout
5. Document lessons learned
