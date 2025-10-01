# 📋 Updated Agent Description for ANAgent APM Nomination V2

**ANAgent APM Nomination V2 - Course Nomination for APM System**

**IMPORTANT SCOPE CLARIFICATION:**
This action creates **COURSE NOMINATIONS** for the external APM (Agent Performance Management) system. It does NOT search for courses, training materials, or sales data.

- ✅ **What this does**: Creates nominations for courses to be included in the APM system, submits course data to external APM API
- ❌ **What this does NOT do**: Search for courses, search for sales data, search for training materials

**Use this when users ask about:**
- Creating APM nominations for courses
- Submitting courses to the APM system
- Nominating courses for performance management
- APM course nominations and submissions

**Do NOT use this when users ask about:**
- Searching for courses or training materials
- Sales opportunities and pipeline data
- Learning content search
- Course completion rates or learner counts

## **Input Parameters:**
- offeringName: The name of the course/offering to nominate (REQUIRED)
- startDate: The start date of the nomination period (REQUIRED)
- endDate: The end date of the nomination period (REQUIRED)
- enablementsId: Enablement event/program identifier (auto-generated if not provided)
- programType: The type of program (defaults to "Training" if not provided)
- enablementTool: The tool or platform used for enablement (defaults to "Trailhead" if not provided)
- notes: Optional notes or additional information (auto-generated if not provided)
- createdUser: The name of the user creating the nomination (defaults to "Agent User" if not provided)

## **Common Query Patterns:**
- "Create an APM nomination for [COURSE_NAME] with start date [DATE] and end date [DATE]" → offeringName="[COURSE_NAME]", startDate="[DATE]", endDate="[DATE]"
- "Nominate [COURSE] for APM" → offeringName="[COURSE]", startDate/endDate required
- "Submit [COURSE] to APM system" → offeringName="[COURSE]", startDate/endDate required

## **Output Structure:**
The response contains nomination creation results with the following information:

### **Key Response Fields:**
- success: Whether the nomination was created successfully
- message: Detailed message about the nomination creation
- record: The created nomination record details
- nominationId: The ID of the created nomination record
- APM_PROCESSED_STATUS__c: Status from the APM API ("Success", "Failed", "Processing...")
- APM_STATUS_DETAILED__c: Detailed status message from the APM API

## **Display Guidelines:**

### **For Successful Nominations:**
- Confirm the nomination was created
- Show the nomination ID
- Display the APM API response status
- Example: "APM nomination created successfully. Nomination ID: [ID]. APM Status: Success"

### **For Failed Nominations:**
- Explain what went wrong
- Show the error message from the APM API
- Provide guidance on how to fix the issue
- Example: "APM nomination created but API call failed: [ERROR_MESSAGE]"

### **For Validation Errors:**
- Explain the validation issue
- Provide guidance on required fields
- Example: "Please provide a course name and valid start/end dates for the nomination period."

## **Important Rules:**
- **ALWAYS use this for APM nomination creation** - submitting courses to APM system
- **NEVER use this for course search** - use Content Search for finding courses
- **Require course name and dates** - these are mandatory fields
- **Auto-populate optional fields** - enablementsId, programType, enablementTool, notes, createdUser
- **Handle API responses** - show success/failure status from APM API
- **Provide clear error messages** - explain what went wrong and how to fix it
- **Use synchronous API calls** - provide immediate feedback to users

## **Example Responses:**

### **User asks: "Create an APM nomination for 'Becoming an AI Storyteller with Salesforce Einstein 1' with a start date of April 29th, 2025 and end date of June 28th, 2025"**
**Correct Response:**
"APM nomination created successfully!

**Nomination Details:**
- Course Name: Becoming an AI Storyteller with Salesforce Einstein 1
- Start Date: April 29th, 2025
- End Date: June 28th, 2025
- Nomination ID: [GENERATED_ID]
- APM Status: Success
- APM Message: Nomination submitted successfully to APM system

The course has been successfully nominated and submitted to the APM system for processing."

### **User asks: "Create an APM nomination for 'Tableau Fundamentals'"**
**Correct Response:**
"I need a bit more information to create the APM nomination. Please provide:

1. **Start Date**: When should the nomination period begin?
2. **End Date**: When should the nomination period end?

For example: 'Create an APM nomination for Tableau Fundamentals with start date January 1st, 2025 and end date March 31st, 2025'"

### **User asks: "Nominate 'Invalid Course Name' for APM"**
**Possible Response (if API returns error):**
"APM nomination created but the external APM system rejected it:

**Nomination Details:**
- Course Name: Invalid Course Name
- Nomination ID: [GENERATED_ID]
- APM Status: Failed
- APM Error: [ERROR_MESSAGE_FROM_API]

The nomination was created in our system, but the external APM system rejected it. Please verify the course name and try again with a valid course."

## **Technical Notes:**
- This creates records in the `apm_nomination_v2__c` object
- Makes synchronous API calls to external APM system
- Auto-generates enablement IDs and other optional fields
- Validates dates (end date must be at least 30 days prior to today)
- Handles various API error responses (insufficient learners, date validation, duplicate offerings)
- This is specifically for creating APM nominations, not for searching or viewing data 