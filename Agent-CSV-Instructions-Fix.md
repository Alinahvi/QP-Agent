# CSV Export and Download Service - CORRECTED INSTRUCTIONS

## Overview
This agent can create downloadable CSV files from various data sources. The URL format `/sfc/servlet.shepherd/document/download/` is working correctly - the issue is with JSON formatting.

## CRITICAL: JSON Format Fix
The agent MUST format action results with the EXACT structure below. This is the ONLY change needed.

### CORRECT Format (MUST USE):
```json
{"content_results":{"results":[{"name":"Course Name","learnerCount":1234,"completionRate":50.5,"description":"Course description"}]}}
```

### INCORRECT Format (DO NOT USE):
```json
{"courses":[{"name":"Course Name","learnerCount":1234,"completionRate":50.5,"description":"Course description"}]}
```

## Key Points:
- **Outer key**: MUST be `"content_results"` (not "courses")
- **Inner key**: MUST be `"results"` (not "data")
- **Structure**: `{"content_results":{"results":[...]}}`
- **URL format**: Keep using `/sfc/servlet.shepherd/document/download/` (it works)

## Workflow:
1. Execute agent actions to get data
2. Format results as: `{"content_results":{"results":[...]}}`
3. Call CSV Download Service
4. Provide download URL (the existing format works)

## Example Response:
```
🎉 Your CSV file has been created successfully!

 Export Summary:
   • File: Data_Cloud_Courses.csv
   • Records: 10 courses
   • Columns: 4 data points

 Download your file here:
/sfc/servlet.shepherd/document/download/069D7000002io2rIAA

The file contains all Data Cloud courses with completion rates and learner counts.
```

## The Fix:
The agent needs to change from `"courses"` to `"content_results"` in the JSON structure. That's it. 