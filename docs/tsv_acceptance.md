# TSV Export Acceptance Criteria

## Overview

This document defines the acceptance criteria for the TSV export functionality, including test scenarios, expected outcomes, and validation steps.

## ✅ Acceptance Criteria

### 1. Core Functionality

#### 1.1 Export Any Analysis as TSV
- **Given**: User has run any analysis (renewals, open pipe, KPI, SME, content, future pipeline)
- **When**: User requests "export to TSV" or "download as TSV"
- **Then**: System generates a properly formatted TSV file with actual analysis data

#### 1.2 Analysis Type Detection
- **Given**: Analysis data is stored in memory context
- **When**: TSV export is requested
- **Then**: System correctly detects analysis type and applies appropriate schema

#### 1.3 Data Extraction
- **Given**: Analysis data contains structured arrays of records
- **When**: TSV export processes the data
- **Then**: System extracts records and maps them to TSV columns correctly

### 2. TSV Format Standards

#### 2.1 File Format
- **Headers**: Fixed, consistent column headers per analysis type
- **Separator**: Tab character (`\t`) between columns
- **Encoding**: UTF-8
- **Line Endings**: LF (`\n`)
- **Quoting**: RFC-4180 compliant (quotes around fields containing tabs/quotes/newlines)

#### 2.2 Data Formatting
- **Numbers**: Plain numeric format (no currency symbols, no commas)
- **Dates**: YYYY-MM-DD format
- **Strings**: Properly escaped for TSV
- **Null Values**: Empty strings

### 3. Analysis Type Schemas

#### 3.1 RENEWALS Schema
```
Product | Total_Value | Opportunity_Count | Avg_Deal_Size
Data Cloud | 2500000.50 | 15 | 166666.70
Einstein Analytics | 1800000.00 | 12 | 150000.00
```

#### 3.2 OPEN_PIPE Schema
```
AE_Email | Learner_Profile_Id | Product | Opportunity_Name | Stage | Stagnation_Days | Amount | Opportunity_URL
john.doe@company.com | LP001 | Data Cloud | Acme Corp Implementation | 03 - Validating | 45 | 500000.00 | https://...
```

#### 3.3 KPIS Schema
```
AE_Email | Learner_Profile_Id | OU | AE_Score | Coverage | Timeframe
john.doe@company.com | LP001 | AMER-ACC | 4.2 | 85.5 | Current Quarter
```

#### 3.4 SME Schema
```
SME_Name | SME_Email | SME_OU | Product_L2 | Excellence_Academy | Total_ACV
Dr. Sarah Johnson | sarah.johnson@company.com | AMER-ACC | Data Cloud | Data Cloud Expert | 5000000.00
```

#### 3.5 CONTENT_ACT Schema
```
Title | URL | ProductTag | EnrollmentCount | CompletionRate | PublishedDate
Data Cloud Fundamentals | https://trailhead... | Data Cloud | 1250 | 78.5 | 2024-01-01
```

#### 3.6 CONTENT_CONSENSUS Schema
```
Title | URL | ProductTag | EngagementScore | PublishedDate
Advanced Data Cloud | https://trailhead... | Data Cloud | 92.3 | 2024-01-10
```

#### 3.7 FUTURE_PIPE Schema
```
AE_Email | Learner_Profile_Id | Product | Opp_Amount | PipeGen_Type
john.doe@company.com | LP001 | Data Cloud | 750000.00 | Upsell
```

### 4. Error Handling

#### 4.1 No Analysis Data
- **Given**: No analysis data in memory
- **When**: TSV export is requested
- **Then**: Returns error: "No analysis data found in memory. Please run an analysis first."

#### 4.2 Analysis Type Mismatch
- **Given**: Analysis data exists but wrong type
- **When**: TSV export is requested with type filter
- **Then**: Returns error: "No [TYPE] analysis data found. Most recent analysis is: [ACTUAL_TYPE]"

#### 4.3 Unrecognized Data Structure
- **Given**: Analysis data has unrecognized structure
- **When**: TSV export processes the data
- **Then**: Falls back to generic key-value format

### 5. MCP Integration

#### 5.1 MCP Tool Support
- **Given**: MCP server is configured
- **When**: Agent receives "export to TSV" request
- **Then**: MCP routes to TSV export tool

#### 5.2 MCP Response Format
- **Given**: TSV export completes successfully
- **When**: MCP returns response
- **Then**: Response includes download URL, file name, record count

### 6. Performance Requirements

#### 6.1 Response Time
- **Given**: Analysis data with 1000 records
- **When**: TSV export is requested
- **Then**: Export completes within 30 seconds

#### 6.2 Memory Usage
- **Given**: Large analysis dataset
- **When**: TSV export processes data
- **Then**: Stays within Salesforce governor limits

### 7. File Management

#### 7.1 File Creation
- **Given**: TSV export succeeds
- **When**: File is created
- **Then**: ContentVersion record is created with proper metadata

#### 7.2 Download Links
- **Given**: TSV file is created
- **When**: Download link is generated
- **Then**: Link is valid and accessible

#### 7.3 File Naming
- **Given**: Custom file name is provided
- **When**: TSV file is created
- **Then**: File uses custom name with .tsv extension

## 🧪 Test Scenarios

### Scenario 1: Renewals Export
1. Run renewals analysis: "show me top 5 renewal products in AMER ACC"
2. Request export: "export the list to TSV"
3. Verify: TSV contains 5 rows with Product, Total_Value, Opportunity_Count, Avg_Deal_Size columns
4. Verify: Values are numeric (no $ symbols)
5. Verify: Download link works

### Scenario 2: Open Pipe Export
1. Run open pipe analysis: "show stagnating opportunities in AMER-ACC"
2. Request export: "download as TSV"
3. Verify: TSV contains opportunity records with AE_Email, Product, Stage, Stagnation_Days columns
4. Verify: URLs are properly formatted
5. Verify: Numbers are plain format

### Scenario 3: KPI Export
1. Run KPI analysis: "show AE performance in AMER-ACC"
2. Request export: "export to TSV"
3. Verify: TSV contains AE records with scores and coverage
4. Verify: Decimal values are properly formatted
5. Verify: File name includes analysis type

### Scenario 4: Error Handling
1. Request export without running analysis
2. Verify: Error message indicates no data found
3. Run wrong analysis type, request different type export
4. Verify: Error message indicates type mismatch

### Scenario 5: MCP Integration
1. Send message: "export the last analysis to TSV"
2. Verify: MCP routes to TSV export tool
3. Verify: Response includes download URL
4. Verify: File contains correct data

## 📊 Validation Checklist

### Data Validation
- [ ] All required columns present
- [ ] Column order matches schema
- [ ] Data types correct (numbers, dates, strings)
- [ ] No currency symbols in numeric fields
- [ ] Proper TSV escaping for special characters
- [ ] No null values (empty strings instead)

### File Validation
- [ ] File created successfully
- [ ] Download link generated
- [ ] File name includes analysis type
- [ ] File size reasonable
- [ ] TSV opens correctly in Excel/Google Sheets

### Error Validation
- [ ] No data error handled
- [ ] Type mismatch error handled
- [ ] Invalid data structure handled
- [ ] Error messages helpful and actionable

### Performance Validation
- [ ] Export completes within time limits
- [ ] Memory usage within governor limits
- [ ] Large datasets handled properly
- [ ] No timeout errors

## 🎯 Success Metrics

### Functional Metrics
- **Export Success Rate**: >95% for valid analysis data
- **Data Accuracy**: 100% match between analysis and TSV content
- **Schema Compliance**: 100% adherence to defined schemas

### Performance Metrics
- **Response Time**: <30 seconds for 1000 records
- **Memory Usage**: <50MB heap usage
- **File Size**: <10MB for typical exports

### User Experience Metrics
- **Error Clarity**: Clear, actionable error messages
- **Download Success**: 100% working download links
- **File Usability**: TSV opens correctly in standard applications

## 🔧 Troubleshooting

### Common Issues
1. **Empty TSV file**: Check analysis data structure
2. **Wrong columns**: Verify analysis type detection
3. **Formatting issues**: Check TSV escaping logic
4. **Download fails**: Verify ContentVersion creation
5. **MCP not working**: Check named credential configuration

### Debug Steps
1. Check debug logs for analysis type detection
2. Verify data extraction in extractDataRows method
3. Test TSV generation with sample data
4. Validate file creation and download link generation
5. Check MCP server connectivity and tool registration

