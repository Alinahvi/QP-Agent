# CSV Download Service - Agent Action Setup Guide

## 🎯 **Overview**
The `ANAgentCSVDownloadService` creates **actual downloadable CSV files** instead of just text content. This replaces the old `ANAgentCSVAggregatorService` to provide users with real downloadable files.

## 📋 **Action Configuration**

### **Action Name**
`Generate and Download CSV File`

### **Class Name**
`ANAgentCSVDownloadService`

### **Method Name**
`generateAndDownloadCSV`

### **Description**
Generates CSV data from agent actions and creates a downloadable file in one step. Users get actual CSV files they can download, not just text content.

---

## 🔧 **Required Input Variables**

| Variable | Type | Required | Description | Example |
|----------|------|----------|-------------|---------|
| `userRequest` | String | ✅ | Natural language request for CSV export | "Export top 10 courses related to data cloud" |
| `actionResults` | String | ✅ | JSON string containing results from existing agent actions | `{"content_results":{"results":[...]}}` |
| `fileName` | String | ❌ | Custom filename for the CSV (optional) | "Data_Cloud_Courses.csv" |
| `description` | String | ❌ | Description of the file content (optional) | "Top Data Cloud courses with completion rates" |
| `requestId` | String | ❌ | Unique identifier for tracking (optional) | "REQ-12345" |
| `includeMetadata` | Boolean | ❌ | Whether to include metadata in CSV (default: false) | false |

---

## 📤 **Output Variables**

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `success` | Boolean | Whether the CSV file creation was successful | true |
| `fileId` | String | Salesforce File ID of the created CSV file | "069D7000002io2rIAA" |
| `fileUrl` | String | Direct download URL for the CSV file | "/sfc/servlet.shepherd/document/download/069D7000002io2rIAA" |
| `fileName` | String | Name of the created file | "Data_Cloud_Courses.csv" |
| `recordCount` | Integer | Total number of records in the CSV | 10 |
| `columnCount` | Integer | Number of columns in the CSV | 4 |
| `message` | String | Success message or error details with resolution guidance | "CSV file created successfully! 10 records exported..." |
| `requestId` | String | Echo of the original request ID for tracking | "REQ-12345" |

---

## 🤖 **Agent Instructions**

### **When to Use This Action**
Use this action when users request CSV exports or downloads. This action:
- ✅ Creates **actual downloadable CSV files** (not just text)
- ✅ Provides **download URLs** for users
- ✅ Handles **complex multi-object joins**
- ✅ Includes **proper error handling**

### **Workflow Steps**
1. **Execute required agent actions** first (content search, OpenPipe, SME search, etc.)
2. **Collect the action results** as JSON strings
3. **Call this CSV Download Service** with the results
4. **Provide the download URL** to the user

### **Example Agent Response**
```
🎉 Your CSV file has been created successfully!
📊 Export Summary:
   • File: Data_Cloud_Courses.csv
   • Records: 10 courses
   • Columns: 4 data points
   • Request ID: REQ-12345

📥 Download your file here:
/sfc/servlet.shepherd/document/download/069D7000002io2rIAA

The file contains all the Data Cloud courses with their completion rates, learner counts, and descriptions.
```

---

## 📝 **Usage Examples**

### **Example 1: Single Object Export**
```
User: "Export all courses related to data cloud"
Agent: 
1. Call content search action
2. Call CSV Download Service with results
3. Provide download URL
```

### **Example 2: Multi-Object Export**
```
User: "Export AE performance with SME details"
Agent:
1. Call OpenPipe action for AE data
2. Call SME search action
3. Call CSV Download Service with both results
4. Provide download URL for joined data
```

### **Example 3: Complex Export**
```
User: "Export top products with SME and course data"
Agent:
1. Call OpenPipe action for product data
2. Call SME search action
3. Call content search action for courses
4. Call CSV Download Service with all three results
5. Provide download URL for complex joined data
```

---

## 🔄 **Migration from Old Service**

### **Replace This:**
```json
{
  "actionName": "Generate CSV from Actions",
  "className": "ANAgentCSVAggregatorService",
  "methodName": "generateCSVFromActions"
}
```

### **With This:**
```json
{
  "actionName": "Generate and Download CSV File",
  "className": "ANAgentCSVDownloadService", 
  "methodName": "generateAndDownloadCSV"
}
```

---

## ⚠️ **Error Handling**

### **Common Errors and Solutions**

| Error | Cause | Solution |
|-------|-------|----------|
| "Failed to generate CSV data" | Invalid JSON in actionResults | Ensure agent actions return valid JSON |
| "Failed to create CSV file" | Permission or file creation issue | Check user permissions for file creation |
| "No data found" | Empty action results | Verify agent actions returned data |

### **Error Response Example**
```
❌ I encountered an issue while creating your CSV file.
Error: Failed to generate CSV data: Invalid JSON format
Please try again or contact support if the issue persists.
```

---

## 🔒 **Security & Permissions**

### **Required Permissions**
- ✅ `ANAgentCSVDownloadService` - Full access
- ✅ `ANAgentCSVAggregatorService` - Read access (used internally)
- ✅ `ANAgentCSVFileService` - Read access (used internally)
- ✅ File creation permissions

### **Data Security**
- ✅ Only processes data from existing agent actions
- ✅ No direct database access
- ✅ File access controlled by Salesforce permissions

---

## 🚀 **Performance Considerations**

### **Optimization Tips**
- ✅ **Metadata is disabled by default** for cleaner CSV files
- ✅ **Only enable metadata** when user specifically requests it or for debugging
- ✅ **Clean CSV files** contain only data, no metadata headers
- ✅ Limit record counts in source actions
- ✅ Use specific file names for better organization

### **Limits**
- ✅ Maximum file size: 2GB
- ✅ Maximum records: Based on source data
- ✅ CPU time: Within Salesforce limits

---

## 📞 **Support & Troubleshooting**

### **Testing the Action**
Use the test script: `test-csv-download-scenarios.apex`

### **Common Issues**
1. **Agent still shows text content**: Ensure using `ANAgentCSVDownloadService`, not `ANAgentCSVAggregatorService`
2. **Permission errors**: Check user has file creation permissions
3. **Invalid JSON**: Verify agent actions return valid JSON format

### **Success Indicators**
- ✅ `success = true`
- ✅ Valid `fileUrl` returned
- ✅ User can download actual CSV file
- ✅ File opens in spreadsheet applications

---

## 🎯 **Key Benefits**

### **For Users:**
- ✅ **Actual downloadable files** (not just text)
- ✅ **Direct download URLs**
- ✅ **Proper CSV formatting**
- ✅ **File metadata and descriptions**

### **For Agents:**
- ✅ **One-step CSV generation and download**
- ✅ **Complex multi-object joins**
- ✅ **Robust error handling**
- ✅ **Production-ready reliability**

---

## 📋 **Implementation Checklist**

- [ ] Add `ANAgentCSVDownloadService` to agent actions
- [ ] Remove or deprecate old `ANAgentCSVAggregatorService`
- [ ] Update agent instructions to use new service
- [ ] Test with various scenarios
- [ ] Verify file downloads work correctly
- [ ] Update user documentation

---

**🎉 Result: Users get actual downloadable CSV files instead of just text content!** 