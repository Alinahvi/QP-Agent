# SearchContentV6

## Overview
Unified search across ACT Learning Content (45,000+ courses, assets, curricula) and Consensus Demo Videos (2,000+ demos) with intelligent routing and lifecycle metrics.

## Version
**V6.0** - Released 2025-11-04

## Components

### Handler Class
- **File**: `ANAgentContentSearchHandlerV6.cls`
- **Label**: `SearchContentV6`
- **Type**: Invocable Method (Agent Action)
- **Purpose**: Input validation and flexible type conversion

### Service Class  
- **File**: `ANAgentContentSearchServiceV6.cls`
- **Type**: Business Logic Service
- **Purpose**: Content search, intelligent routing, lifecycle metrics

### Metadata Files
- `ANAgentContentSearchHandlerV6.cls-meta.xml` (API Version: 60.0)
- `ANAgentContentSearchServiceV6.cls-meta.xml` (API Version: 60.0)

## Key Features

### V6 Improvements from V5
- ✅ AgentCore_PermissionValidator replaces FRPermissionGuard
- ✅ AgentCore_Exception for consistent error handling
- ✅ AgentCore_Constants for standardized codes
- ✅ Removed FRSearchGuard and FRResult dependencies
- ✅ Enhanced validation with inline methods

### Content Sources
1. **ACT Learning Content**
   - Objects: `Course__c`, `Asset__c`, `Curriculum__c`
   - Metrics: Enrollment count, completion rate, CSAT scores
   - Status filtering: Active/Draft/Archived

2. **Consensus Demo Videos**
   - Object: `Agent_Consensu__c`
   - Published/archived status
   - Preview links

### Search Modes
- **AUTO** (default): Intelligent routing based on keywords
- **ACT**: Search only ACT learning content
- **CONSENSUS**: Search only Consensus demo videos
- **BOTH**: Search both sources

### Lifecycle Metrics
- Enrollment count
- Completion rate
- CSAT scores (Course only)
- High performers identification
- Low enrollment/completion/CSAT flags

## Input Parameters

### Required
- `searchTerm`: Product name, topic, or keyword (min 2 chars)

### Optional
- `contentType`: COURSE | ASSET | CURRICULUM | ALL (ACT only)
- `searchMode`: AUTO | ACT | CONSENSUS | BOTH
- `userUtterance`: Full user query for AUTO routing
- `createdSince`: Created after date (YYYY-MM-DD)
- `createdBefore`: Created before date (YYYY-MM-DD)
- `sortBy`: ENROLLMENT | CSAT | COMPLETION | CREATED_DATE | DEFAULT
- `sortOrder`: ASC | DESC (default: DESC)
- `limitStr`: Max results (1-500, default: 100)
- `includeInactiveStr`: Include archived content (default: false)

## Output Structure

```json
{
  "ok": true,
  "data": {
    "analysisType": "CONTENT_SEARCH_ACT",
    "searchTerm": "Tableau",
    "routing": "Auto-routed to ACT (default for content searches)",
    "sortBy": "DEFAULT",
    "sortOrder": "DESC",
    "dateRange": "all dates",
    "summary": {
      "totalContent": 78,
      "totalEnrollment": 4567,
      "totalCompletions": 3456,
      "avgCompletionRate": 75.6,
      "avgCSAT": 4.2,
      "highPerformers": 12,
      "lowEnrollment": 8,
      "lowCompletion": 5,
      "lowCSAT": 2
    },
    "records": [
      {
        "id": "a0Y...",
        "name": "Tableau Fundamentals",
        "type": "Course",
        "status": "Active",
        "link": "https://...",
        "createdDate": "2024-08-15T10:30:00.000Z",
        "description": "Learn Tableau basics...",
        "enrollment": 245,
        "completionRate": 78.5,
        "csat": 4.3
      }
    ]
  }
}
```

## Intelligent Routing

### AUTO Mode Keywords
**Consensus Keywords** (routes to demo videos):
- consensus, demo, video, presentation, demo pack, demo video

**ACT Keywords** (routes to learning content):
- act, course, training, learning, curriculum, asset, content, certification

**Behavior**:
- Both keywords present → BOTH mode
- Only Consensus keywords → CONSENSUS mode
- Only ACT or no keywords → ACT mode (default)

## Deployment Instructions

### Prerequisites
- Access to ACT objects: `Course__c`, `Asset__c`, `Curriculum__c`
- Access to `Agent_Consensu__c`
- Access to `Assigned_Course__c` (for metrics)
- AgentCore framework

### Deploy Order
1. Deploy Service: `ANAgentContentSearchServiceV6.cls`
2. Deploy Handler: `ANAgentContentSearchHandlerV6.cls`
3. Deploy metadata files

## Dependencies
- `AgentCore_PermissionValidator`
- `AgentCore_Exception`
- `AgentCore_Constants`
- `Course__c`
- `Asset__c`
- `Curriculum__c`
- `Agent_Consensu__c`
- `Assigned_Course__c`

## Example Usage

### Find Tableau Training
```json
{
  "searchTerm": "Tableau",
  "contentType": "COURSE",
  "sortBy": "CSAT"
}
```

### Find Recent Agentforce Content
```json
{
  "searchTerm": "Agentforce",
  "createdSince": "2025-01-01",
  "sortBy": "CREATED_DATE"
}
```

### Find Demo Videos
```json
{
  "searchTerm": "Einstein",
  "searchMode": "CONSENSUS"
}
```

## Performance Thresholds
- Low Enrollment: < 20 learners
- Low Completion: < 25%
- Low CSAT: < 3.0
- High CSAT: >= 4.0
- High Completion: >= 70%

## Support
Contact Sales Operations Team for support.

