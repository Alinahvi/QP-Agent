# QP Topic Agent API Guide

## Overview

This guide provides comprehensive documentation for the REST API created for the **QP Topic (1 Topic Only)** agent. The API exposes all agent functionality through standardized REST endpoints, enabling external systems to interact with the agent's capabilities.

## Base URL

```
https://[your-salesforce-instance].salesforce.com/services/apexrest/api/qp-agent/
```

## Authentication

All API calls require Salesforce authentication. Use one of these methods:

1. **OAuth 2.0** (Recommended for external applications)
2. **Session ID** (For direct API calls)
3. **Named Credentials** (For Salesforce-to-Salesforce integration)

## Available Endpoints

### 1. Health Check
**GET** `/health`

Check API health and status.

**Response:**
```json
{
  "success": true,
  "message": "QP Topic Agent API is healthy",
  "data": {
    "status": "healthy",
    "timestamp": "2024-01-15T10:30:00.000Z",
    "version": "1.0",
    "agent": "QP Topic (1 Topic Only)",
    "company": "Field Readiness"
  },
  "timestamp": "2024-01-15T10:30:00.000Z",
  "agent": "QP Topic (1 Topic Only)"
}
```

### 2. KPI Analysis
**GET** `/kpi-analysis`

Analyze KPIs across Account Executives, Operating Units, and territories.

**Parameters:**
- `analysisType` (required): Type of analysis (e.g., "AE_PERFORMANCE", "TERRITORY_KPIS")
- `ouName` (optional): Operating Unit name (e.g., "AMER ACC", "EMEA")
- `workLocationCountry` (optional): Country filter (e.g., "US", "Canada", "UK")
- `groupBy` (optional): Group results by field
- `filterCriteria` (optional): Additional filter criteria
- `limit` (optional): Number of results (default: 10)
- `aggregationType` (optional): Aggregation method (e.g., "COUNT", "SUM")

**Example Request:**
```
GET /api/qp-agent/kpi-analysis?analysisType=AE_PERFORMANCE&ouName=AMER%20ACC&limit=5
```

**Example Response:**
```json
{
  "success": true,
  "message": "KPI analysis completed successfully",
  "data": "Top 5 AEs in AMER ACC:\n1. John Smith - ACV: $2.5M\n2. Jane Doe - ACV: $2.1M\n...",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "agent": "QP Topic (1 Topic Only)"
}
```

### 3. Pipeline Analysis
**GET** `/pipeline-analysis`

Analyze sales pipeline data for opportunities and forecasting.

**Parameters:**
- `analysisType` (required): "OPEN_PIPELINE" or "FUTURE_PIPELINE"
- `ouName` (optional): Operating Unit filter
- `workLocationCountry` (optional): Country filter
- `groupBy` (optional): Group by field (e.g., "ACCOUNT", "PRODUCT")
- `filterCriteria` (optional): Additional filters
- `limit` (optional): Result limit
- `aggregationType` (optional): Aggregation method

**Example Request:**
```
GET /api/qp-agent/pipeline-analysis?analysisType=OPEN_PIPELINE&groupBy=ACCOUNT&limit=10
```

### 4. Content Search
**GET** `/content-search`

Search for courses, training materials, and educational content.

**Parameters:**
- `searchTerm` (required): Search query
- `contentType` (optional): Filter by content type ("Course", "Asset", "Curriculum")
- `limit` (optional): Number of results

**Example Request:**
```
GET /api/qp-agent/content-search?searchTerm=Tableau&contentType=Course&limit=5
```

**Example Response:**
```json
{
  "success": true,
  "message": "Content search completed successfully",
  "data": [
    {
      "name": "Tableau Fundamentals",
      "type": "Course",
      "completionRate": "85%",
      "learnerCount": 1250,
      "description": "Introduction to Tableau basics..."
    }
  ],
  "timestamp": "2024-01-15T10:30:00.000Z",
  "agent": "QP Topic (1 Topic Only)"
}
```

### 5. Knowledge Search
**GET** `/knowledge-search`

Search knowledge articles and documentation.

**Parameters:**
- `searchTerm` (required): Search query
- `limit` (optional): Number of results

**Example Request:**
```
GET /api/qp-agent/knowledge-search?searchTerm=AE%20Academy&limit=3
```

### 6. AE Territory Analysis
**GET** `/ae-territory-analysis`

Analyze Account Executive territories and performance.

**Parameters:**
- `analysisType` (required): Type of analysis
  - "OPEN_PIPELINE_STATUS"
  - "PIPELINE_GENERATION_OPPORTUNITIES"
  - "TERRITORY_KPIS"
  - "NEW_HIRE_ANALYSIS"
  - "COMPREHENSIVE_ANALYSIS"
- `ouName` (optional): Operating Unit filter
- `workLocationCountry` (optional): Country filter
- `limit` (optional): Result limit

**Example Request:**
```
GET /api/qp-agent/ae-territory-analysis?analysisType=TERRITORY_KPIS&ouName=AMER%20ACC
```

### 7. Sales Coach Feedback
**POST** `/sales-coach-feedback`

Get Next Best Action recommendations for sales coaching.

**Request Body:**
```json
{
  "learnerProfileId": "a1234567890abcdef",
  "opportunityId": "0061234567890abc",
  "includeCrossSell": true,
  "includeUpsell": true
}
```

**Example Response:**
```json
{
  "success": true,
  "message": "Next Best Action retrieved successfully",
  "data": {
    "actionType": "CROSS_SELL",
    "sellerName": "John Smith",
    "sellerEmail": "john.smith@salesforce.com",
    "product": "Tableau Server",
    "account": "Acme Corp",
    "reason": "Cross-sell opportunity for additional Tableau products",
    "priority": "Medium",
    "amount": 25000,
    "opportunityId": "0061234567890abc"
  },
  "timestamp": "2024-01-15T10:30:00.000Z",
  "agent": "QP Topic (1 Topic Only)"
}
```

## Error Handling

All endpoints return standardized error responses:

```json
{
  "success": false,
  "message": "Error description",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "agent": "QP Topic (1 Topic Only)"
}
```

**Common HTTP Status Codes:**
- `200`: Success
- `400`: Bad Request (missing required parameters)
- `401`: Unauthorized (authentication required)
- `403`: Forbidden (insufficient permissions)
- `500`: Internal Server Error

## Testing Examples

### cURL Examples

**Health Check:**
```bash
curl -X GET \
  'https://your-instance.salesforce.com/services/apexrest/api/qp-agent/health' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN'
```

**KPI Analysis:**
```bash
curl -X GET \
  'https://your-instance.salesforce.com/services/apexrest/api/qp-agent/kpi-analysis?analysisType=AE_PERFORMANCE&ouName=AMER%20ACC&limit=5' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN'
```

**Content Search:**
```bash
curl -X GET \
  'https://your-instance.salesforce.com/services/apexrest/api/qp-agent/content-search?searchTerm=Tableau&limit=3' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN'
```

**Sales Coach Feedback:**
```bash
curl -X POST \
  'https://your-instance.salesforce.com/services/apexrest/api/qp-agent/sales-coach-feedback' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "learnerProfileId": "a1234567890abcdef",
    "includeCrossSell": true,
    "includeUpsell": true
  }'
```

### Postman Collection

Import this collection into Postman for easy testing:

```json
{
  "info": {
    "name": "QP Topic Agent API",
    "description": "API collection for QP Topic (1 Topic Only) agent"
  },
  "variable": [
    {
      "key": "baseUrl",
      "value": "https://your-instance.salesforce.com/services/apexrest/api/qp-agent"
    },
    {
      "key": "accessToken",
      "value": "YOUR_ACCESS_TOKEN"
    }
  ],
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{accessToken}}"
          }
        ],
        "url": {
          "raw": "{{baseUrl}}/health",
          "host": ["{{baseUrl}}"],
          "path": ["health"]
        }
      }
    }
  ]
}
```

## Integration Examples

### JavaScript/Node.js
```javascript
const axios = require('axios');

const QPTopicAPI = {
  baseURL: 'https://your-instance.salesforce.com/services/apexrest/api/qp-agent',
  accessToken: 'YOUR_ACCESS_TOKEN',
  
  async searchContent(searchTerm, limit = 10) {
    const response = await axios.get(`${this.baseURL}/content-search`, {
      headers: {
        'Authorization': `Bearer ${this.accessToken}`
      },
      params: {
        searchTerm,
        limit
      }
    });
    return response.data;
  },
  
  async getSalesCoachFeedback(learnerProfileId, opportunityId = null) {
    const response = await axios.post(`${this.baseURL}/sales-coach-feedback`, {
      learnerProfileId,
      opportunityId,
      includeCrossSell: true,
      includeUpsell: true
    }, {
      headers: {
        'Authorization': `Bearer ${this.accessToken}`,
        'Content-Type': 'application/json'
      }
    });
    return response.data;
  }
};

// Usage
QPTopicAPI.searchContent('Tableau')
  .then(result => console.log(result.data))
  .catch(error => console.error(error));
```

### Python
```python
import requests
import json

class QPTopicAPI:
    def __init__(self, instance_url, access_token):
        self.base_url = f"{instance_url}/services/apexrest/api/qp-agent"
        self.headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        }
    
    def analyze_kpis(self, analysis_type, ou_name=None, limit=10):
        params = {'analysisType': analysis_type, 'limit': limit}
        if ou_name:
            params['ouName'] = ou_name
        
        response = requests.get(f"{self.base_url}/kpi-analysis", 
                              headers=self.headers, params=params)
        return response.json()
    
    def search_content(self, search_term, content_type=None, limit=10):
        params = {'searchTerm': search_term, 'limit': limit}
        if content_type:
            params['contentType'] = content_type
        
        response = requests.get(f"{self.base_url}/content-search", 
                              headers=self.headers, params=params)
        return response.json()

# Usage
api = QPTopicAPI('https://your-instance.salesforce.com', 'YOUR_ACCESS_TOKEN')
result = api.search_content('Tableau', limit=5)
print(json.dumps(result, indent=2))
```

## Rate Limits

- **Standard Limits**: 15,000 API calls per 24-hour period per user
- **Concurrent Requests**: Maximum 10 concurrent requests per user
- **Request Size**: Maximum 6MB per request

## Security Considerations

1. **Authentication**: Always use OAuth 2.0 or secure session tokens
2. **HTTPS**: All API calls must use HTTPS
3. **Permissions**: Ensure proper Salesforce permissions are configured
4. **Data Privacy**: Respect data privacy regulations and internal policies
5. **Logging**: Monitor API usage and log access for security auditing

## Support

For technical support or questions about the QP Topic Agent API:

- **Documentation**: Refer to this guide and Salesforce REST API documentation
- **Agent Configuration**: Contact Field Readiness team for agent-specific questions
- **API Issues**: Check Salesforce API status and your organization's API limits

---

**Agent Information:**
- **Name**: QP Topic (1 Topic Only)
- **API Name**: QP_Topic_1
- **Company**: Field Readiness
- **Version**: 1.0

