# SubmitAgentFeedback

## Overview
Creates Work tickets for Field Readiness Agent user feedback, issues, and feature gaps with intelligent routing and auto-classification.

## Version
**V1.0** - Released 2025-11-02

## Components

### Handler Class
- **File**: `ANAgentEOAFeedbackHandler.cls`
- **Label**: `SubmitAgentFeedback`
- **Type**: Invocable Method (Agent Action)
- **Purpose**: Validates input and routes to service

### Service Class  
- **File**: `ANAgentEOAFeedbackService.cls`
- **Type**: Business Logic Service
- **Purpose**: Creates Work tickets with auto-routing and classification

### Metadata Files
- `ANAgentEOAFeedbackHandler.cls-meta.xml` (API Version: 65.0)
- `ANAgentEOAFeedbackService.cls-meta.xml` (API Version: 65.0)

## Key Features

### Auto-Routing by Topic
Intelligently routes feedback to correct Epic:
- **QP Topic Epic**: Search Content, Programs, OpenPipe, FuturePipe, KPI, Planning
- **Cohort Management Epic**: Audience Creation, Audience Grouping

### Auto-Classification
**Issue Types**:
- BUG: Functional errors
- FEATURE_GAP: Missing functionality
- ENHANCEMENT: Improvements
- QUESTION: Needs clarification
- OTHER: Uncategorized
- AUTO: System classifies based on keywords

**Work Types**:
- Bug (for BUG issues)
- User Story (for others)

### Auto-Severity Detection
Analyzes feedback text and conversation context:
- **CRITICAL**: System-wide blockers, data issues → P0
- **HIGH**: Significant impact → P1
- **MEDIUM**: Moderate impact → P2
- **LOW**: Minor issues → P3

### Keywords for Severity
**CRITICAL**:
- blocking, blocker, system down, completely broken
- all users, production down, data loss, security issue
- urgent, emergency, cannot work, unusable

**HIGH**:
- major issue, significant problem, high priority
- severely impacts, serious bug, affecting many
- core functionality, broken for

**MEDIUM**:
- sometimes fails, intermittent, inconsistent
- workaround exists, moderate impact, enhancement

## Input Parameters

### Required
- `feedbackText`: Issue description or feature gap (min 10 characters, max 32,000)

### Optional
- `agentTopic`: QP | COHORT | AUTO (default: AUTO)
- `issueType`: BUG | FEATURE_GAP | ENHANCEMENT | QUESTION | OTHER | AUTO (default: AUTO)
- `sessionId`: Agent session identifier
- `conversationContext`: Conversation excerpt (max 10,000 chars)
- `reporterName`: Person reporting (defaults to current user)

## Output Structure

```json
{
  "ok": true,
  "data": {
    "workId": "a4g...",
    "workNumber": "W-12345",
    "subject": "FR Agent Feedback: QP - Bug Report",
    "type": "Bug",
    "status": "New",
    "priority": "P1",
    "epicName": "QP Topic",
    "projectName": "FR Agent Feedback",
    "assignedTo": "Praveen Kumar",
    "reportedBy": "John Smith",
    "sessionId": "session-abc123",
    "confirmationMessage": "Feedback ticket W-12345 created successfully..."
  }
}
```

## Project Configuration

### FR Agent Feedback Project
- **Project Name**: `FR Agent Feedback`
- **Epics**:
  - QP Topic
  - Cohort Management
- **Default Assignee**: Praveen Kumar (User ID: 005Hu00000Qs8ecIAB)
- **Default Scrum Team**: Agentforce Learning Transformation (a4fHu000001d54cIAA)
- **Default Product Tag**: Agentforce Learning Transformation (a4SHu000004cT5QMAU)

### Topic Keywords
**QP Topic**:
- search content, search program, openpipe, futurepipe
- kpi analysis, quarterly planning, engine

**Cohort Management**:
- cohort, audience, grouping, audience creation
- cohort management

## Work Item Structure

### Subject Format
```
FR Agent Feedback: {Topic} - {IssueLabel}
```

### Description Template
```
=== FR AGENT FEEDBACK ===

FEEDBACK:
{User feedback text}

METADATA:
  • Topic Area: {Epic Name}
  • Issue Classification: {Issue Type}
  • Severity: {Auto-detected severity}
  • Reporter: {Reporter name}
  • Submitted: {Timestamp}
  • Session ID: {Session ID if provided}

CONVERSATION CONTEXT:
{Conversation excerpt if provided}

=== AUTO-CREATED BY FR AGENT FEEDBACK ACTION ===
```

## Deployment Instructions

### Prerequisites
- Access to Agile Accelerator package:
  - `agf__ADM_Work__c` (Create permission required)
  - `agf__PPM_Project__c` (Read permission)
  - `agf__ADM_Epic__c` (Read permission)
- FR Agent Feedback project setup
- QP Topic and Cohort Management epics created
- FRPermissionGuard utility

### Setup Steps
1. Create FR Agent Feedback project in Agile Accelerator
2. Create two epics: "QP Topic" and "Cohort Management"
3. Verify Praveen Kumar user exists (ID: 005Hu00000Qs8ecIAB)
4. Deploy Handler and Service classes
5. Test with sample feedback

## Dependencies
- `FRPermissionGuard`
- `agf__ADM_Work__c` (Agile Accelerator)
- `agf__PPM_Project__c` (Agile Accelerator)
- `agf__ADM_Epic__c` (Agile Accelerator)

## Error Handling
Comprehensive error responses with:
- INVALID_INPUT: Missing or invalid fields
- INSUFFICIENT_ACCESS: Permission errors
- DML_ERROR: Database insert errors
- QUERY_ERROR: Project/Epic lookup errors
- CONFIGURATION_ERROR: Project/Epic not found
- UNEXPECTED_ERROR: System errors

## Example Usage

### Submit Bug Report
```json
{
  "feedbackText": "Search Content action returned no results when searching for Agentforce courses created after Jan 2025",
  "issueType": "BUG",
  "agentTopic": "QP"
}
```

### Submit Feature Gap
```json
{
  "feedbackText": "Need ability to filter cohorts by manager name",
  "issueType": "FEATURE_GAP",
  "agentTopic": "COHORT",
  "conversationContext": "User tried filtering cohorts multiple ways, none worked for manager filter"
}
```

### Auto-classified Feedback
```json
{
  "feedbackText": "KPI Analysis fails with permission error when analyzing EMEA region",
  "sessionId": "conv-2025-11-02-001"
}
```

## Validation Rules
- Feedback text: 10-32,000 characters
- Conversation context: max 10,000 characters
- Additional details: max 255 characters (in Work description)

## Support
All tickets are automatically assigned to **Praveen Kumar** for triage.

For setup issues, contact: Ali Nahvi (Alinahvi)

