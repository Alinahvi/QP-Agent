# MCP Open Pipe Analysis Server

A local MCP (Model Context Protocol) server for Open Pipe Analysis that routes natural language requests to Salesforce Apex REST endpoints.

## 🚀 Quick Start

### 1. Setup Environment

```bash
# Copy the environment template
cp env.example .env

# Edit .env with your Salesforce credentials
nano .env
```

### 2. Install Dependencies

```bash
make install
```

### 3. Test the Router (Offline)

```bash
make test
```

### 4. Start the Server

```bash
# Dry run mode (default)
make run

# Live mode (calls Salesforce)
make run-live
```

### 5. Verify Health

```bash
curl http://localhost:8787/health
```

## 📋 Prerequisites

- Python 3.11+
- Access to Salesforce org with the Open Pipe Analysis Apex REST endpoint
- Salesforce access token (see Authentication section)

## 🔧 Configuration

### Environment Variables

Create a `.env` file from `env.example`:

```bash
# Salesforce Configuration
SF_BASE_URL=https://your-domain.my.salesforce.com
SF_ACCESS_TOKEN=your_bearer_token_here

# Server Configuration
PORT=8787
HOST=localhost

# Development Mode
DRY_RUN=true

# Logging
LOG_LEVEL=INFO
```

### Salesforce Authentication

You need a Salesforce access token to call the Apex REST endpoint. Here are two methods:

#### Method 1: User Session Token (Easiest)
1. Log into your Salesforce org
2. Open Developer Console (Setup → Developer Console)
3. Go to Debug → Open Execute Anonymous Window
4. Run this Apex code:
```apex
String sessionId = UserInfo.getSessionId();
System.debug('Session ID: ' + sessionId);
```
5. Copy the Session ID from the debug log
6. Use this as your `SF_ACCESS_TOKEN`

#### Method 2: OAuth 2.0 (Recommended for Production)
1. Create a Connected App in Salesforce
2. Use OAuth 2.0 flow to get access token
3. Use the access token as `SF_ACCESS_TOKEN`

## 🏃‍♂️ Running the Server

### Local Development

```bash
# Install dependencies
make install

# Test router offline
make test

# Start server in dry-run mode
make run

# Start server in live mode (calls Salesforce)
make run-live
```

### Docker (Optional)

```bash
# Build Docker image
make build

# Run in Docker
make docker-run
```

## 🧪 Testing

### Router Tests (Offline)

```bash
make test
```

This runs the router tests without calling Salesforce.

### Health Check

```bash
curl http://localhost:8787/health
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

### API Testing

#### Route Natural Language

```bash
curl -X POST http://localhost:8787/route \
  -H "Content-Type: application/json" \
  -d '{"text": "Show me all the products that passed stage 4 within AMER ACC for open pipe."}'
```

#### Direct Analysis

```bash
curl -X POST http://localhost:8787/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "ouName": "AMER ACC",
    "minStage": 4,
    "timeFrame": "CURRENT",
    "limitN": 10
  }'
```

## 📚 API Endpoints

### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "service": "open-pipe-mcp",
  "dry_run": true,
  "sf_configured": true
}
```

### POST /route
Route natural language requests to structured parameters.

**Request:**
```json
{
  "text": "Show me all the products that passed stage 4 within AMER ACC for open pipe."
}
```

**Response:**
```json
{
  "tool": "open_pipe_analyze",
  "args": {
    "ouName": "AMER ACC",
    "minStage": 4,
    "timeFrame": "CURRENT",
    "limitN": 10
  }
}
```

### POST /analyze
Direct analysis with structured parameters.

**Request:**
```json
{
  "ouName": "AMER ACC",
  "minStage": 4,
  "timeFrame": "CURRENT",
  "limitN": 10
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Open Pipe Analysis completed",
  "parameters": {...},
  "salesforce_response": "..."
}
```

## 🔍 Router Logic

The router handles natural language requests and converts them to structured parameters:

### Supported Parameters

- **ouName** (required): Operating Unit name (e.g., "AMER ACC", "EMEA ENTR")
- **country** (optional): Work location country filter
- **minStage** (optional): Minimum stage number (0-8)
- **productListCsv** (optional): CSV list of product names
- **timeFrame** (optional): "CURRENT" or "PREVIOUS" (default: "CURRENT")
- **limitN** (optional): Result limit (1-1000, default: 10)

### Intent Classification

- ✅ **Routes to open_pipe_analyze**: Open pipe analysis requests
- ❌ **Rejects**: Pipeline generation, renewals, upsell, cross-sell
- ❌ **Rejects**: Unsupported filter syntax (raw SOQL, unknown fields)

### Normalization Rules

- **Stage mapping**: "post stage 4" → `minStage: 4`
- **Timeframe mapping**: "this quarter" → `timeFrame: "CURRENT"`
- **OU normalization**: "AMER ACC OU" → `ouName: "AMER ACC"`
- **Country mapping**: "US" → "United States"

## 🛠️ Development

### Project Structure

```
├── mcp_server.py              # Main MCP server
├── open_pipe_analyze.schema.json  # JSON schema
├── router.md                  # Router documentation
├── requirements.txt           # Python dependencies
├── Dockerfile                # Docker configuration
├── Makefile                  # Build commands
├── env.example               # Environment template
└── README_OPEN_PIPE_MCP.md   # This file
```

### Adding New Features

1. **Router Logic**: Update `OpenPipeRouter` class in `mcp_server.py`
2. **API Endpoints**: Add new routes in `_setup_routes()` method
3. **Salesforce Integration**: Update `_call_salesforce_endpoint()` method
4. **Testing**: Add test cases to `run_router_tests()` function

### Debugging

Enable debug logging by setting `LOG_LEVEL=DEBUG` in your `.env` file.

## 🚨 Troubleshooting

### Common Issues

1. **"Salesforce configuration missing"**
   - Check your `.env` file has `SF_BASE_URL` and `SF_ACCESS_TOKEN`
   - Verify the access token is valid

2. **"Operating Unit (ouName) is required"**
   - The router couldn't extract an OU name from the request
   - Try being more explicit: "Show me open pipe for AMER ACC"

3. **"Unsupported filter syntax"**
   - The request contains unsupported filters (raw SOQL, unknown fields)
   - Use only supported parameters: ouName, country, minStage, productListCsv, timeFrame, limitN

4. **Docker build fails**
   - Ensure you have Docker installed
   - Check that `requirements.txt` is present

### Logs

Check the server logs for detailed error information:

```bash
# View logs when running locally
python mcp_server.py --port 8787

# View Docker logs
docker logs <container_id>
```

## 🔒 Security Notes

- **Access Tokens**: Keep your Salesforce access token secure
- **Environment Variables**: Never commit `.env` files to version control
- **Network**: The server runs on localhost by default for security
- **HTTPS**: Use HTTPS in production environments

## 📞 Support

For issues with:
- **Router Logic**: Check `router.md` for normalization rules
- **Salesforce Integration**: Verify your Apex REST endpoint is working
- **API Issues**: Check the health endpoint and logs

## 🎯 Next Steps

1. **Test the router** with `make test`
2. **Start the server** with `make run`
3. **Verify health** with `curl http://localhost:8787/health`
4. **Test with real data** by setting `DRY_RUN=false`
5. **Integrate with your application** using the API endpoints

The MCP Open Pipe Analysis server is now ready for local development and testing!
