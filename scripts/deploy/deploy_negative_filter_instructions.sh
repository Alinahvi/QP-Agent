#!/bin/bash

# Deploy Negative Filter Agent Instructions
# This script deploys the agent instructions for negative filter detection

echo "=== Deploying Negative Filter Agent Instructions ==="
echo "Timestamp: $(date)"
echo ""

# Set deployment directory
DEPLOY_DIR="temp-deploy-negative-filter-instructions-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEPLOY_DIR"

echo "Created deployment directory: $DEPLOY_DIR"
echo ""

# Copy agent instructions to deployment directory
echo "Copying agent instructions..."
cp "agent-instructions-negative-filters.md" "$DEPLOY_DIR/"

echo "✓ Copied agent instructions"
echo ""

# Create a comprehensive deployment guide
cat > "$DEPLOY_DIR/DEPLOYMENT_GUIDE.md" << 'EOF'
# 🚨 CRITICAL NEGATIVE FILTER ROUTING - DEPLOYMENT GUIDE

## THE PROBLEM
The agent is NOT detecting negative intent and routing to the MCP adapter for "don't have" queries.

**❌ WRONG BEHAVIOR (What's happening now):**
- User asks: "List AEs in UKI who don't have agentforce deals"
- Agent uses: **ANAGENT Open Pipe Analysis V3** directly ❌
- Result: Uses `filterCriteria: "open_pipe_opty_stg_nm IS NULL"` instead of negative filters
- Result: Returns "no records found" instead of proper negative analysis

**✅ CORRECT BEHAVIOR (What should happen):**
- User asks: "List AEs in UKI who don't have agentforce deals"
- Agent routes to: **MCP Adapter with negative parameters** ✅
- Result: Uses `excludeProducts: "Agentforce"` and `negativeIntent: true`
- Result: Returns proper negative filter analysis with 810 AEs

## 🎯 THE SOLUTION - NEGATIVE FILTER DETECTION

### **NEGATIVE INTENT KEYWORDS TO DETECT:**
- "don't have"
- "without"
- "excluding"
- "exclude"
- "lack"
- "no [product]"
- "missing"
- "not having"

### **ROUTING LOGIC:**
1. **Detect negative intent** in user query
2. **Extract product names** from the query
3. **Route to MCP Adapter** with these parameters:
   - `excludeProducts`: "Product1,Product2"
   - `negativeIntent`: true
   - `ouName`: extracted OU
   - `country`: extracted country

### **MCP ADAPTER PARAMETERS:**
```json
{
  "ouName": "UKI",
  "excludeProducts": "Agentforce",
  "negativeIntent": true,
  "limit": "10",
  "correlationId": "agent-query-001"
}
```

## 📋 MANUAL CONFIGURATION STEPS

### Step 1: Update Agent Instructions
1. Copy the content from `agent-instructions-negative-filters.md`
2. Add to your agent's instruction set
3. Ensure the agent follows the routing logic above

### Step 2: Test the Routing
Use these test utterances:
1. "List AEs in UKI who don't have agentforce deals"
2. "Show me AEs without Data Cloud in AMER ACC"
3. "Find AEs excluding Slack in UKI"
4. "AEs who lack Tableau Cloud in AMER ENTR"
5. "Show AEs not having MuleSoft in AMER SMB"

### Step 3: Verify MCP Adapter
The MCP adapter (`AN_OpenPipeV3_FromMCP`) is already deployed and working.
Test with: `scripts/testing/test_negative_filter_mcp.apex`

## ✅ SUCCESS CRITERIA
- Agent detects negative intent keywords
- Agent routes to MCP adapter with correct parameters
- MCP adapter returns proper negative filter analysis
- User gets accurate results (e.g., 810 AEs in UKI without Agentforce)

## 🔧 TROUBLESHOOTING
If the agent still uses the old action:
1. Check agent instructions are properly configured
2. Verify MCP adapter is deployed
3. Test with the provided test utterances
4. Check agent logs for routing decisions

EOF

echo "✓ Created deployment guide"
echo ""

# Create a test script to verify the deployment
cat > "$DEPLOY_DIR/test_negative_routing.apex" << 'EOF'
// Test script to verify negative filter routing
System.debug('=== Testing Negative Filter Routing ===');

// Test 1: MCP Adapter Test
String testArgsJson = JSON.serialize(new Map<String, Object>{
    'ouName' => 'UKI',
    'excludeProducts' => 'Agentforce',
    'negativeIntent' => true,
    'limit' => '10',
    'correlationId' => 'test-001'
});

try {
    List<AN_OpenPipeV3_FromMCP.Result> results = AN_OpenPipeV3_FromMCP.run(new List<String>{testArgsJson});
    
    if (!results.isEmpty()) {
        AN_OpenPipeV3_FromMCP.Result result = results[0];
        System.debug('✅ MCP Adapter Test: SUCCESS');
        System.debug('Success: ' + result.success);
        System.debug('Message Length: ' + (result.message != null ? result.message.length() : 0));
        System.debug('Contains "Negative Filter": ' + (result.message != null && result.message.contains('Negative Filter')));
    } else {
        System.debug('❌ MCP Adapter Test: FAILED - No results');
    }
} catch (Exception e) {
    System.debug('❌ MCP Adapter Test: ERROR - ' + e.getMessage());
}

System.debug('=== Test Complete ===');
EOF

echo "✓ Created test script"
echo ""

# Display deployment summary
echo "=== DEPLOYMENT SUMMARY ==="
echo ""
echo "Files created:"
echo "  - agent-instructions-negative-filters.md"
echo "  - DEPLOYMENT_GUIDE.md"
echo "  - test_negative_routing.apex"
echo ""
echo "Next steps:"
echo "  1. Copy agent-instructions-negative-filters.md content to your agent"
echo "  2. Update agent routing logic to detect negative intent"
echo "  3. Test with provided test utterances"
echo "  4. Run test_negative_routing.apex to verify MCP adapter"
echo ""
echo "Test utterances:"
echo "  1. 'List AEs in UKI who don't have agentforce deals'"
echo "  2. 'Show me AEs without Data Cloud in AMER ACC'"
echo "  3. 'Find AEs excluding Slack in UKI'"
echo "  4. 'AEs who lack Tableau Cloud in AMER ENTR'"
echo "  5. 'Show AEs not having MuleSoft in AMER SMB'"
echo ""
echo "=== Deployment Complete ==="
echo "Timestamp: $(date)"
