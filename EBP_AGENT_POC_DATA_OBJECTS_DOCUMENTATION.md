# EBP Agent POC - Comprehensive Data Objects Documentation

## Overview

This document provides a comprehensive analysis of the data objects used in the EBP Agent POC system. The analysis is based on examination of Apex code, field mappings, and business logic to understand the data structure, relationships, and variations.

## Data Objects Summary

| Object Name | Purpose | Record Count | Primary Use Case |
|-------------|---------|--------------|------------------|
| `Agent_Open_Pipe__c` | Open Pipeline Analysis | ~58,000 | Current pipeline opportunities analysis |
| `AGENT_OU_PIPELINE_V3__c` | KPI Analysis | Unknown | AE performance metrics and KPIs |
| `Agent_Cross_Sell__c` | Future Pipeline - Cross-sell | Unknown | Cross-sell opportunity identification |
| `Agent_Renewals__c` | Future Pipeline - Renewals | Unknown | Renewal opportunity tracking |
| `Agent_Upsell__c` | Future Pipeline - Upsell | Unknown | Upsell opportunity identification |
| `Agent_Consensu__c` | Content Search | Unknown | Learning content and enablement materials |
| `Course__c` | ACT Learning | Unknown | Course definitions and metadata |
| `Curriculum__c` | ACT Learning | Unknown | Curriculum definitions and structure |

---

## 1. Agent_Open_Pipe__c (Open Pipeline Analysis)

### Purpose
Primary object for analyzing current open pipeline opportunities across Account Executives (AEs). Contains detailed opportunity data including stages, products, amounts, and AE performance metrics.

### Key Fields and Data Structure

#### Core Identification Fields
- **`emp_id__c`** (Text, 18 chars)
  - **Purpose**: Employee identifier for the AE
  - **Unique Values**: Employee IDs (e.g., "0010M00001Qlf7n", "0013000000M1a2r")
  - **Variations**: `emp_id`, `employee_id`, `emp`, `ae_id`

- **`full_name__c`** (Text, 255 chars)
  - **Purpose**: AE full name
  - **Unique Values**: Full names (e.g., "John Smith", "Sarah Johnson")
  - **Variations**: `name`, `ae_name`, `sales_rep_name`

- **`emp_email_addr__c`** (Email, 255 chars)
  - **Purpose**: AE email address
  - **Unique Values**: Email addresses (e.g., "john.smith@salesforce.com")
  - **Variations**: `email`, `email_addr`, `ae_email`

#### Organizational Fields
- **`ou_name__c`** (Text, 255 chars)
  - **Purpose**: Organizational Unit (core partition filter)
  - **Unique Values**: 
    - `AMER ACC` (Americas Account)
    - `AMER REG` (Americas Regional)
    - `AMER ICE` (Americas ICE)
    - `SMB - AMER SMB` (Small Medium Business - Americas)
    - `SMB - EMEA SMB` (Small Medium Business - EMEA)
    - `PubSec+.Org` (Public Sector Plus)
    - `South Asia - India`
    - `South Asia - ASEAN`
    - `NextGen Platform`
    - `UKI` (UK & Ireland)
    - `LATAM` (Latin America)
    - `ANZ` (Australia New Zealand)
    - `EMEA Central`
    - `EMEA South`
    - `EMEA North`
    - `North Asia`
    - `France`
    - `Unmapped`
  - **Variations**: `ou`, `operating_unit`, `org_unit`
  - **Aliases**: 
    - AMER SMB = AMER_SMB = AMERSMB = SMB AMER = SMB_AMER = SMBAMER
    - EME SMB = EME_SMB = EMESMB = SMB EME = SMB_EME = SMBEME
    - Pubsec = PUBSEC = PubSec = pubsec = PUB_SEC = PUB_SEC_PLUS
    - South Asia = SOUTH ASIA = south_asia = SouthAsia = SOUTHASIA
    - ASEAN = asean = SOUTH_ASIA_ASEAN
    - Next Gen = NextGen = NEXTGEN = next_gen = NEXT_GEN = NEXT_GEN_PLATFORM

- **`work_location_country__c`** (Text, 255 chars)
  - **Purpose**: Work location country of the AE
  - **Unique Values**: Country codes and names
  - **Variations**: `work_location`, `country`, `location`, `work_country`
  - **Aliases**: 
    - USA = U.S. = United States = US
    - Brasil = Brazil
    - UK = U.K. = UKI

- **`emp_mgr_nm__c`** (Text, 255 chars)
  - **Purpose**: Manager name of the AE
  - **Unique Values**: Manager names
  - **Variations**: `manager`, `manager_name`, `mgr`, `mgr_name`, `sales_manager`

#### Industry and Segment Fields
- **`primary_industry__c`** (Text, 255 chars)
  - **Purpose**: Primary industry classification
  - **Unique Values**: Industry classifications
  - **Variations**: `industry`, `sector`

- **`macrosgment__c`** (Text, 255 chars)
  - **Purpose**: Macro segment classification
  - **Unique Values**: 
    - `CMRCL` (Commercial)
    - `ESMB` (Enterprise Small Medium Business)
    - `ENTR` (Enterprise)
    - `SMB` (Small Medium Business)
  - **Variations**: `macro_segment`, `segment`, `macro`, `business_segment`

#### Opportunity Fields
- **`open_pipe_prod_nm__c`** (Text, 255 chars)
  - **Purpose**: Product name tied to the open opportunity
  - **Unique Values**: Product names
  - **Variations**: `product`, `product_name`, `prod`

- **`open_pipe_opty_nm__c`** (Text, 255 chars)
  - **Purpose**: Opportunity name
  - **Unique Values**: Opportunity names
  - **Variations**: `opportunity_name`, `oppty_name`, `opp_name`, `opty_nm`, `oppty_nm`

- **`open_pipe_opty_stg_nm__c`** (Text, 255 chars)
  - **Purpose**: Opportunity stage name
  - **Unique Values**: Sales stage names
  - **Variations**: `stage`, `opportunity_stage`, `oppty_stage`, `opp_stage`, `stage_name`

- **`open_pipe_opty_days_in_stage__c`** (Number, 18,0)
  - **Purpose**: Days the opportunity has been in current stage
  - **Unique Values**: Integer values (0-200+ days)
  - **Variations**: `open_pipe_oppty_days_in_stage`, `open_pipe_opty_days_in_stg`, `open_pipe_oppty_days_in_stg`

- **`open_pipe_ae_score__c`** (Number, 18,2)
  - **Purpose**: AE score (0-5 scale)
  - **Unique Values**: Decimal values 0.0-5.0
  - **Variations**: `ae_score`, `score`

- **`open_pipe_apm_l2__c`** (Text, 255 chars)
  - **Purpose**: APM L2 classification/category
  - **Unique Values**: Product family categories
  - **Variations**: `apm_l2`, `product_family`

- **`open_pipe_revised_sub_sector__c`** (Text, 255 chars)
  - **Purpose**: Refined industry sub-sector
  - **Unique Values**: Industry sub-sectors
  - **Variations**: `sub_sector`, `industry_sub_sector`

- **`open_pipe_opp_manager_nt__c`** (Text, 255 chars)
  - **Purpose**: Manager/representative notes on the opportunity
  - **Unique Values**: Free text notes
  - **Variations**: `manager_notes`, `opp_manager_notes`, `oppty_manager_notes`

- **`open_pipe_original_openpipe_alloc_amt__c`** (Currency, 18,2)
  - **Purpose**: Original allocation amount
  - **Unique Values**: Currency values
  - **Variations**: `amount`, `alloc_amt`, `allocation_amount`, `open_pipe_amount`

- **`open_pipe_rn__c`** (Number, 18,0)
  - **Purpose**: Row number/rank for opportunity ordering
  - **Unique Values**: Integer values
  - **Variations**: `row_number`, `rn`

#### Learning and Enablement Fields
- **`learner_profile_id__c`** (Text, 18 chars)
  - **Purpose**: Linked learner profile ID for enablement
  - **Unique Values**: Learner profile IDs
  - **Variations**: `learner_id`, `profile_id`, `learner_profile`

- **`time_since_onboarding__c`** (Number, 18,2)
  - **Purpose**: Time since onboarding in months
  - **Unique Values**: Decimal values
  - **Variations**: `onboarding_time`, `tenure`, `months_onboarded`

- **`ramp_status__c`** (Text, 255 chars)
  - **Purpose**: AE ramp status
  - **Unique Values**: 
    - `Fast Ramper`
    - `Standard Ramper`
    - `Slow Ramper`
    - `Ramped`
  - **Variations**: `ramp`, `onboarding_status`, `ramp_up`, `ramp_state`, `ramp_phase`, `ramp_level`

### Relationships
- **Learner Profile**: `learner_profile_id__c` → `Learner_Profile__c.Id`
- **Employee**: `emp_id__c` → Employee records
- **Account**: Opportunity accounts (via opportunity data)

### Business Context
This object is the core of the open pipeline analysis system, providing comprehensive data for:
- Pipeline health analysis
- AE performance tracking
- Opportunity stage analysis
- Product performance metrics
- Territory and industry analysis

---

## 2. AGENT_OU_PIPELINE_V3__c (KPI Analysis)

### Purpose
Comprehensive KPI analysis object containing aggregated performance metrics for AEs across different dimensions including meetings, calls, ACV, and pipeline generation.

### Key Fields and Data Structure

#### Core Identification Fields
- **`emp_id__c`** (Text, 18 chars)
  - **Purpose**: Employee identifier for the AE
  - **Variations**: `emp_id`, `employee_id`, `emp`

- **`full_name__c`** (Text, 255 chars)
  - **Purpose**: AE full name
  - **Variations**: `name`, `ae_name`, `sales_rep_name`

- **`emp_email_addr__c`** (Email, 255 chars)
  - **Purpose**: AE email address
  - **Variations**: `email`, `email_addr`, `ae_email`

#### Organizational Fields
- **`ou_name__c`** (Text, 255 chars)
  - **Purpose**: Organizational Unit
  - **Unique Values**: Same as Agent_Open_Pipe__c
  - **Variations**: `ou`, `operating_unit`, `org_unit`

- **`work_location_country__c`** (Text, 255 chars)
  - **Purpose**: Work location country
  - **Variations**: `work_location`, `country`, `location`

- **`emp_mgr_nm__c`** (Text, 255 chars)
  - **Purpose**: Manager name
  - **Variations**: `manager`, `manager_name`

#### Performance Metrics Fields
- **`cq_meetings__c`** (Number, 18,2)
  - **Purpose**: Current quarter number of meetings
  - **Unique Values**: Decimal values (e.g., 10.0, 6.0, 8.0)
  - **Variations**: `meetings`, `customer_meetings`

- **`cq_calls__c`** (Number, 18,2)
  - **Purpose**: Current quarter number of calls
  - **Unique Values**: Decimal values
  - **Variations**: `calls`, `call_count`

- **`cq_acv__c`** (Currency, 18,2)
  - **Purpose**: Current Quarter Annual Contract Value
  - **Unique Values**: Currency values
  - **Variations**: `acv`, `annual_contract_value`

- **`cq_pg__c`** (Currency, 18,2)
  - **Purpose**: Current Quarter Pipeline Generation
  - **Unique Values**: Currency values
  - **Variations**: `pg`, `pipeline_generation`

- **`cq_cc_acv__c`** (Currency, 18,2)
  - **Purpose**: Current quarter Create and Close ACV
  - **Unique Values**: Currency values (e.g., 1861.32, 0.0, 148.18)
  - **Variations**: `cc_acv`, `create_close_acv`

- **`val_quota__c`** (Currency, 18,2)
  - **Purpose**: Validation quota amount
  - **Unique Values**: Currency values
  - **Variations**: `quota`, `validation_quota`

- **`coverage__c`** (Number, 18,2)
  - **Purpose**: Pipeline coverage ratio (pipeline value to quota)
  - **Unique Values**: Decimal values
  - **Variations**: `coverage_ratio`, `pipeline_coverage`

#### Industry and Segment Fields
- **`primary_industry__c`** (Text, 255 chars)
  - **Purpose**: Primary industry classification
  - **Variations**: `industry`, `sector`

- **`macrosgment__c`** (Text, 255 chars)
  - **Purpose**: Macro segment classification
  - **Unique Values**: Same as Agent_Open_Pipe__c
  - **Variations**: `macro_segment`, `segment`

#### Learning Fields
- **`learner_profile_id__c`** (Text, 18 chars)
  - **Purpose**: Linked learner profile ID
  - **Variations**: `learner_id`, `profile_id`

### Relationships
- **Learner Profile**: `learner_profile_id__c` → `Learner_Profile__c.Id`
- **Employee**: `emp_id__c` → Employee records

### Business Context
This object provides comprehensive KPI analysis including:
- Meeting and call activity tracking
- ACV and pipeline generation metrics
- Quota and coverage analysis
- Performance benchmarking

---

## 3. Agent_Cross_Sell__c (Future Pipeline - Cross-sell)

### Purpose
Identifies cross-sell opportunities for existing customers, recommending next best products to expand their Salesforce footprint.

### Key Fields and Data Structure

#### Core Identification Fields
- **`emp_id__c`** (Text, 18 chars)
  - **Purpose**: Employee identifier for the AE
  - **Variations**: `emp_id`, `employee_id`, `emp`, `ae_id`

- **`full_name__c`** (Text, 255 chars)
  - **Purpose**: AE full name
  - **Variations**: `name`, `ae_name`, `sales_rep`

- **`emp_email_addr__c`** (Email, 255 chars)
  - **Purpose**: AE email address
  - **Variations**: `emp_email`, `email`, `ae_email`

#### Organizational Fields
- **`ou_name__c`** (Text, 255 chars)
  - **Purpose**: Organizational Unit
  - **Variations**: `ou`, `operating_unit`, `org_unit`

- **`work_location_country__c`** (Text, 255 chars)
  - **Purpose**: Work location country
  - **Variations**: `work_location`, `country`, `location`

- **`emp_mgr_nm__c`** (Text, 255 chars)
  - **Purpose**: Manager name
  - **Variations**: `emp_mgr`, `manager`, `mgr`, `mgr_name`, `sales_manager`

#### Cross-sell Specific Fields
- **`cross_sell_next_best_product__c`** (Text, 255 chars)
  - **Purpose**: Product name for cross-sell recommendation
  - **Unique Values**: Product names
  - **Variations**: `product`, `product_name`, `cross_sell_product`, `next_best_product`

- **`cross_sell_acct_nm__c`** (Text, 255 chars)
  - **Purpose**: Account name associated with cross-sell
  - **Unique Values**: Account names
  - **Variations**: `account_name`, `account`, `customer`

- **`cross_sell_acct_id__c`** (Text, 18 chars)
  - **Purpose**: Account ID associated with cross-sell
  - **Unique Values**: Account IDs (e.g., "0010M00001Qlf7n", "0013000000M1a2r")
  - **Variations**: `account_id`, `customer_id`

- **`cross_sell_rn__c`** (Number, 18,0)
  - **Purpose**: Cross-sell round/rank/sequence number
  - **Unique Values**: Integer values
  - **Variations**: `cross_sell_round`, `cross_sell_rank`, `round`, `rank`

#### Industry and Segment Fields
- **`primary_industry__c`** (Text, 255 chars)
  - **Purpose**: Primary industry classification
  - **Variations**: `industry`, `sector`

- **`macrosgment__c`** (Text, 255 chars)
  - **Purpose**: Macro segment classification
  - **Variations**: `macro_segment`, `segment`

#### Learning Fields
- **`learner_profile_id__c`** (Text, 18 chars)
  - **Purpose**: Linked learner profile ID
  - **Variations**: `learner_id`, `profile_id`

- **`ramp_status__c`** (Text, 255 chars)
  - **Purpose**: AE ramp status
  - **Variations**: `ramp`, `onboarding_status`

- **`time_since_onboarding__c`** (Number, 18,2)
  - **Purpose**: Time since onboarding in months
  - **Variations**: `onboarding_time`, `months_onboarded`, `tenure`

### Relationships
- **Learner Profile**: `learner_profile_id__c` → `Learner_Profile__c.Id`
- **Account**: `cross_sell_acct_id__c` → Account records
- **Employee**: `emp_id__c` → Employee records

### Business Context
This object enables:
- Cross-sell opportunity identification
- Next best product recommendations
- Account expansion analysis
- AE cross-sell performance tracking

---

## 4. Agent_Renewals__c (Future Pipeline - Renewals)

### Purpose
Tracks renewal opportunities with monetary values, helping AEs identify and manage contract renewals.

### Key Fields and Data Structure

#### Core Identification Fields
- **`emp_id__c`** (Text, 18 chars)
  - **Purpose**: Employee identifier for the AE
  - **Variations**: `emp_id`, `employee_id`, `emp`

- **`full_name__c`** (Text, 255 chars)
  - **Purpose**: AE full name
  - **Variations**: `name`, `ae_name`

- **`emp_email_addr__c`** (Email, 255 chars)
  - **Purpose**: AE email address
  - **Variations**: `email`, `ae_email`

#### Organizational Fields
- **`ou_name__c`** (Text, 255 chars)
  - **Purpose**: Organizational Unit
  - **Variations**: `ou`, `operating_unit`, `org_unit`

- **`work_location_country__c`** (Text, 255 chars)
  - **Purpose**: Work location country
  - **Variations**: `work_location`, `country`, `location`

- **`emp_mgr_nm__c`** (Text, 255 chars)
  - **Purpose**: Manager name
  - **Variations**: `manager`, `mgr`

#### Renewal Specific Fields
- **`renewal_prod_nm__c`** (Text, 255 chars)
  - **Purpose**: Product name for renewal
  - **Unique Values**: Product names
  - **Variations**: `product`, `renewal_product`

- **`renewal_acct_nm__c`** (Text, 255 chars)
  - **Purpose**: Account name for renewal
  - **Unique Values**: Account names
  - **Variations**: `account`, `renewal_account`

- **`renewal_acct_id__c`** (Text, 18 chars)
  - **Purpose**: Account ID for renewal
  - **Unique Values**: Account IDs
  - **Variations**: `account_id`, `renewal_account_id`

- **`renewal_opty_amt__c`** (Currency, 18,2)
  - **Purpose**: Renewal opportunity amount
  - **Unique Values**: Currency values
  - **Variations**: `amount`, `renewal_amount`

- **`renewal_opty_nm__c`** (Text, 255 chars)
  - **Purpose**: Renewal opportunity name
  - **Unique Values**: Opportunity names
  - **Variations**: `opportunity_name`, `renewal_opportunity`

#### Industry and Segment Fields
- **`primary_industry__c`** (Text, 255 chars)
  - **Purpose**: Primary industry classification
  - **Variations**: `industry`, `sector`

- **`macrosgment__c`** (Text, 255 chars)
  - **Purpose**: Macro segment classification
  - **Variations**: `macro_segment`, `segment`

### Relationships
- **Account**: `renewal_acct_id__c` → Account records
- **Employee**: `emp_id__c` → Employee records

### Business Context
This object enables:
- Renewal opportunity tracking
- Revenue protection analysis
- Contract renewal management
- AE renewal performance metrics

---

## 5. Agent_Upsell__c (Future Pipeline - Upsell)

### Purpose
Identifies upsell opportunities for existing customers, recommending additional products or expanded usage.

### Key Fields and Data Structure

#### Core Identification Fields
- **`emp_id__c`** (Text, 18 chars)
  - **Purpose**: Employee identifier for the AE
  - **Variations**: `emp_id`, `employee_id`, `emp`

- **`full_name__c`** (Text, 255 chars)
  - **Purpose**: AE full name
  - **Variations**: `name`, `ae_name`

- **`emp_email_addr__c`** (Email, 255 chars)
  - **Purpose**: AE email address
  - **Variations**: `email`, `ae_email`

#### Organizational Fields
- **`ou_name__c`** (Text, 255 chars)
  - **Purpose**: Organizational Unit
  - **Variations**: `ou`, `operating_unit`, `org_unit`

- **`work_location_country__c`** (Text, 255 chars)
  - **Purpose**: Work location country
  - **Variations**: `work_location`, `country`, `location`

- **`emp_mgr_nm__c`** (Text, 255 chars)
  - **Purpose**: Manager name
  - **Variations**: `manager`, `mgr`

#### Upsell Specific Fields
- **`upsell_acct_nm__c`** (Text, 255 chars)
  - **Purpose**: Account name for upsell
  - **Unique Values**: Account names
  - **Variations**: `account`, `upsell_account`

- **`upsell_acct_id__c`** (Text, 18 chars)
  - **Purpose**: Account ID for upsell
  - **Unique Values**: Account IDs (e.g., "0013y00001focD2", "0010M00001QqTzb")
  - **Variations**: `account_id`, `upsell_account_id`

- **`upsell_sub_category__c`** (Text, 255 chars)
  - **Purpose**: Upsell sub-category classification
  - **Unique Values**: Sub-category classifications
  - **Variations**: `sub_category`, `upsell_category`

#### Industry and Segment Fields
- **`primary_industry__c`** (Text, 255 chars)
  - **Purpose**: Primary industry classification
  - **Variations**: `industry`, `sector`

- **`macrosgment__c`** (Text, 255 chars)
  - **Purpose**: Macro segment classification
  - **Variations**: `macro_segment`, `segment`

### Relationships
- **Account**: `upsell_acct_id__c` → Account records
- **Employee**: `emp_id__c` → Employee records

### Business Context
This object enables:
- Upsell opportunity identification
- Account expansion analysis
- Revenue growth tracking
- AE upsell performance metrics

---

## 6. Agent_Consensu__c (Content Search)

### Purpose
Stores learning content and enablement materials for intelligent search and discovery by AEs.

### Key Fields and Data Structure

#### Content Identification Fields
- **`title__c`** (Text, 255 chars)
  - **Purpose**: Public title of the content
  - **Unique Values**: Content titles
  - **Variations**: `title`, `content_title`

- **`internalTitle__c`** (Text, 255 chars)
  - **Purpose**: Internal title of the content
  - **Unique Values**: Internal content titles
  - **Variations**: `internal_title`, `internal_name`

- **`description__c`** (Text, 255 chars)
  - **Purpose**: Content description
  - **Unique Values**: Free text descriptions
  - **Variations**: `desc`, `content_description`

#### Content Status Fields
- **`isPublic__c`** (Checkbox)
  - **Purpose**: Whether content is public
  - **Unique Values**: True/False
  - **Variations**: `public`, `is_public`

- **`isPublished__c`** (Checkbox)
  - **Purpose**: Whether content is published
  - **Unique Values**: True/False
  - **Variations**: `published`, `is_published`

#### Content Metadata Fields
- **`createdAt__c`** (DateTime)
  - **Purpose**: Content creation date
  - **Unique Values**: DateTime values
  - **Variations**: `created_date`, `creation_date`

- **`previewLink__c`** (Text, 255 chars)
  - **Purpose**: Preview link for content
  - **Unique Values**: URLs
  - **Variations**: `preview_url`, `link`

- **`languageTitle__c`** (Text, 255 chars)
  - **Purpose**: Language of the content
  - **Unique Values**: Language names
  - **Variations**: `language`, `content_language`

- **`folderInfoName__c`** (Text, 255 chars)
  - **Purpose**: Folder information name
  - **Unique Values**: Folder names
  - **Variations**: `folder_name`, `folder`

#### Creator Fields
- **`creatorDatafirstName__c`** (Text, 255 chars)
  - **Purpose**: Creator first name
  - **Unique Values**: First names
  - **Variations**: `creator_first_name`, `author_first_name`

- **`creatorDatalastName__c`** (Text, 255 chars)
  - **Purpose**: Creator last name
  - **Unique Values**: Last names
  - **Variations**: `creator_last_name`, `author_last_name`

- **`creatorDataemail__c`** (Email, 255 chars)
  - **Purpose**: Creator email
  - **Unique Values**: Email addresses
  - **Variations**: `creator_email`, `author_email`

### Business Context
This object enables:
- Content search and discovery
- Learning material organization
- Content intelligence features
- Enablement content management

---

## 7. Course__c (ACT Learning)

### Purpose
Defines courses in the learning management system, providing metadata and structure for learning content.

### Key Fields and Data Structure

#### Core Identification Fields
- **`Name`** (Text, 255 chars)
  - **Purpose**: Course name
  - **Unique Values**: Course names
  - **Variations**: `course_name`, `title`

- **`Description__c`** (Text, 255 chars)
  - **Purpose**: Course description
  - **Unique Values**: Free text descriptions
  - **Variations**: `desc`, `course_description`

#### Course Status Fields
- **`Status__c`** (Text, 255 chars)
  - **Purpose**: Course status
  - **Unique Values**: Status values
  - **Variations**: `status`, `course_status`

- **`Primary_Category__c`** (Text, 255 chars)
  - **Purpose**: Primary category of the course
  - **Unique Values**: Category names
  - **Variations**: `category`, `primary_category`

- **`Share_Url__c`** (Text, 255 chars)
  - **Purpose**: Share URL for the course
  - **Unique Values**: URLs
  - **Variations**: `url`, `share_url`

### Relationships
- **Assigned Courses**: Course__c → Assigned_Course__c
- **Curriculum**: Course__c → Curriculum__c (many-to-many)

### Business Context
This object enables:
- Course management and organization
- Learning path creation
- Content categorization
- Course completion tracking

---

## 8. Curriculum__c (ACT Learning)

### Purpose
Defines curriculum structures and learning paths, organizing courses into coherent learning experiences.

### Key Fields and Data Structure

#### Core Identification Fields
- **`Name`** (Text, 255 chars)
  - **Purpose**: Curriculum name
  - **Unique Values**: Curriculum names
  - **Variations**: `curriculum_name`, `title`

- **`Description__c`** (Text, 255 chars)
  - **Purpose**: Curriculum description
  - **Unique Values**: Free text descriptions
  - **Variations**: `desc`, `curriculum_description`

#### Curriculum Status Fields
- **`Status__c`** (Text, 255 chars)
  - **Purpose**: Curriculum status
  - **Unique Values**: Status values
  - **Variations**: `status`, `curriculum_status`

### Relationships
- **Courses**: Curriculum__c → Course__c (many-to-many)
- **Assigned Curricula**: Curriculum__c → Assigned_Curriculum__c

### Business Context
This object enables:
- Learning path creation
- Curriculum management
- Course sequencing
- Learning experience design

---

## Data Relationships and Dependencies

### Primary Relationships
1. **Learner Profile Integration**: All agent objects link to `Learner_Profile__c` via `learner_profile_id__c`
2. **Employee Integration**: All objects reference employee data via `emp_id__c`
3. **Account Integration**: Future pipeline objects reference accounts via account ID fields
4. **Organizational Structure**: All objects use `ou_name__c` for organizational filtering

### Data Flow
1. **Open Pipeline**: `Agent_Open_Pipe__c` → Current opportunities analysis
2. **Future Pipeline**: `Agent_Cross_Sell__c`, `Agent_Renewals__c`, `Agent_Upsell__c` → Future opportunities
3. **KPI Analysis**: `AGENT_OU_PIPELINE_V3__c` → Performance metrics
4. **Content Search**: `Agent_Consensu__c` → Learning materials
5. **Learning Management**: `Course__c`, `Curriculum__c` → Learning paths

### Common Field Patterns
- **Employee Fields**: `emp_id__c`, `full_name__c`, `emp_email_addr__c`, `emp_mgr_nm__c`
- **Organizational Fields**: `ou_name__c`, `work_location_country__c`
- **Industry Fields**: `primary_industry__c`, `macrosgment__c`
- **Learning Fields**: `learner_profile_id__c`, `ramp_status__c`, `time_since_onboarding__c`

---

## Field Variation Patterns

### Common Variations by Field Type
1. **ID Fields**: `field_name` = `field` = `field_id` = `field_name_id`
2. **Name Fields**: `field_name` = `field` = `field_nm` = `field_name_nm`
3. **Email Fields**: `field_email` = `field_email_addr` = `field_email_address`
4. **Manager Fields**: `field_mgr` = `field_manager` = `field_mgr_nm` = `field_manager_name`
5. **Date Fields**: `field_date` = `field_created` = `field_created_date` = `field_creation_date`

### OU Name Variations
- **AMER SMB**: AMER_SMB, AMERSMB, SMB AMER, SMB_AMER, SMBAMER
- **EMEA SMB**: EME SMB, EME_SMB, EMESMB, SMB EME, SMB_EME, SMBEME
- **PubSec**: Pubsec, PUBSEC, PubSec, pubsec, PUB_SEC, PUB_SEC_PLUS
- **South Asia**: South Asia, SOUTH ASIA, south_asia, SouthAsia, SOUTHASIA
- **ASEAN**: ASEAN, asean, SOUTH_ASIA_ASEAN
- **NextGen**: Next Gen, NextGen, NEXTGEN, next_gen, NEXT_GEN, NEXT_GEN_PLATFORM

### Country Variations
- **USA**: USA, U.S., United States, US
- **Brazil**: Brasil, Brazil
- **UK**: UK, U.K., UKI

---

## Business Use Cases by Object

### Agent_Open_Pipe__c
- Pipeline health analysis
- AE performance tracking
- Opportunity stage analysis
- Product performance metrics
- Territory and industry analysis
- Stagnation analysis
- AE scoring and ranking

### AGENT_OU_PIPELINE_V3__c
- KPI analysis and benchmarking
- Meeting and call activity tracking
- ACV and pipeline generation metrics
- Quota and coverage analysis
- Performance outlier detection
- Manager reporting

### Agent_Cross_Sell__c
- Cross-sell opportunity identification
- Next best product recommendations
- Account expansion analysis
- AE cross-sell performance tracking
- Product adoption analysis

### Agent_Renewals__c
- Renewal opportunity tracking
- Revenue protection analysis
- Contract renewal management
- AE renewal performance metrics
- Churn risk analysis

### Agent_Upsell__c
- Upsell opportunity identification
- Account expansion analysis
- Revenue growth tracking
- AE upsell performance metrics
- Product expansion analysis

### Agent_Consensu__c
- Content search and discovery
- Learning material organization
- Content intelligence features
- Enablement content management
- Knowledge base search

### Course__c & Curriculum__c
- Learning path creation
- Course management and organization
- Content categorization
- Course completion tracking
- Learning experience design

---

## Technical Implementation Notes

### Field Mapping Strategy
The system uses comprehensive field mapping with aliases to handle:
- Common typos and variations
- Different naming conventions
- User-friendly field names
- Backward compatibility

### Data Quality Considerations
- **Outlier Handling**: Days in stage capped at 200 for stagnation analysis
- **Sample Size**: Minimum 2 opportunities per product for meaningful averages
- **Data Validation**: Governor-safe limits and validation
- **Memory Optimization**: Aggregate queries to prevent heap size issues

### Performance Optimizations
- **Aggregate Queries**: Used extensively to prevent heap size issues
- **Selective SOQL**: Only essential fields loaded
- **Governor Safety**: Built-in limits and validation
- **Caching**: Dimension registry for common lookups

---

## Conclusion

The EBP Agent POC system uses a comprehensive set of data objects to provide:
1. **Current Pipeline Analysis** via `Agent_Open_Pipe__c`
2. **Future Pipeline Analysis** via `Agent_Cross_Sell__c`, `Agent_Renewals__c`, `Agent_Upsell__c`
3. **KPI Analysis** via `AGENT_OU_PIPELINE_V3__c`
4. **Content Search** via `Agent_Consensu__c`
5. **Learning Management** via `Course__c` and `Curriculum__c`

Each object is designed with comprehensive field mapping, data validation, and performance optimization to support the AI agent's analytical capabilities while maintaining data quality and system performance.

The system's strength lies in its ability to handle variations in field names, provide comprehensive aliasing, and maintain relationships across different data dimensions while ensuring governor-safe operations and optimal performance.
