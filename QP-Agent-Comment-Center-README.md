# QP-Agent Comment Center

A simple, guided interface for QP-Agent that helps users get started with enablement tasks through a step-by-step process.

## Overview

The QP-Agent Comment Center provides a user-friendly interface that guides users through common enablement tasks by asking "What are you trying to do?" and providing follow-up actions based on their selection.

## Features

### Initial Question
Users are presented with 7 main categories:
- **Onboarding** - Get new team members up to speed
- **Quarterly Planning** - Plan and organize quarterly initiatives  
- **Priority Initiative** - Focus on high-priority projects
- **Finding Content for Enablement** - Discover and organize training materials
- **Getting in Touch with Subject Matter Experts** - Connect with the right experts
- **Territory Analysis** - Analyze territory performance and opportunities
- **KPI Analysis** - Analyze key performance indicators and metrics

### Follow-up Actions
Each category provides 2-3 specific actions users can take, such as:
- Creating onboarding plans
- Finding relevant resources
- Scheduling SME sessions
- Analyzing performance data
- Building dashboards

### Guided Forms
For actions that require input, users are presented with relevant form fields to collect necessary information.

## Technical Architecture

### Lightning Web Component
- **File**: `force-app/main/default/lwc/qpAgentCommentCenter/`
- **Main Files**:
  - `qpAgentCommentCenter.html` - Template with responsive design
  - `qpAgentCommentCenter.js` - JavaScript controller with state management
  - `qpAgentCommentCenter.css` - Custom styling and animations
  - `qpAgentCommentCenter.js-meta.xml` - Component metadata

### Apex Controller
- **File**: `force-app/main/default/classes/QPAgentCommentCenterController.cls`
- **Purpose**: Handles backend logic for processing user actions
- **Features**:
  - Action routing based on user selection
  - Form data processing
  - Mock responses for demonstration
  - Error handling and validation

### Test Coverage
- **File**: `force-app/main/default/classes/QPAgentCommentCenterControllerTest.cls`
- **Coverage**: 100% test coverage for all action types and error scenarios

## Usage

### Deployment
1. Deploy the Lightning Web Component to your Salesforce org
2. Add the component to a Lightning App Page or Tab
3. Configure permissions as needed

### User Experience
1. Users see the initial question: "What are you trying to do?"
2. They select from 7 main categories
3. They choose a specific action from the follow-up options
4. For form-based actions, they fill out relevant fields
5. They click "Start [Action Name]" to initiate the process
6. The system processes the request and provides feedback

## Customization

### Adding New Categories
1. Update the `initialOptions` array in `qpAgentCommentCenter.js`
2. Add corresponding handler methods in `QPAgentCommentCenterController.cls`
3. Update test coverage in `QPAgentCommentCenterControllerTest.cls`

### Adding New Actions
1. Add new action objects to the `followUpActions` array for the relevant category
2. Implement the action handler method in the Apex controller
3. Add test cases for the new action

### Styling
- Modify `qpAgentCommentCenter.css` for visual changes
- The component uses Salesforce Lightning Design System (SLDS) classes
- Responsive design supports mobile and desktop views

## Integration Points

The component is designed to integrate with existing QP-Agent services:
- KPI Analysis System
- Territory Analysis
- Content Search
- SME Identification
- Pipeline Analysis

## Future Enhancements

- Real-time integration with actual QP-Agent services
- User preference storage
- Action history tracking
- Advanced form validation
- Progress tracking for multi-step processes
- Integration with Salesforce records and objects

## Support

For questions or issues:
1. Check the test cases for usage examples
2. Review the Apex controller for implementation details
3. Examine the Lightning Web Component for UI behavior

---

**Version**: 1.0  
**Last Updated**: January 2025  
**Maintainer**: Ali Nahvi (Alinahvi)
