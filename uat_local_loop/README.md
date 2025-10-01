# Local Loop UAT System

This system tests the MCP Agent Integration locally, bypassing Zscaler issues by using:
- **Local MCP Server** (no inbound tunnels)
- **Direct Apex calls** via Salesforce REST API
- **Comprehensive test cases** with expected results

## 🚀 Quick Start

### 1. Start MCP Server
```bash
# In your main project directory
python3 mcp_server.py --host 0.0.0.0 --port 8787 --dry-run
```

### 2. Run UAT Tests

#### Dry Run (MCP only)
```bash
cd uat_local_loop
python3 run_uat.py --dry-run
```

#### Live Testing (MCP + Apex)
```bash
# Set Salesforce credentials
export SF_BASE_URL="https://your-org.salesforce.com"
export SF_ACCESS_TOKEN="your-access-token"

# Run full UAT
python3 run_uat.py
```

#### Filtered Testing
```bash
# Test only Open Pipe cases
python3 run_uat.py --filter "open_pipe" --dry-run

# Test only KPI cases
python3 run_uat.py --filter "kpi" --dry-run
```

## 📋 Test Cases

The `cases.csv` file contains test utterances with expected results:

| Field | Description |
|-------|-------------|
| `utterance` | Natural language input |
| `expected_tool` | Expected MCP tool name |
| `expected_keys` | Expected argument keys |
| `description` | Test case description |

## 🔧 Configuration

### Environment Variables
```bash
# Salesforce Configuration
export SF_BASE_URL="https://your-org.salesforce.com"
export SF_ACCESS_TOKEN="your-access-token"

# MCP Configuration (optional)
export MCP_URL="http://localhost:8787"
```

### Command Line Options
```bash
python3 run_uat.py --help
```

Options:
- `--mcp-url`: MCP server URL (default: http://localhost:8787)
- `--sf-base-url`: Salesforce base URL
- `--sf-token`: Salesforce access token
- `--filter`: Filter by tool name
- `--dry-run`: Test MCP only, skip Apex calls
- `--cases`: Test cases CSV file

## 📊 Results

### Console Output
- Real-time test progress
- Colorized pass/fail indicators
- Response times and error details

### CSV Reports
- Detailed results saved to `uat_results_YYYYMMDD_HHMMSS.csv`
- Includes all test data, timing, and error messages

## 🎯 Expected Results

### Successful Test Flow
1. **MCP Route**: Utterance → Tool + Args
2. **Apex Call**: Args → Salesforce REST API
3. **Validation**: Response matches expectations

### Common Issues
- **MCP Connection**: Check if MCP server is running
- **Salesforce Auth**: Verify SF_BASE_URL and SF_ACCESS_TOKEN
- **Tool Mapping**: Ensure MCP tools map to correct Apex classes

## 🔄 Adding New Test Cases

Edit `cases.csv` to add new test cases:

```csv
utterance,expected_tool,expected_keys,description
"Your new utterance here",expected_tool,"key1,key2,key3","Your test description"
```

## 🚀 Next Steps

1. **Run dry-run tests** to validate MCP routing
2. **Configure Salesforce credentials** for live testing
3. **Run full UAT** to validate end-to-end flow
4. **Review results** and fix any issues
5. **Deploy to production** when ready

## 🆘 Troubleshooting

### MCP Server Issues
```bash
# Check if MCP server is running
curl http://localhost:8787/health

# Check MCP logs
python3 mcp_server.py --host 0.0.0.0 --port 8787 --dry-run
```

### Salesforce Issues
```bash
# Test Salesforce connection
curl -H "Authorization: Bearer $SF_ACCESS_TOKEN" \
     "$SF_BASE_URL/services/data/v60.0/sobjects/Account/describe"
```

### Zscaler Issues
This local loop system completely bypasses Zscaler by:
- Using local MCP server (no inbound tunnels)
- Making outbound calls to Salesforce (allowed)
- No ngrok or tunneling required
