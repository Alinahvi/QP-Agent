# 🚀 Unified TSV Service Integration Guide

## 🎯 **Overview**

The `ANAgentUnifiedTSVService` provides **standardized TSV export** for all four business scenarios:
- **Open Pipe Analysis** (`ANAGENT_Open_Pipe_Analysis_V3`)
- **Renewals Analysis** (`ABAGENT_Renewals_Analysis`)
- **Cross-Sell Analysis** (`ABAGENT_Cross_Sell_Analysis`)
- **Upsell Analysis** (`ABAGENT_Upsell_Analysis`)

## 📊 **Standardized TSV Output Format**

**All scenarios produce identical TSV structure:**

```
AE Email Address	AE Name	Product Name	Amount	Customer Name
john.doe@company.com	John Doe	Data Cloud	$2,500,000	Acme Corp
jane.smith@company.com	Jane Smith	Einstein Analytics	$1,800,000	Tech Solutions
```

**Key Features:**
- ✅ **AE Email Address always first** (as required)
- ✅ **Consistent field order** across all scenarios
- ✅ **Standardized field names** regardless of source data
- ✅ **Automatic field mapping** from various input formats

## 🔧 **Agent Action Configuration**

### **Action Name**
`Convert Business Data to Standardized TSV`

### **Class Name**
`ANAgentUnifiedTSVService`

### **Method Name**
`convertBusinessDataToTSV`

---

## 📋 **Required Input Variables**

| Variable | Type | Required | Description | Example |
|----------|------|----------|-------------|---------|
| `textData` | String | ✅ | Raw text data from agent actions | Output from OpenPipe/Renewals/etc. |
| `businessScenario` | String | ✅ | Business scenario identifier | "OpenPipe", "Renewals", "CrossSell", "Upsell" |
| `fileName` | String | ❌ | Custom filename (optional) | "OpenPipe_Analysis_2024.tsv" |
| `description` | String | ❌ | File description (optional) | "Top 50 Open Pipe opportunities in UKI" |
| `requestId` | String | ❌ | Tracking identifier (optional) | "REQ-2024-001" |
| `maxRecords` | Integer | ❌ | Record limit (optional) | 50 |

---

## 📤 **Output Variables**

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `success` | Boolean | Whether TSV creation succeeded | true |
| `fileId` | String | Salesforce File ID | "069D7000002io2rIAA" |
| `fileUrl` | String | Direct download URL | "/sfc/servlet.shepherd/document/download/..." |
| `fileName` | String | Created file name | "OpenPipe_Analysis_2024-01-15.tsv" |
| `recordCount` | Integer | Number of records in file | 50 |
| `message` | String | Success/error message | "TSV file created successfully with 50 records!" |

---

## 🔄 **Integration Workflows**

### **1. Open Pipe Analysis Workflow**
```
User: "Export top 50 Open Pipe opportunities in UKI"
Agent: 
1. Call ANAGENT_Open_Pipe_Analysis_V3
2. Collect results
3. Call Unified TSV Service with:
   - textData: OpenPipe results
   - businessScenario: "OpenPipe"
   - maxRecords: 50
4. Provide download URL for standardized TSV
```

### **2. Renewals Analysis Workflow**
```
User: "Export renewals data for AMER region"
Agent:
1. Call ABAGENT_Renewals_Analysis
2. Collect results
3. Call Unified TSV Service with:
   - textData: Renewals results
   - businessScenario: "Renewals"
4. Provide download URL for standardized TSV
```

### **3. Cross-Sell Analysis Workflow**
```
User: "Export cross-sell opportunities"
Agent:
1. Call ABAGENT_Cross_Sell_Analysis
2. Collect results
3. Call Unified TSV Service with:
   - textData: Cross-sell results
   - businessScenario: "CrossSell"
4. Provide download URL for standardized TSV
```

### **4. Upsell Analysis Workflow**
```
User: "Export upsell data for top products"
Agent:
1. Call ABAGENT_Upsell_Analysis
2. Collect results
3. Call Unified TSV Service with:
   - textData: Upsell results
   - businessScenario: "Upsell"
4. Provide download URL for standardized TSV
```

---

## 🎯 **Agent Instructions for Each Scenario**

### **Open Pipe Analysis**
```
When users request Open Pipe TSV exports:
1. Execute ANAGENT_Open_Pipe_Analysis_V3 with appropriate parameters
2. Collect the results text
3. Call Unified TSV Service with:
   - textData: OpenPipe results
   - businessScenario: "OpenPipe"
   - maxRecords: (if user specifies a limit)
4. Present download URL with record count
```

### **Renewals Analysis**
```
When users request Renewals TSV exports:
1. Execute ABAGENT_Renewals_Analysis with appropriate parameters
2. Collect the results text
3. Call Unified TSV Service with:
   - textData: Renewals results
   - businessScenario: "Renewals"
4. Present download URL with record count
```

### **Cross-Sell Analysis**
```
When users request Cross-Sell TSV exports:
1. Execute ABAGENT_Cross_Sell_Analysis with appropriate parameters
2. Collect the results text
3. Call Unified TSV Service with:
   - textData: Cross-sell results
   - businessScenario: "CrossSell"
4. Present download URL with record count
```

### **Upsell Analysis**
```
When users request Upsell TSV exports:
1. Execute ABAGENT_Upsell_Analysis with appropriate parameters
2. Collect the results text
3. Call Unified TSV Service with:
   - textData: Upsell results
   - businessScenario: "Upsell"
4. Present download URL with record count
```

---

## 🔍 **Field Mapping & Standardization**

### **Input Field Variations → Standardized Output**

| Input Field | Standardized Output | Examples |
|-------------|---------------------|----------|
| `AE Name`, `AE`, `Account Executive` | `AE Name` | "John Doe" |
| `Email`, `AE Email`, `Email Address` | `AE Email Address` | "john@company.com" |
| `Product`, `Product Name`, `Product__c` | `Product Name` | "Data Cloud" |
| `Amount`, `Value`, `ACV`, `Total_ACV__c` | `Amount` | "$2,500,000" |
| `Customer`, `Customer Name`, `Account` | `Customer Name` | "Acme Corp" |

### **Automatic Field Detection**
- ✅ **Smart field mapping** from various input formats
- ✅ **Handles missing fields** with empty values
- ✅ **Maintains consistent order** regardless of input
- ✅ **Filters out irrelevant fields** not in required set

---

## 🛠️ **Error Handling**

### **Common Error Scenarios**

| Error | Cause | Solution |
|-------|-------|----------|
| "Business scenario is required" | Missing businessScenario parameter | Always specify: "OpenPipe", "Renewals", "CrossSell", or "Upsell" |
| "Could not parse data" | Unrecognized data format | Ensure agent action returned data in expected format |
| "Permission to create files" | File creation access issue | Check user permissions for file creation |

### **Error Response Strategy**
1. **Check success field** first
2. **If false**: Present error message with resolution guidance
3. **If true**: Present download URL with record count
4. **Always include**: Request ID for tracking

---

## 🔒 **Security & Permissions**

### **Required Permissions**
- ✅ `ANAgentUnifiedTSVService` - Full access
- ✅ File creation permissions
- ✅ ContentVersion and ContentDocumentLink access

### **Data Security**
- ✅ Only processes data from existing agent actions
- ✅ No direct database access
- ✅ File access controlled by Salesforce permissions
- ✅ Standardized output format prevents data leakage

---

## 🚀 **Performance Considerations**

### **Optimization Tips**
- ✅ **Use maxRecords** for large datasets (prevents memory issues)
- ✅ **Standardized format** reduces processing overhead
- ✅ **Field mapping** happens once per record
- ✅ **Early termination** when record limits reached

### **Limits**
- ✅ Maximum file size: 2GB
- ✅ Maximum records: Based on maxRecords parameter
- ✅ CPU time: Within Salesforce limits

---

## 🧪 **Testing & Validation**

### **Test Scenarios**
1. **Open Pipe Analysis**: Export top 50 opportunities
2. **Renewals Analysis**: Export all renewals data
3. **Cross-Sell Analysis**: Export cross-sell opportunities
4. **Upsell Analysis**: Export upsell data
5. **Record Limiting**: Test "only first 25" requests
6. **Field Mapping**: Verify all required fields present

### **Success Indicators**
- ✅ `success = true`
- ✅ Valid `fileUrl` returned
- ✅ `recordCount` matches expected count
- ✅ TSV file opens correctly in spreadsheet applications
- ✅ All required fields present in correct order

---

## 🔄 **Migration from Old Service**

### **Replace This:**
```json
{
  "actionName": "Convert Text to TSV File",
  "className": "ANAgentSimpleTSVService",
  "methodName": "convertTextToTSV"
}
```

### **With This:**
```json
{
  "actionName": "Convert Business Data to Standardized TSV",
  "className": "ANAgentUnifiedTSVService",
  "methodName": "convertBusinessDataToTSV"
}
```

---

## 📋 **Implementation Checklist**

- [ ] Deploy `ANAgentUnifiedTSVService.cls`
- [ ] Update agent actions to use new service
- [ ] Test all four business scenarios
- [ ] Verify standardized output format
- [ ] Test record limiting functionality
- [ ] Update user documentation
- [ ] Train agents on new workflow

---

## 🎉 **Expected Results**

**Users get consistent, professional TSV exports across all business scenarios:**
- ✅ **Standardized format** regardless of source
- ✅ **Required fields always present** in correct order
- ✅ **Professional file naming** with timestamps
- ✅ **Record counts** for user verification
- ✅ **Direct download URLs** for immediate access

---

**🚀 Result: Unified, professional TSV export experience across all business scenarios!**
