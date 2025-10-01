# Email Service Agent Action Guide

## Overview
The Email Service allows the AI agent to send emails to Salesforce.com domain addresses only, with built-in security validation and support for both plain text and HTML emails.

## Apex Class Information

### Primary Class: `ANAgentEmailHandler`
- **Type**: Invocable Apex Class
- **Purpose**: Send emails from the AI agent with domain restrictions
- **Security**: Only allows Salesforce.com domain addresses

### Service Class: `ANAgentEmailService`
- **Type**: Core Business Logic Class
- **Purpose**: Handles email validation, sending, and error handling

## Agent Builder Configuration

### Action Name
```
Send Email (Salesforce Domain Only)
```

### Description
```
Send email from agent. Only Salesforce.com domain addresses are allowed for security. Supports both plain text and HTML emails.
```

### Method Name
```
sendEmail
```

### Class Name
```
ANAgentEmailHandler
```

## Required Input Variables

### 1. recipientEmail (String)
- **Description**: The email address of the recipient
- **Required**: Yes
- **Validation**: Must be a valid email format and end with @salesforce.com
- **Example**: `anahvi@salesforce.com`
- **Agent Instruction**: "Enter the recipient's email address. Must be a Salesforce.com domain address."

### 2. subject (String)
- **Description**: The subject line of the email
- **Required**: Yes
- **Max Length**: 255 characters
- **Example**: `Test Email from Agentforce AI Assistant`
- **Agent Instruction**: "Enter a clear, descriptive subject line for the email."

### 3. body (String)
- **Description**: The plain text body of the email
- **Required**: Yes (if htmlBody is not provided)
- **Max Length**: 32,000 characters
- **Example**: `Hello! This is a test email sent by the Agentforce AI Assistant.`
- **Agent Instruction**: "Enter the main content of the email in plain text format."

### 4. htmlBody (String)
- **Description**: The HTML body of the email (optional)
- **Required**: No
- **Max Length**: 32,000 characters
- **Example**: `<html><body><h1>Hello!</h1><p>This is an <strong>HTML email</strong>.</p></body></html>`
- **Agent Instruction**: "Enter HTML formatted content if you want rich formatting. If provided, this will be used instead of the plain text body."

### 5. senderName (String)
- **Description**: Custom sender name for the email
- **Required**: No
- **Max Length**: 80 characters
- **Default**: "Agentforce AI Assistant"
- **Example**: `Agentforce AI Assistant`
- **Agent Instruction**: "Enter a custom sender name for the email. If not provided, will use default name."

## Output Variables

### 1. success (Boolean)
- **Description**: Indicates whether the email was sent successfully
- **Values**: `true` or `false`
- **Agent Usage**: Use to determine if the email action completed successfully

### 2. message (String)
- **Description**: Success message or error details
- **Examples**: 
  - Success: `Email sent successfully to anahvi@salesforce.com`
  - Error: `Invalid email domain. Only Salesforce.com addresses are allowed.`
- **Agent Usage**: Display to user or use for error handling

### 3. emailId (String)
- **Description**: Confirmation ID or status message
- **Example**: `Email sent successfully`
- **Agent Usage**: Provide confirmation to user

## Agent Instructions for Email Usage

### When to Use Email Service
- When user requests to send an email
- When user needs to communicate with Salesforce team members
- When user wants to send notifications or updates
- When user needs to share information via email

### Security Guidelines
- **ALWAYS** validate that the recipient email ends with `@salesforce.com`
- **NEVER** attempt to send emails to external domains
- **ALWAYS** inform the user about the domain restriction
- **ALWAYS** provide clear error messages if validation fails

### Email Content Guidelines
- Use professional, clear language
- Include relevant context from the conversation
- Keep subject lines descriptive and concise
- Use appropriate formatting (plain text or HTML)
- Include sender name for clarity

### Error Handling
- If email validation fails, explain the restriction to the user
- If email format is invalid, suggest the correct format
- If sending fails, provide helpful error message
- Always check the `success` output before confirming to user

## Example Usage Scenarios

### Scenario 1: Send Test Email
**User Request**: "Send a test email to anahvi@salesforce.com"
**Agent Action**:
- Input: recipientEmail = "anahvi@salesforce.com"
- Input: subject = "Test Email from Agentforce AI Assistant"
- Input: body = "Hello Anahvi! This is a test email sent by the Agentforce AI Assistant."
- Input: senderName = "Agentforce AI Assistant"

### Scenario 2: Send HTML Email
**User Request**: "Send an HTML email to john@salesforce.com with formatted content"
**Agent Action**:
- Input: recipientEmail = "john@salesforce.com"
- Input: subject = "Important Update"
- Input: htmlBody = "<html><body><h1>Important Update</h1><p>This is <strong>formatted</strong> content.</p></body></html>"
- Input: body = "Important Update - This is formatted content." (fallback)

### Scenario 3: Invalid Domain Attempt
**User Request**: "Send email to user@gmail.com"
**Agent Response**: "I can only send emails to Salesforce.com domain addresses for security reasons. Please provide a Salesforce.com email address."

## Integration with Agent Instructions

### Add to Agent Instructions
```
## Email Capabilities
You can send emails to Salesforce.com domain addresses only. When a user requests to send an email:

1. Validate the recipient email ends with @salesforce.com
2. Collect required information (recipient, subject, body)
3. Use the "Send Email (Salesforce Domain Only)" action
4. Check the success output and inform the user of the result
5. If validation fails, explain the domain restriction

### Email Security
- Only Salesforce.com domain addresses are allowed
- All emails are logged and monitored
- Use professional language and clear subject lines
- Include relevant context from the conversation
```

## Testing the Email Action

### Test Script
```apex
// Test the email action
ANAgentEmailHandler.EmailRequest request = new ANAgentEmailHandler.EmailRequest();
request.recipientEmail = 'anahvi@salesforce.com';
request.subject = 'Test Email from Agent';
request.body = 'This is a test email sent by the agent.';
request.senderName = 'Agentforce AI Assistant';

List<ANAgentEmailHandler.EmailResponse> responses = 
    ANAgentEmailHandler.sendEmail(new List<ANAgentEmailHandler.EmailRequest>{request});

System.debug('Success: ' + responses[0].success);
System.debug('Message: ' + responses[0].message);
```

## Permission Requirements

### Permission Set
- **Name**: AEAE_AN_Agents_CRUD
- **Classes**: ANAgentEmailService, ANAgentEmailHandler
- **Status**: ✅ Already included in permission set

### User Permissions
- Users must have the permission set assigned
- Users must have email sending permissions in Salesforce
- Users must have access to the org's email settings

## Troubleshooting

### Common Issues
1. **Invalid Email Domain**: Ensure recipient ends with @salesforce.com
2. **Email Format Error**: Check email format (user@domain.com)
3. **Permission Error**: Verify user has required permission set
4. **Sending Failure**: Check org email settings and limits

### Error Messages
- `Invalid email domain. Only Salesforce.com addresses are allowed.`
- `Invalid email format. Please use format: user@domain.com`
- `Email sending failed. Please try again later.`
- `Permission denied. Contact your administrator.`

## Best Practices

### For Agent Implementation
1. Always validate email domains before sending
2. Provide clear feedback to users
3. Use appropriate subject lines
4. Include relevant context in email body
5. Handle errors gracefully

### For User Experience
1. Explain domain restrictions upfront
2. Provide helpful error messages
3. Confirm successful email sending
4. Offer alternatives for external emails
5. Maintain professional communication

## Summary

The Email Service provides a secure, controlled way for the AI agent to send emails within the Salesforce organization. With proper validation, error handling, and user guidance, it can be a valuable tool for communication and notifications while maintaining security standards. 