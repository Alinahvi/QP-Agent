# CSV Aggregator Service - Agent Action Integration Guide

## 🎯 **Action Overview**

**Action Name**: `ANAgentCSVAggregatorService.generateCSVFromActions`  
**Class Name**: `ANAgentCSVAggregatorService`  
**Description**: Creates dynamic CSV exports by aggregating results from existing agent actions with minimal transformation. Supports single object exports and complex multi-object joins based on user intent.

## 📋 **Required Input Variables**

### **1. userRequest** (String - Required)
- **Label**: User Request
- **Description**: Natural language request for CSV export (e.g., "Export all courses related to data cloud + their APM result")
- **Example**: `"Export top pipe gen product in AMER + SME for each product"`
- **Agent Instructions**: Extract the user's CSV export request from the conversation context. This should be the exact request the user made for the CSV export.

### **2. actionResults** (String - Required)
- **Label**: Agent Action Results
- **Description**: JSON string containing results from existing agent actions that have been executed
- **Format**: Valid JSON string with nested action results
- **Example**: 
```json
{
  "openpipe_results": {
    "results": [
      {
        "PRODUCT_L3__c": "Data Cloud",
        "TOTAL_ACV__c": 2500000,
        "EMPLOYEE_LOCATION_REGION__c": "AMER"
      }
    ]
  },
  "sme_results": {
    "results": [
      {
        "PRODUCT_L3__c": "Data Cloud",
        "AE_NAME__c": "Mike Chen",
        "expertise_level": "Expert"
      }
    ]
  }
}
```
- **Agent Instructions**: Combine the results from all relevant agent actions into a single JSON string. Each action's results should be nested under a descriptive key (e.g., "openpipe_results", "sme_results", "content_results").

### **3. requestId** (String - Optional)
- **Label**: Request ID
- **Description**: Unique identifier for tracking this request
- **Example**: `"REQ-2024-001"`
- **Agent Instructions**: Generate a unique identifier for this CSV request. Can use timestamp or incremental numbering.

### **4. includeMetadata** (Boolean - Optional)
- **Label**: Include Metadata
- **Description**: Whether to include metadata about data sources in CSV (default: true)
- **Default Value**: `true`
- **Agent Instructions**: Set to true to include helpful metadata in the CSV output, such as generation date, user request, and join type.

## 📤 **Output Variables**

### **1. success** (Boolean)
- **Label**: Success
- **Description**: Indicates whether the CSV generation was successful
- **Agent Instructions**: Check this first to determine if the CSV was generated successfully.

### **2. csvData** (String)
- **Label**: CSV Data
- **Description**: The generated CSV content as a string, ready for export or further processing
- **Agent Instructions**: This contains the actual CSV data that should be presented to the user. It includes headers, data rows, and metadata if requested.

### **3. recordCount** (Integer)
- **Label**: Record Count
- **Description**: Total number of records in the generated CSV
- **Agent Instructions**: Use this to inform the user how many records were included in the export.

### **4. columnCount** (Integer)
- **Label**: Column Count
- **Description**: Number of columns in the generated CSV
- **Agent Instructions**: Use this to inform the user about the structure of the exported data.

### **5. message** (String)
- **Label**: Message
- **Description**: Success message or error details with resolution guidance
- **Agent Instructions**: Present this message to the user. If success is false, this contains error details and resolution steps.

### **6. metadata** (String)
- **Label**: Metadata
- **Description**: Information about data sources and processing strategy used
- **Agent Instructions**: This contains technical details about how the data was processed. Can be used for debugging or to explain the aggregation strategy to the user.

### **7. requestId** (String)
- **Label**: Request ID
- **Description**: Echo of the original request ID for tracking
- **Agent Instructions**: Use this for request tracking and debugging purposes.

## 🎯 **Agent Instructions**

### **When to Use This Action**
Use the CSV Aggregator Service when users request:
- CSV exports of data from your existing agent actions
- Combined data from multiple sources (e.g., "products + SMEs")
- Dynamic exports with flexible column selection
- Data analysis or reporting in spreadsheet format

### **Workflow Steps**
1. **Identify User Intent**: Determine what data the user wants to export
2. **Execute Required Actions**: Run the necessary agent actions first:
   - `ANAgentOpenPipeHandlerV2` for performance/territory data
   - `ANAgent Search SMEs` for expert information
   - `ANAgentAPMNominationHandlerV2` for APM data
   - `ANAgentContentSearchHandlerV2` for course/content data
3. **Collect Results**: Gather results from all executed actions
4. **Combine Data**: Merge action results into a single JSON string
5. **Call CSV Aggregator**: Execute this action with the combined data
6. **Present Results**: Show the CSV data to the user with metadata

### **Supported Use Cases**

#### **Single Object Export**
```
User: "Export all courses related to data cloud"
Agent Actions: Execute ANAgentContentSearchHandlerV2
Input: actionResults = JSON from content search
Output: CSV with course data (name, learnerCount, completionRate, etc.)
```

#### **Multi-Object Join**
```
User: "Export top pipe gen product in AMER + SME for each product"
Agent Actions: Execute ANAgentOpenPipeHandlerV2 + ANAgent Search SMEs
Input: actionResults = Combined JSON from both actions
Output: CSV with product performance + SME information joined by product
```

#### **Complex Aggregation**
```
User: "Export all courses related to data cloud + their APM result"
Agent Actions: Execute ANAgentContentSearchHandlerV2 + ANAgentAPMNominationHandlerV2
Input: actionResults = Combined JSON from both actions
Output: CSV with course data + APM nomination results joined by course name
```

## 🔧 **Technical Implementation**

### **JSON Structure for actionResults**
```json
{
  "action_name_1": {
    "results": [
      {
        "field1": "value1",
        "field2": "value2"
      }
    ]
  },
  "action_name_2": {
    "results": [
      {
        "field3": "value3",
        "field4": "value4"
      }
    ]
  }
}
```

### **Common Action Result Keys**
- `openpipe_results` - Results from ANAgentOpenPipeHandlerV2
- `sme_results` - Results from ANAgent Search SMEs
- `apm_results` - Results from ANAgentAPMNominationHandlerV2
- `content_results` - Results from ANAgentContentSearchHandlerV2

### **Join Key Mapping**
The service automatically joins data based on these field mappings:
- **Product**: `PRODUCT_L3__c`, `PRODUCT_L2__c`, `product`
- **Region**: `EMPLOYEE_LOCATION_REGION__c`, `region`, `OU__c`
- **AE Name**: `AE_NAME__c`, `AE_NAME`, `name`
- **Course Name**: `name`, `course_name`, `title`

## 📊 **Example Scenarios**

### **Scenario 1: Course Export**
```
User Request: "Export all courses related to data cloud"
Input Variables:
- userRequest: "Export all courses related to data cloud"
- actionResults: {"content_results": {"results": [{"name": "Data Cloud 101", "learnerCount": 1970, "completionRate": 57.06}]}}
- requestId: "COURSE-EXPORT-001"
- includeMetadata: true

Expected Output:
- success: true
- csvData: CSV with course data and metadata
- recordCount: 1
- columnCount: 3
- message: "CSV generated successfully with 1 records and 3 columns."
```

### **Scenario 2: Product + SME Export**
```
User Request: "Export top products in AMER with their SMEs"
Input Variables:
- userRequest: "Export top products in AMER with their SMEs"
- actionResults: {"openpipe_results": {...}, "sme_results": {...}}
- requestId: "PRODUCT-SME-EXPORT-001"
- includeMetadata: true

Expected Output:
- success: true
- csvData: CSV with joined product and SME data
- recordCount: 2
- columnCount: 10
- message: "CSV generated successfully with 2 records and 10 columns."
```

## 🛠️ **Error Handling**

### **Common Error Scenarios**

#### **Invalid JSON Format**
```
Error: Failed to parse agent action results
Resolution: Ensure agent actions return valid JSON data. Check that actions completed successfully.
```

#### **Missing Action Results**
```
Error: No valid action results found
Resolution: Verify that agent actions returned data in expected format.
```

#### **No Matching Data**
```
Error: No data found matching your request
Resolution: Check search criteria or try broader search terms.
```

### **Agent Error Response Strategy**
1. **Check success field** first
2. **If false**: Present the error message to user with resolution guidance
3. **If true**: Present the CSV data with record/column counts
4. **Always include**: Request ID for tracking

## 🔒 **Security Considerations**

### **Data Access**
- Service respects Salesforce sharing rules
- Only accessible fields are included in CSV
- Requires read access to referenced objects

### **Input Validation**
- Validates JSON format before processing
- Sanitizes user input to prevent injection
- Validates field accessibility

## 📈 **Performance Guidelines**

### **Best Practices**
- **Execute actions first**: Always run agent actions before calling CSV aggregator
- **Limit data size**: Large datasets may impact performance
- **Use specific requests**: More specific user requests lead to better results
- **Include metadata**: Helps with debugging and user understanding

### **Limitations**
- **JSON size**: Very large action results may cause timeout
- **Join complexity**: Complex multi-object joins may be slower
- **Memory usage**: Large datasets require adequate heap space

## 🧪 **Testing**

### **Test Cases**
1. **Single object export** with basic data
2. **Multi-object join** with matching keys
3. **Error handling** with invalid JSON
4. **Large dataset** performance testing
5. **Complex join** scenarios

### **Validation Checklist**
- [ ] CSV format is valid and importable
- [ ] All expected columns are present
- [ ] Data is properly joined (for multi-object requests)
- [ ] Metadata is included (when requested)
- [ ] Error messages are user-friendly
- [ ] Performance is acceptable for dataset size

## 🚀 **Integration with Other Actions**

### **Preceding Actions**
- `ANAgentOpenPipeHandlerV2` - For performance/territory data
- `ANAgent Search SMEs` - For expert information
- `ANAgentAPMNominationHandlerV2` - For APM data
- `ANAgentContentSearchHandlerV2` - For course/content data

### **Following Actions**
- `ANAgentEmailService` - Send CSV via email
- File storage actions - Save CSV to Salesforce Files
- Analytics actions - Process CSV data further

## 📞 **Support**

### **Troubleshooting Steps**
1. Verify agent actions executed successfully
2. Check JSON format of action results
3. Ensure user request is clear and specific
4. Review error messages for resolution guidance
5. Test with simpler requests first

### **Common Issues**
- **Empty CSV**: No data found matching criteria
- **Missing columns**: Agent actions didn't return expected fields
- **Join failures**: No common keys between datasets
- **Performance issues**: Dataset too large for processing

---

**Version**: 1.0  
**Last Updated**: January 2024  
**Compatible With**: ANAgentOpenPipeHandlerV2, ANAgent Search SMEs, ANAgentAPMNominationHandlerV2, ANAgentContentSearchHandlerV2 