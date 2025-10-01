# MCP Open Pipe Analysis Router

## Overview
This router handles natural language requests for Open Pipe Analysis and routes them to the `open_pipe_analyze` MCP tool. It applies normalization rules to convert user intent into structured parameters.

## Intent Lock Rules
- **Primary Intent**: If the user asks about existing pipeline analysis (not future pipe generation), choose `open_pipe_analyze`
- **Exclusion**: Do NOT route renewal/upsell/cross-sell requests (those are PipeGen tools)
- **Exclusion**: Do NOT route pipeline generation requests (those are PipeGen tools)

## Synonym Mapping Rules

### Stage Mapping
- "post stage 4", "passed stage 4", ">= stage 4" → `"minStage": 4`
- "post stage 3", "passed stage 3", ">= stage 3" → `"minStage": 3`
- "post stage 5", "passed stage 5", ">= stage 5" → `"minStage": 5`
- "stage 4 and above", "stage 4+" → `"minStage": 4`

### Time Frame Mapping
- "this quarter", "current quarter", "Q4", "current" → `"timeFrame": "CURRENT"`
- "last quarter", "previous quarter", "Q3" → `"timeFrame": "PREVIOUS"`

### OU & Geo Normalization
- Accept "AMER ACC", "AMER ACC OU", "ACC in AMER" → `"ouName": "AMER ACC"`
- Accept "EMEA ENTR", "EMEA Enterprise", "Enterprise EMEA" → `"ouName": "EMEA ENTR"`
- If both ouName and country given, pass both parameters
- Country names should be normalized to standard format (e.g., "United States" not "US")

### Limits and Safety
- Always set `limitN` (default 10, max 1000)
- Cap at 50 for safety
- No raw SOQL, no unknown fields
- Reject free-form filters with guidance message

## Guardrail Checks

### Valid Requests (Route to open_pipe_analyze)
- "Show me all the products that passed stage 4 within AMER ACC for open pipe"
- "Open pipe passed stage 4 in AMER ACC, country = US, top 20"
- "Compare last quarter open pipe post stage 4 for AMER ACC"
- "Filter to Data Cloud and Sales Cloud only"

### Invalid Requests (Refuse with guidance)
- "Open pipe for AMER ACC where amount > 1M and stage in (3,4,5) order by secretField"
  - Response: "Unsupported filter syntax. Provide minStage, productListCsv, ouName, country, timeframe, limitN only."
- "Generate pipeline for UKI next quarter"
  - Response: Do not use this tool (that's PipeGen)

## Test Utterances and Expected Outputs

### A. Q4 "close" scenario (AMER ACC, post-Stage-4)
**User**: "Show me all the products that passed stage 4 within AMER ACC for open pipe."
**Expected**:
```json
{"tool":"open_pipe_analyze","args":{"ouName":"AMER ACC","minStage":4,"timeFrame":"CURRENT","limitN":10}}
```

**User**: "For those products, keep timeframe to this quarter and show top 15."
**Expected**:
```json
{"tool":"open_pipe_analyze","args":{"ouName":"AMER ACC","minStage":4,"timeFrame":"CURRENT","limitN":15}}
```

**User**: "Filter to Data Cloud and Sales Cloud only."
**Expected**:
```json
{"tool":"open_pipe_analyze","args":{"ouName":"AMER ACC","minStage":4,"timeFrame":"CURRENT","productListCsv":"Data Cloud,Sales Cloud","limitN":10}}
```

### B. Regional filter
**User**: "Open pipe passed stage 4 in AMER ACC, country = US, top 20."
**Expected**:
```json
{"tool":"open_pipe_analyze","args":{"ouName":"AMER ACC","country":"United States","minStage":4,"timeFrame":"CURRENT","limitN":20}}
```

### C. Previous quarter
**User**: "Compare last quarter open pipe post stage 4 for AMER ACC."
**Expected**:
```json
{"tool":"open_pipe_analyze","args":{"ouName":"AMER ACC","minStage":4,"timeFrame":"PREVIOUS","limitN":10}}
```

### D. Guardrail checks
**User**: "Open pipe for AMER ACC where amount > 1M and stage in (3,4,5) order by secretField"
**Response**: Refuse with guidance: "Unsupported filter syntax. Provide minStage, productListCsv, ouName, country, timeframe, limitN only." (No tool call.)

**User**: "Generate pipeline for UKI next quarter"
**Response**: Do not use this tool (that's PipeGen). (No tool call.)

## Implementation Notes

### Router Behavior
1. Read user text
2. Apply normalization rules above
3. Emit only the JSON block `{ "tool":"open_pipe_analyze", "args":{...} }`
4. Handle guardrails and rejections appropriately

### MCP Tool Implementation
- Tool name: `open_pipe_analyze`
- Description: "Analyze existing opportunities ('open pipe') with stage/product/OU filters and aggregated results."
- Parameters: Follow the JSON schema exactly
- Output: Structured JSON response from Salesforce Apex REST endpoint

### Apex Endpoint (Optional)
- POST `/services/apexrest/agent/openPipeAnalyze`
- Proxies to `ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe()`
- Returns single composed message string

## Acceptance Criteria
- For each test utterance above, generate exactly the expected JSON with normalized params
- Any out-of-scope intent (PipeGen, renewals/upsell/cross-sell) is not routed to this tool
- Invalid filter attempts return a refusal with guidance (and no tool call)
- `limitN` always present and within [1,1000]
- `timeFrame` defaults to "CURRENT"
- `minStage` correctly mapped from phrases like "post stage 4"
