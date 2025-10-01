# CSV Download URL Access Guide

## Issue
Users may encounter "page doesn't exist" errors when clicking CSV download links.

## Root Cause
The generated URLs are relative paths that work within the Salesforce Lightning Experience context, but may not work when accessed directly or from certain interfaces.

## Solutions

### Solution 1: Manual File Access (Recommended)
1. **Go to Files Tab**: Navigate to the Files tab in Salesforce
2. **Search by File ID**: Use the File ID provided in the agent response
3. **Download**: Click on the file and download it directly

### Solution 2: Construct Full URL
If you have the File ID, construct the full URL:
```
https://[your-instance].salesforce.com/lightning/r/ContentDocument/[FILE-ID]/view
```

### Solution 3: Alternative URL Formats
Try these alternative URL patterns:
- `/lightning/r/ContentDocument/[FILE-ID]/view` (current)
- `/lightning/r/ContentDocument/[FILE-ID]/related/ContentVersions`
- `/sfc/servlet.shepherd/version/download/[VERSION-ID]`

## Updated Agent Response Format

The agent should now provide responses like this:

```
🎉 Your CSV file has been created successfully!

 Export Summary:
   • File: Data_Cloud_Courses.csv
   • Records: 10 courses
   • Columns: 4 data points
   • Request ID: REQ-12345

 Download your file here:
/lightning/r/ContentDocument/069D7000002io2KIAQ/view

 📁 Alternative Access:
   • File ID: 069D7000002io2KIAQ
   • Go to Files tab → Search for this File ID
   • Or construct full URL: https://[instance].salesforce.com/lightning/r/ContentDocument/069D7000002io2KIAQ/view

The file contains all Data Cloud courses with completion rates and learner counts.
```

## Troubleshooting Steps

1. **Check File Exists**: Verify the file was created by checking the Files tab
2. **Verify Permissions**: Ensure user has access to the file
3. **Try Manual Access**: Use the Files tab instead of direct URL
4. **Check Instance**: Make sure you're using the correct Salesforce instance URL
5. **Contact Admin**: If issues persist, check file sharing settings

## Prevention

- Always provide the File ID in agent responses
- Include manual access instructions
- Test URLs in the same context where they'll be used
- Consider using email attachments for critical downloads 