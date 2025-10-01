# ngrok Setup for MCP Open Pipe Analysis

## Overview

ngrok creates a secure tunnel from your local MCP server to the internet, allowing Salesforce to access it via HTTPS. This is required for the Named Credential integration.

## Step 1: Install ngrok

### Option A: Download from ngrok.com
1. Visit [https://ngrok.com/download](https://ngrok.com/download)
2. Download the appropriate version for your OS
3. Extract the binary to your PATH

### Option B: Install via Package Manager

#### macOS (Homebrew)
```bash
brew install ngrok/ngrok/ngrok
```

#### Windows (Chocolatey)
```bash
choco install ngrok
```

#### Linux (Snap)
```bash
sudo snap install ngrok
```

## Step 2: Create ngrok Account

1. **Sign up for free account**
   - Visit [https://ngrok.com](https://ngrok.com)
   - Click "Sign up" and create an account
   - Verify your email address

2. **Get your authtoken**
   - Go to [https://dashboard.ngrok.com/get-started/your-authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)
   - Copy your authtoken

3. **Configure ngrok**
   ```bash
   ngrok config add-authtoken YOUR_AUTHTOKEN_HERE
   ```

## Step 3: Start ngrok Tunnel

### Start the MCP Server
```bash
# In one terminal, start your MCP server
python3 mcp_server.py --port 8787
```

### Start ngrok Tunnel
```bash
# In another terminal, start ngrok
ngrok http 8787
```

### Note the HTTPS URL
ngrok will display output like:
```
Session Status                online
Account                       your-email@example.com
Version                       3.x.x
Region                        United States (us)
Latency                       -
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123.ngrok.io -> http://localhost:8787
```

**Copy the HTTPS URL**: `https://abc123.ngrok.io`

## Step 4: Configure Salesforce Named Credential

### In Salesforce Setup:

1. **Navigate to Named Credentials**
   - Go to Setup → Named Credentials
   - Click "New Named Credential"

2. **Configure Named Credential**
   - **Label**: `MCP_OpenPipe`
   - **Name**: `MCP_OpenPipe`
   - **URL**: `https://abc123.ngrok.io` (use your ngrok URL)
   - **Identity Type**: `Anonymous`
   - **Authentication Protocol**: `No Authentication`
   - **Generate Authorization Header**: `No`
   - **Allow Merge Fields in HTTP Header**: `Yes`
   - **Allow Merge Fields in HTTP Body**: `Yes`

3. **Save the Named Credential**

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

Expected response:
```json
{
  "tool": "open_pipe_analyze",
  "args": {
    "ouName": "AMER ACC",
    "minStage": 4,
    "timeFrame": "CURRENT",
    "limitN": 20,
    "country": "United States"
  }
}
```

### Test Analyze Endpoint
```bash
curl -X POST https://abc123.ngrok.io/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "ouName": "AMER ACC",
    "minStage": 4,
    "timeFrame": "CURRENT",
    "limitN": 10
  }'
```

## Step 6: Monitor ngrok

### ngrok Web Interface
- Visit `http://127.0.0.1:4040` to see request logs
- Monitor traffic and debug issues
- View request/response details

### ngrok Logs
```bash
# View ngrok logs
ngrok http 8787 --log stdout
```

## Troubleshooting

### Common Issues

1. **ngrok URL Changes**
   - Free ngrok URLs change when you restart
   - Update the Named Credential URL when this happens
   - Consider upgrading to paid plan for static URLs

2. **Connection Refused**
   - Ensure MCP server is running on port 8787
   - Check that ngrok is forwarding to the correct port
   - Verify firewall settings

3. **HTTPS Certificate Issues**
   - ngrok provides valid SSL certificates
   - If you see certificate errors, check the ngrok URL
   - Ensure you're using the HTTPS URL, not HTTP

4. **Timeout Issues**
   - Check network connectivity
   - Verify MCP server is responding quickly
   - Check ngrok status at [https://status.ngrok.com](https://status.ngrok.com)

### Debug Commands

```bash
# Check ngrok status
ngrok status

# View ngrok configuration
ngrok config check

# Test local server
curl http://localhost:8787/health

# Test ngrok tunnel
curl https://your-ngrok-url.ngrok.io/health
```

## Production Considerations

### Paid ngrok Plans
- **Static URLs**: Paid plans provide static URLs that don't change
- **Custom Domains**: Use your own domain for production
- **Higher Limits**: More concurrent tunnels and bandwidth

### Security
- **HTTPS Only**: Always use HTTPS URLs in Named Credentials
- **Access Control**: Consider IP whitelisting if needed
- **Monitoring**: Monitor usage and set up alerts

### Performance
- **Region Selection**: Choose ngrok region closest to your users
- **Connection Pooling**: Named Credentials handle connection pooling
- **Caching**: Consider caching responses for better performance

## Alternative Solutions

### Other Tunneling Services
- **Cloudflare Tunnel**: Free alternative to ngrok
- **LocalTunnel**: Open source tunneling solution
- **SSH Tunneling**: Use SSH for secure tunneling

### Cloud Deployment
- **Heroku**: Deploy MCP server to Heroku
- **Railway**: Simple cloud deployment
- **AWS/GCP/Azure**: Full cloud infrastructure

## Maintenance

### Regular Tasks
1. **Monitor ngrok status**: Check if tunnel is active
2. **Update URLs**: Update Named Credential if URL changes
3. **Test connectivity**: Regular health checks
4. **Review logs**: Check for errors and performance issues

### Backup and Recovery
1. **Document setup**: Keep this guide updated
2. **Test procedures**: Regular testing of the integration
3. **Alternative plans**: Have backup tunneling solutions ready

## Support

For issues with:
- **ngrok**: Check [https://ngrok.com/docs](https://ngrok.com/docs)
- **MCP Server**: Check local server logs and health endpoint
- **Salesforce Integration**: Review debug logs and Named Credential configuration

The ngrok tunnel is now ready for Salesforce integration!
