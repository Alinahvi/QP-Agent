# QP Agent - Salesforce Objects & Fields Manifest

**Version**: 1.0  
**Last Updated**: January 2025  
**Maintainer**: Ali Nahvi (Alinahvi)

---

## 🏗️ **OBJECT ARCHITECTURE OVERVIEW**

The QP Agent system utilizes **9 primary Salesforce objects** with **200+ custom fields** to provide comprehensive data analysis and automation capabilities across multiple business domains.

---

## 📊 **PRIMARY DATA OBJECTS**

### **1. AGENT_OU_PIPELINE_V2__c**
**Purpose**: Central data warehouse for KPI analysis, territory management, and AE performance tracking.

**Object Type**: Custom Object  
**Primary Use**: KPI Analysis, Territory Analysis, Ramp Status Analysis  
**Record Count**: ~50,000+ records  
**Update Frequency**: Daily

#### **Core Identity Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001ABC` |
| `EMP_ID__c` | Employee ID | Text(18) | Unique employee identifier | `SF001234` |
| `FULL_NAME__c` | Full Name | Text(255) | Account Executive full name | `John Smith` |
| `EMP_EMAIL_ADDR__c` | Employee Email | Email | Primary email address | `john.smith@salesforce.com` |
| `LEARNER_PROFILE_ID__c` | Learner Profile ID | Text(18) | Learning management system ID | `LP001234` |

#### **Geographic & Organizational Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `WORK_LOCATION_COUNTRY__c` | Work Location Country | Text(100) | Country where AE is based | `United States` |
| `OU_NAME__c` | Operating Unit Name | Text(100) | Organizational unit assignment | `AMER ICE` |
| `EMP_MGR_NM__c` | Manager Name | Text(255) | Direct manager's name | `Sarah Johnson` |
| `PRIMARY_INDUSTRY__c` | Primary Industry | Text(100) | Industry focus area | `Financial Services` |

#### **Performance Metrics - Current Quarter (CQ)**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `CQ_ACV__c` | Current Quarter ACV | Currency(18,2) | Annual Contract Value booked this quarter | `$1,250,000.00` |
| `CQ_PG__c` | Current Quarter Pipeline Generated | Currency(18,2) | Pipeline generated this quarter | `$2,500,000.00` |
| `CQ_CALL_CONNECT__c` | Current Quarter Call Connects | Number(18,0) | Number of successful call connects | `45` |
| `CQ_CUSTOMER_MEETING__c` | Current Quarter Customer Meetings | Number(18,0) | Number of customer meetings held | `23` |
| `CQ_CC_ACV__c` | Current Quarter Call Connect ACV | Currency(18,2) | ACV from call connect activities | `$750,000.00` |
| `CQ_DAYS_ACV__c` | Current Quarter Days to ACV | Number(18,0) | Average days to close ACV deals | `45` |
| `CQ_DAYS_ACV_PART__c` | Current Quarter Days to ACV (Partial) | Number(18,0) | Partial days calculation for ACV | `30` |
| `CQ_DAYS_PG__c` | Current Quarter Days to PG | Number(18,0) | Average days to generate pipeline | `15` |
| `CQ_DAYS_PG_PART__c` | Current Quarter Days to PG (Partial) | Number(18,0) | Partial days calculation for PG | `10` |

#### **Performance Metrics - Previous Quarter (PQ)**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `PQ_ACV__c` | Previous Quarter ACV | Currency(18,2) | ACV booked in previous quarter | `$980,000.00` |
| `PQ_PG__c` | Previous Quarter Pipeline Generated | Currency(18,2) | Pipeline generated in previous quarter | `$1,800,000.00` |
| `PQ_CALL_CONNECT__c` | Previous Quarter Call Connects | Number(18,0) | Call connects in previous quarter | `38` |
| `PQ_CUSTOMER_MEETING__c` | Previous Quarter Customer Meetings | Number(18,0) | Customer meetings in previous quarter | `19` |
| `PQ_CC_ACV__c` | Previous Quarter Call Connect ACV | Currency(18,2) | ACV from call connects in previous quarter | `$620,000.00` |
| `PQ_DAYS_ACV__c` | Previous Quarter Days to ACV | Number(18,0) | Average days to close ACV in previous quarter | `52` |
| `PQ_DAYS_ACV_PART__c` | Previous Quarter Days to ACV (Partial) | Number(18,0) | Partial days for ACV in previous quarter | `35` |
| `PQ_DAYS_PG__c` | Previous Quarter Days to PG | Number(18,0) | Average days to generate pipeline in previous quarter | `18` |
| `PQ_DAYS_PG_PART__c` | Previous Quarter Days to PG (Partial) | Number(18,0) | Partial days for PG in previous quarter | `12` |

#### **Ramp Status & Productivity Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `RAMP_STATUS__c` | Ramp Status | Picklist | AE ramp status classification | `Fast` |
| `TIME_SINCE_ONBOARDING__c` | Time Since Onboarding | Number(18,1) | Months since AE joined | `8.5` |
| `DAYS_TO_PRODUCTIVITY__c` | Days to Productivity | Number(18,0) | Days taken to reach productivity | `120` |
| `COVERAGE__c` | Coverage | Percent(5,2) | Territory coverage percentage | `85.50` |
| `CALL_AI_MENTION__c` | Call AI Mention | Number(18,0) | Number of calls mentioning AI | `12` |

#### **Quota & Performance Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `VAL_QUOTA__c` | Value Quota | Currency(18,2) | Annual quota target | `$5,000,000.00` |
| `FULLTOTALACVQUOTAUSD__c` | Full Total ACV Quota USD | Currency(18,2) | Total ACV quota in USD | `$5,000,000.00` |
| `ACV_THRESHOLD__c` | ACV Threshold | Currency(18,2) | Minimum ACV threshold for performance | `$100,000.00` |
| `AOV__c` | Average Order Value | Currency(18,2) | Average value per order | `$75,000.00` |

#### **Cross-Sell & Upsell Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `CS_ACCT_ID_1__c` | Cross-Sell Account ID 1 | Text(18) | First cross-sell account ID | `0015g00000ABC123` |
| `CS_ACCT_NM_1__c` | Cross-Sell Account Name 1 | Text(255) | First cross-sell account name | `Acme Corporation` |
| `CS_NEXT_BEST_PRODUCT_1__c` | Cross-Sell Next Best Product 1 | Text(255) | Recommended next product | `Data Cloud` |

#### **Open Pipeline Fields (1-5)**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `OPEN_PIPE_AE_SCORE_1__c` | Open Pipe AE Score 1 | Number(18,2) | AE performance score for opportunity 1 | `8.5` |
| `OPEN_PIPE_APM_L2_1__c` | Open Pipe APM L2 1 | Text(100) | APM Level 2 classification | `High Priority` |
| `OPEN_PIPE_OPP_MANAGER_NT_1__c` | Open Pipe Opportunity Manager Note 1 | Text(255) | Manager notes for opportunity 1 | `Strong pipeline potential` |
| `OPEN_PIPE_OPTY_DAYS_IN_STAGE_1__c` | Open Pipe Opportunity Days in Stage 1 | Number(18,0) | Days opportunity has been in current stage | `15` |

---

### **2. Agent_Open_Pipe__c**
**Purpose**: Detailed pipeline opportunity analysis and tracking.

**Object Type**: Custom Object  
**Primary Use**: Open Pipe Analysis, Pipeline Management  
**Record Count**: ~25,000+ records  
**Update Frequency**: Real-time

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001DEF` |
| `EMP_ID__c` | Employee ID | Text(18) | AE employee identifier | `SF001234` |
| `FULL_NAME__c` | Full Name | Text(255) | Account Executive name | `John Smith` |
| `EMP_EMAIL_ADDR__c` | Employee Email | Email | AE email address | `john.smith@salesforce.com` |
| `OU_NAME__c` | Operating Unit Name | Text(100) | Organizational unit | `AMER ICE` |
| `WORK_LOCATION_COUNTRY__c` | Work Location Country | Text(100) | Country location | `United States` |
| `PRIMARY_INDUSTRY__c` | Primary Industry | Text(100) | Industry focus | `Financial Services` |
| `MACROSGMENT__c` | Macro Segment | Text(100) | Business segment | `Enterprise` |

#### **Opportunity Details**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `OPEN_PIPE_OPTY_NM__c` | Open Pipe Opportunity Name | Text(255) | Opportunity name | `Acme Corp - Data Cloud Expansion` |
| `OPEN_PIPE_OPTY_STG_NM__c` | Open Pipe Opportunity Stage Name | Text(100) | Current opportunity stage | `03 - Validating Benefits & Value` |
| `OPEN_PIPE_PROD_NM__c` | Open Pipe Product Name | Text(255) | Product being sold | `Data Cloud` |
| `OPEN_PIPE_OPTY_DAYS_IN_STAGE__c` | Open Pipe Opportunity Days in Stage | Number(18,0) | Days in current stage | `25` |
| `OPEN_PIPE_AE_SCORE__c` | Open Pipe AE Score | Number(18,2) | AE performance score | `8.5` |
| `OPEN_PIPE_RN__c` | Open Pipe Rank | Number(18,0) | Opportunity ranking | `3` |
| `OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c` | Original Open Pipe Allocation Amount | Currency(18,2) | Original allocated amount | `$500,000.00` |
| `OPEN_PIPE_OPP_MANAGER_NT__c` | Open Pipe Opportunity Manager Note | Text(255) | Manager notes | `High priority opportunity` |
| `OPEN_PIPE_REVISED_SUB_SECTOR__c` | Open Pipe Revised Sub Sector | Text(100) | Revised sector classification | `Banking` |

---

### **3. Course__c**
**Purpose**: Learning content and course management.

**Object Type**: Custom Object  
**Primary Use**: Content Search, Learning Management  
**Record Count**: ~5,000+ records  
**Update Frequency**: Weekly

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001GHI` |
| `Name` | Course Name | Text(255) | Course title | `Data Cloud Fundamentals` |
| `Description__c` | Description | Long Text Area | Course description | `Comprehensive introduction to Data Cloud platform` |
| `Status__c` | Status | Picklist | Course status | `Active` |
| `CreatedDate` | Created Date | DateTime | Record creation date | `2024-01-15T10:30:00Z` |
| `LastModifiedDate` | Last Modified Date | DateTime | Last modification date | `2024-12-01T14:22:00Z` |

---

### **4. Asset__c**
**Purpose**: Learning assets and training materials.

**Object Type**: Custom Object  
**Primary Use**: Content Search, Asset Management  
**Record Count**: ~3,000+ records  
**Update Frequency**: Weekly

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001JKL` |
| `Name` | Asset Name | Text(255) | Asset title | `Tableau Best Practices Guide` |
| `Description__c` | Description | Long Text Area | Asset description | `Comprehensive guide for Tableau implementation` |
| `Status__c` | Status | Picklist | Asset status | `Published` |
| `CreatedDate` | Created Date | DateTime | Record creation date | `2024-02-20T09:15:00Z` |
| `LastModifiedDate` | Last Modified Date | DateTime | Last modification date | `2024-11-15T16:45:00Z` |

---

### **5. Curriculum__c**
**Purpose**: Learning curriculum and program management.

**Object Type**: Custom Object  
**Primary Use**: Content Search, Curriculum Management  
**Record Count**: ~1,500+ records  
**Update Frequency**: Monthly

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001MNO` |
| `Name` | Curriculum Name | Text(255) | Curriculum title | `Sales Cloud Certification Path` |
| `Description__c` | Description | Long Text Area | Curriculum description | `Complete certification path for Sales Cloud` |
| `Status__c` | Status | Picklist | Curriculum status | `Active` |
| `CreatedDate` | Created Date | DateTime | Record creation date | `2024-03-10T11:00:00Z` |
| `LastModifiedDate` | Last Modified Date | DateTime | Last modification date | `2024-10-30T13:20:00Z` |

---

### **6. Assigned_Course__c**
**Purpose**: Course assignments and completion tracking.

**Object Type**: Custom Object  
**Primary Use**: Learning Analytics, Completion Tracking  
**Record Count**: ~100,000+ records  
**Update Frequency**: Daily

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001PQR` |
| `Name` | Assignment Name | Text(255) | Assignment identifier | `SF001234-DataCloud-2024` |
| `Course__c` | Course | Lookup(Course__c) | Related course record | `a0X5g0000001GHI` |
| `Learner_Profile__c` | Learner Profile | Lookup(Learner_Profile__c) | Learner profile reference | `LP001234` |
| `Completed__c` | Completed | Checkbox | Completion status | `true` |
| `Inactive__c` | Inactive | Checkbox | Inactive status | `false` |

---

### **7. AGENT_SME_ACADEMIES__c**
**Purpose**: Subject Matter Expert identification and management.

**Object Type**: Custom Object  
**Primary Use**: SME Search, Expert Identification  
**Record Count**: ~2,000+ records  
**Update Frequency**: Monthly

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001STU` |
| `Name` | SME Name | Text(255) | Expert name | `Dr. Sarah Johnson` |
| `Expertise_Area__c` | Expertise Area | Text(255) | Area of expertise | `Data Cloud Architecture` |
| `Skills__c` | Skills | Long Text Area | Technical skills | `Data Cloud, MuleSoft, Integration` |
| `Availability__c` | Availability | Picklist | Availability status | `Available` |
| `Contact_Email__c` | Contact Email | Email | Contact email | `sarah.johnson@salesforce.com` |

---

### **8. apm_nomination_v2__c**
**Purpose**: APM nomination management and tracking.

**Object Type**: Custom Object  
**Primary Use**: APM Nominations, Course Submissions  
**Record Count**: ~500+ records  
**Update Frequency**: Weekly

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001VWX` |
| `Name` | Nomination Name | Text(255) | Nomination identifier | `DataCloud-Fundamentals-2024` |
| `Course_Name__c` | Course Name | Text(255) | Nominated course name | `Data Cloud Fundamentals` |
| `Start_Date__c` | Start Date | Date | Course start date | `2024-02-01` |
| `End_Date__c` | End Date | Date | Course end date | `2024-04-30` |
| `Status__c` | Status | Picklist | Nomination status | `Submitted` |
| `API_Response__c` | API Response | Long Text Area | External API response | `Success: Course nominated` |

---

### **9. apm_outcome_v2__c**
**Purpose**: APM efficacy data and performance outcomes.

**Object Type**: Custom Object  
**Primary Use**: Efficacy Analysis, Performance Metrics  
**Record Count**: ~1,000+ records  
**Update Frequency**: Monthly

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001YZA` |
| `OFFERING_LABEL__c` | Offering Label | Text(255) | Course/program name | `Data Cloud Fundamentals` |
| `PROGRAM_TYPE__c` | Program Type | Text(100) | Type of program | `Course` |
| `REGION__c` | Region | Text(100) | Geographic region | `AMER` |
| `MACRO_SEGMENT__c` | Macro Segment | Text(100) | Business segment | `Enterprise` |
| `FISCAL_QUARTER__c` | Fiscal Quarter | Text(10) | Quarter identifier | `Q4 2024` |
| `KPI_NM__c` | KPI Name | Text(255) | Performance metric name | `ACV Impact` |
| `PRODUCT__c` | Product | Text(255) | Related product | `Data Cloud` |
| `MEAN_EFFECTIVENESS__c` | Mean Effectiveness | Number(18,2) | Average effectiveness score | `8.5` |
| `MEAN_TREATMENT__c` | Mean Treatment | Number(18,2) | Treatment group average | `85.2` |
| `MEAN_CONTROL__c` | Mean Control | Number(18,2) | Control group average | `72.8` |
| `CALCULATED_LIFT__c` | Calculated Lift | Percent(5,2) | Performance lift percentage | `17.05` |
| `TOTAL_INFLUENCED_ACV__c` | Total Influenced ACV | Currency(18,2) | Total ACV influenced | `$2,500,000.00` |
| `DISTINCT_LEARNERS__c` | Distinct Learners | Number(18,0) | Number of unique learners | `150` |

---

## 🔗 **SALES OPPORTUNITY OBJECTS**

### **10. Agent_Upsell__c**
**Purpose**: Upsell opportunity analysis and tracking.

**Object Type**: Custom Object  
**Primary Use**: Upsell Analysis, Expansion Opportunities  
**Record Count**: ~10,000+ records  
**Update Frequency**: Weekly

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001BCD` |
| `EMP_ID__c` | Employee ID | Text(18) | AE employee identifier | `SF001234` |
| `FULL_NAME__c` | Full Name | Text(255) | Account Executive name | `John Smith` |
| `OU_NAME__c` | Operating Unit Name | Text(100) | Organizational unit | `AMER ICE` |
| `WORK_LOCATION_COUNTRY__c` | Work Location Country | Text(100) | Country location | `United States` |
| `PRIMARY_INDUSTRY__c` | Primary Industry | Text(100) | Industry focus | `Financial Services` |
| `UPSELL_SUB_CATEGORY__c` | Upsell Sub Category | Text(255) | Upsell product category | `Data Cloud Analytics` |
| `UPSELL_RN__c` | Upsell Rank | Number(18,0) | Upsell opportunity ranking | `2` |
| `UPSELL_OPPORTUNITY_AMOUNT__c` | Upsell Opportunity Amount | Currency(18,2) | Potential upsell value | `$750,000.00` |

### **11. Agent_Cross_Sell__c**
**Purpose**: Cross-sell opportunity analysis and tracking.

**Object Type**: Custom Object  
**Primary Use**: Cross-Sell Analysis, Next Best Product  
**Record Count**: ~8,000+ records  
**Update Frequency**: Weekly

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001EFG` |
| `EMP_ID__c` | Employee ID | Text(18) | AE employee identifier | `SF001234` |
| `FULL_NAME__c` | Full Name | Text(255) | Account Executive name | `John Smith` |
| `OU_NAME__c` | Operating Unit Name | Text(100) | Organizational unit | `AMER ICE` |
| `WORK_LOCATION_COUNTRY__c` | Work Location Country | Text(100) | Country location | `United States` |
| `PRIMARY_INDUSTRY__c` | Primary Industry | Text(100) | Industry focus | `Financial Services` |
| `CROSS_SELL_NEXT_BEST_PRODUCT__c` | Cross-Sell Next Best Product | Text(255) | Recommended next product | `MuleSoft` |
| `CROSS_SELL_RN__c` | Cross-Sell Rank | Number(18,0) | Cross-sell opportunity ranking | `1` |
| `CROSS_SELL_OPPORTUNITY_AMOUNT__c` | Cross-Sell Opportunity Amount | Currency(18,2) | Potential cross-sell value | `$500,000.00` |

### **12. Agent_Renewals__c**
**Purpose**: Renewal opportunity analysis and tracking.

**Object Type**: Custom Object  
**Primary Use**: Renewals Analysis, Contract Management  
**Record Count**: ~6,000+ records  
**Update Frequency**: Weekly

#### **Core Fields**
| **Field API Name** | **Field Label** | **Data Type** | **Description** | **Sample Data** |
|-------------------|-----------------|---------------|-----------------|-----------------|
| `Id` | Record ID | ID | Unique Salesforce record identifier | `a0X5g0000001HIJ` |
| `EMP_ID__c` | Employee ID | Text(18) | AE employee identifier | `SF001234` |
| `FULL_NAME__c` | Full Name | Text(255) | Account Executive name | `John Smith` |
| `OU_NAME__c` | Operating Unit Name | Text(100) | Organizational unit | `AMER ICE` |
| `WORK_LOCATION_COUNTRY__c` | Work Location Country | Text(100) | Country location | `United States` |
| `PRIMARY_INDUSTRY__c` | Primary Industry | Text(100) | Industry focus | `Financial Services` |
| `RENEWAL_PROD_NM__c` | Renewal Product Name | Text(255) | Product up for renewal | `Sales Cloud Enterprise` |
| `RENEWAL_RN__c` | Renewal Rank | Number(18,0) | Renewal opportunity ranking | `3` |
| `RENEWAL_OPTY_AMT__c` | Renewal Opportunity Amount | Currency(18,2) | Renewal contract value | `$1,200,000.00` |

---

## 📈 **DATA RELATIONSHIPS**

### **Primary Relationships**
```
AGENT_OU_PIPELINE_V2__c (Master)
├── Assigned_Course__c (Learner_Profile__c → LEARNER_PROFILE_ID__c)
├── apm_nomination_v2__c (Course references)
└── apm_outcome_v2__c (Performance outcomes)

Course__c (Master)
├── Assigned_Course__c (Course__c)
├── apm_nomination_v2__c (Course references)
└── apm_outcome_v2__c (OFFERING_LABEL__c)

Agent_Open_Pipe__c (Independent)
├── AGENT_OU_PIPELINE_V2__c (EMP_ID__c relationship)
└── Sales opportunity tracking

Sales Opportunity Objects (Independent)
├── Agent_Upsell__c
├── Agent_Cross_Sell__c
└── Agent_Renewals__c
```

---

## 🔧 **FIELD USAGE PATTERNS**

### **KPI Analysis Fields**
- **Primary**: `CQ_ACV__c`, `CQ_PG__c`, `CQ_CALL_CONNECT__c`, `CQ_CUSTOMER_MEETING__c`
- **Comparison**: `PQ_ACV__c`, `PQ_PG__c`, `PQ_CALL_CONNECT__c`, `PQ_CUSTOMER_MEETING__c`
- **Grouping**: `WORK_LOCATION_COUNTRY__c`, `OU_NAME__c`, `PRIMARY_INDUSTRY__c`, `FULL_NAME__c`
- **Filtering**: `RAMP_STATUS__c`, `TIME_SINCE_ONBOARDING__c`, `EMP_MGR_NM__c`

### **Content Search Fields**
- **Search**: `Name`, `Description__c` (across Course__c, Asset__c, Curriculum__c)
- **Filtering**: `Status__c`, `CreatedDate`, `LastModifiedDate`
- **Analytics**: `Assigned_Course__c.Completed__c`, `Assigned_Course__c.Inactive__c`

### **Pipeline Analysis Fields**
- **Opportunity**: `OPEN_PIPE_OPTY_NM__c`, `OPEN_PIPE_OPTY_STG_NM__c`, `OPEN_PIPE_PROD_NM__c`
- **Performance**: `OPEN_PIPE_AE_SCORE__c`, `OPEN_PIPE_RN__c`, `OPEN_PIPE_OPTY_DAYS_IN_STAGE__c`
- **Grouping**: `OU_NAME__c`, `PRIMARY_INDUSTRY__c`, `MACROSGMENT__c`

---

## 📊 **SAMPLE DATA SCENARIOS**

### **Scenario 1: KPI Analysis Query**
```sql
SELECT EMP_ID__c, FULL_NAME__c, WORK_LOCATION_COUNTRY__c, OU_NAME__c,
       CQ_ACV__c, CQ_PG__c, CQ_CALL_CONNECT__c, RAMP_STATUS__c
FROM AGENT_OU_PIPELINE_V2__c
WHERE OU_NAME__c = 'AMER ICE' 
  AND RAMP_STATUS__c = 'Fast'
  AND CQ_ACV__c > 1000000
```

### **Scenario 2: Content Search Query**
```sql
SELECT Id, Name, Description__c, Status__c, CreatedDate
FROM Course__c
WHERE Name LIKE '%Data Cloud%'
  AND Status__c = 'Active'
ORDER BY CreatedDate DESC
```

### **Scenario 3: Pipeline Analysis Query**
```sql
SELECT EMP_ID__c, FULL_NAME__c, OPEN_PIPE_OPTY_NM__c, OPEN_PIPE_OPTY_STG_NM__c,
       OPEN_PIPE_PROD_NM__c, OPEN_PIPE_AE_SCORE__c, OPEN_PIPE_RN__c
FROM Agent_Open_Pipe__c
WHERE OU_NAME__c = 'AMER ICE'
  AND OPEN_PIPE_OPTY_STG_NM__c = '03 - Validating Benefits & Value'
ORDER BY OPEN_PIPE_AE_SCORE__c DESC
```

---

## 🚀 **PERFORMANCE CONSIDERATIONS**

### **Indexed Fields**
- `AGENT_OU_PIPELINE_V2__c.EMP_ID__c`
- `AGENT_OU_PIPELINE_V2__c.OU_NAME__c`
- `AGENT_OU_PIPELINE_V2__c.WORK_LOCATION_COUNTRY__c`
- `Course__c.Name`
- `Agent_Open_Pipe__c.OU_NAME__c`

### **Query Optimization**
- Use selective filters on indexed fields
- Limit result sets with appropriate WHERE clauses
- Use proper field selection to avoid unnecessary data transfer
- Consider governor limits for large datasets

---

**This object manifest provides comprehensive documentation of all Salesforce objects and fields used in the QP Agent system, enabling developers and analysts to understand the data structure and create effective queries and analyses.**
