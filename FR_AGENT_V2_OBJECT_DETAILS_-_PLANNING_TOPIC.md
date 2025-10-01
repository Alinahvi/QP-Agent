# FR AGENT V2 OBJECT DETAILS - PLANNING TOPIC

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
  - **Business Context**: Critical metric for pipeline health analysis and stagnation detection. Used to identify opportunities that may be stuck or require intervention.
  - **Use Cases**:
    - **Stagnation Analysis**: Identify opportunities stuck in stages for extended periods (outlier cap: 200 days)
    - **Pipeline Health Monitoring**: Track average days in stage by product, AE, or territory
    - **Process Optimization**: Find bottlenecks in the sales process that cause delays
    - **Manager Coaching**: Alert managers to opportunities that need attention
    - **Forecasting Accuracy**: Predict closure likelihood based on stage duration patterns
    - **Product Analysis**: Compare stage duration across different products to identify selling challenges
  - **Unique Values**: Integer values (0-200+ days, with 200-day outlier cap for analysis)
  - **Variations**: `open_pipe_oppty_days_in_stage`, `open_pipe_opty_days_in_stg`, `open_pipe_oppty_days_in_stg`, `days_in_stage`, `stage_days`, `opp_days`, `oppty_days`

- **`open_pipe_ae_score__c`** (Number, 18,2)
  - **Purpose**: AE score (0-5 scale) indicating confidence level in opportunity closure
  - **Business Context**: Represents AE's confidence in closing the opportunity. Higher scores indicate higher probability of closure. Used for pipeline forecasting and risk assessment.
  - **Use Cases**:
    - **Pipeline Forecasting**: Weight pipeline value by AE score for more accurate forecasting
    - **Risk Assessment**: Identify high-value opportunities with low AE scores that may need support
    - **AE Performance**: Track AE scoring patterns to identify over/under-confident AEs
    - **Manager Coaching**: Focus coaching on opportunities with low scores
    - **Territory Analysis**: Compare average AE scores across different regions/segments
    - **Product Analysis**: Identify products where AEs consistently score low (indicating selling challenges)
  - **Unique Values**: Decimal values 0.0-5.0
  - **Variations**: `ae_score`, `score`, `sales_score`, `ae_sc`, `sales_sc`

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
  - **Purpose**: Linked learner profile ID for enablement and learning analytics
  - **Business Context**: Critical field that connects sales performance data with learning and development data. Enables correlation between training completion and sales performance.
  - **Use Cases**:
    - **Learning Analytics**: Correlate training completion with sales performance metrics
    - **Enablement ROI**: Measure impact of training programs on AE performance
    - **Personalized Learning**: Identify AEs who need specific training based on performance gaps
    - **Manager Coaching**: Provide managers with learning data for coaching conversations
    - **Performance Prediction**: Use learning patterns to predict AE success
  - **Unique Values**: Learner profile IDs
  - **Variations**: `learner_id`, `profile_id`, `learner_profile`

- **`time_since_onboarding__c`** (Number, 18,2)
  - **Purpose**: Time since onboarding in months - measures AE tenure
  - **Business Context**: Critical for understanding AE maturity and performance expectations. Used for ramp analysis and performance benchmarking.
  - **Use Cases**:
    - **Ramp Analysis**: Track AE performance progression during onboarding period
    - **Performance Benchmarking**: Compare AEs at similar tenure levels
    - **Coaching Timing**: Identify optimal times for different types of coaching
    - **Expectation Setting**: Set realistic performance expectations based on tenure
    - **Retention Analysis**: Identify AEs at risk of leaving based on tenure and performance
  - **Unique Values**: Decimal values (typically 0-60 months)
  - **Variations**: `onboarding_time`, `tenure`, `months_onboarded`

- **`ramp_status__c`** (Text, 255 chars)
  - **Purpose**: AE ramp status - indicates where the AE is in their onboarding journey
  - **Business Context**: Critical for understanding AE maturity and setting appropriate expectations. Used for performance analysis and coaching prioritization.
  - **Use Cases**:
    - **Performance Expectations**: Set different performance targets based on ramp status
    - **Coaching Prioritization**: Focus coaching resources on AEs who need it most
    - **Territory Planning**: Assign appropriate territories based on ramp status
    - **Manager Training**: Help managers understand how to coach AEs at different ramp stages
    - **Retention Risk**: Identify AEs at risk of leaving during critical ramp periods
  - **Unique Values**: 
    - `Fast Ramper` - AEs who ramp up quickly
    - `Standard Ramper` - AEs following normal ramp timeline
    - `Slow Ramper` - AEs taking longer than expected to ramp
    - `Ramped` - Fully ramped AEs
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
  - **Purpose**: Current quarter number of customer meetings for each AE
  - **Business Context**: Tracks AE engagement and customer interaction frequency. Used for performance analysis and outlier detection.
  - **Use Cases**: 
    - **Performance Benchmarking**: Compare meeting activity across AEs, regions, and segments
    - **Outlier Detection**: Identify AEs with unusually high/low meeting activity using Z-Score analysis
    - **Ramp Analysis**: Track meeting patterns for new AEs during onboarding
    - **Manager Coaching**: Identify AEs who need coaching on customer engagement
  - **Unique Values**: Decimal values (e.g., 10.0, 6.0, 8.0)
  - **Variations**: `meetings`, `customer_meetings`

- **`cq_calls__c`** (Number, 18,2)
  - **Purpose**: Current quarter number of call connects for each AE
  - **Business Context**: Measures AE call activity and connection success rate. Critical for understanding AE productivity and customer outreach effectiveness.
  - **Use Cases**:
    - **Productivity Analysis**: Track call volume trends and patterns
    - **Performance Correlation**: Analyze relationship between call activity and ACV/PG performance
    - **Territory Optimization**: Identify AEs with optimal call-to-meeting ratios
    - **Coaching Opportunities**: Find AEs with low call activity who may need support
  - **Unique Values**: Decimal values
  - **Variations**: `calls`, `call_count`

- **`cq_acv__c`** (Currency, 18,2)
  - **Purpose**: Current Quarter Annual Contract Value - total ACV generated from closed deals
  - **Business Context**: Primary revenue metric for AE performance. Represents actual closed business value in the current quarter.
  - **Use Cases**:
    - **Revenue Performance**: Track and compare AE revenue generation
    - **Quota Analysis**: Measure progress against quota targets
    - **Territory Planning**: Allocate territories based on ACV potential
    - **Compensation Planning**: Calculate commission and bonus structures
    - **Forecasting**: Predict future quarter performance based on current trends
  - **Unique Values**: Currency values
  - **Variations**: `acv`, `annual_contract_value`

- **`cq_pg__c`** (Currency, 18,2)
  - **Purpose**: Current Quarter Pipeline Generation - total pipeline value created
  - **Business Context**: Measures AE's ability to generate new pipeline opportunities. Critical for future revenue forecasting.
  - **Use Cases**:
    - **Pipeline Health**: Assess pipeline generation velocity and quality
    - **Future Revenue Prediction**: Forecast upcoming quarters based on PG trends
    - **AE Development**: Identify AEs who need help with pipeline generation
    - **Territory Analysis**: Compare pipeline generation across different regions/segments
    - **Coaching Focus**: Target AEs with low PG for pipeline development training
  - **Unique Values**: Currency values
  - **Variations**: `pg`, `pipeline_generation`

- **`cq_cc_acv__c`** (Currency, 18,2)
  - **Purpose**: Current quarter Create and Close (C&C) ACV - measures ACV from same-period opportunities
  - **Business Context**: Critical metric for measuring AE effectiveness in closing deals within the same period they were created. Indicates sales velocity and deal closure efficiency.
  - **Use Cases**:
    - **Sales Velocity Analysis**: Measure how quickly AEs can close deals after creating them
    - **Performance Efficiency**: Identify AEs who excel at fast deal closure
    - **Process Optimization**: Find bottlenecks in the sales process that slow deal closure
    - **Quota Achievement**: AEs with high C&C ACV are more likely to hit quota consistently
    - **Coaching Opportunities**: AEs with low C&C ACV may need help with deal acceleration techniques
  - **Unique Values**: Currency values (e.g., 1861.32, 0.0, 148.18)
  - **Variations**: `cc_acv`, `create_close_acv`

- **`val_quota__c`** (Currency, 18,2)
  - **Purpose**: Validation quota amount for the AE
  - **Business Context**: Represents the AE's assigned quota target for performance measurement and compensation calculation.
  - **Use Cases**:
    - **Performance Measurement**: Calculate quota attainment percentage
    - **Compensation Planning**: Determine commission and bonus eligibility
    - **Territory Planning**: Set realistic quota targets based on territory potential
    - **Manager Coaching**: Identify AEs at risk of missing quota
    - **Forecasting**: Predict end-of-quarter performance against quota
  - **Unique Values**: Currency values
  - **Variations**: `quota`, `validation_quota`

- **`coverage__c`** (Number, 18,2)
  - **Purpose**: Pipeline coverage ratio (pipeline value to quota ratio)
  - **Business Context**: Critical metric indicating whether an AE has sufficient pipeline to meet their quota. Values above 3.0 are typically considered healthy.
  - **Use Cases**:
    - **Pipeline Health Assessment**: Identify AEs with insufficient pipeline coverage
    - **Risk Management**: Flag AEs at risk of missing quota due to low coverage
    - **Territory Planning**: Adjust territory sizes based on coverage patterns
    - **Manager Intervention**: Trigger coaching sessions for AEs with low coverage
    - **Forecasting Accuracy**: Predict quota attainment likelihood based on coverage ratios
  - **Unique Values**: Decimal values (typically 0.5 to 5.0)
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

#### Advanced Analytics Fields
- **`call_ai_mention__c`** (Number, 18,0)
  - **Purpose**: AI mentions in calls - tracks how often AI tools are mentioned during customer calls
  - **Business Context**: Measures adoption and usage of AI tools in sales conversations. Critical for understanding AI tool effectiveness and training needs.
  - **Use Cases**:
    - **AI Adoption Tracking**: Monitor how often AEs mention AI tools to customers
    - **Training Effectiveness**: Measure impact of AI tool training on customer conversations
    - **Performance Correlation**: Analyze relationship between AI mentions and deal success
    - **Coaching Opportunities**: Identify AEs who need help with AI tool positioning
    - **Product Development**: Understand which AI features are most valuable to customers
  - **Unique Values**: Integer values (count of mentions)
  - **Variations**: `ai_mentions`, `call_ai_mentions`

- **`actionable__c`** (Text, 255 chars)
  - **Purpose**: Actionable growth factors and recommendations for the AE
  - **Business Context**: Contains specific, actionable recommendations for improving AE performance. Used for personalized coaching and development planning.
  - **Use Cases**:
    - **Personalized Coaching**: Provide specific recommendations for each AE
    - **Development Planning**: Create targeted development plans based on growth factors
    - **Manager Coaching**: Give managers specific talking points for coaching conversations
    - **Performance Improvement**: Track progress on actionable recommendations
    - **Success Pattern Analysis**: Identify common growth factors across top performers
  - **Unique Values**: Free text recommendations
  - **Variations**: `growth_factors`, `recommendations`, `actionable_items`

- **`definition__c`** (Text, 255 chars)
  - **Purpose**: Definition of the growth factor or performance metric being measured
  - **Business Context**: Provides context about what specific metric or factor is being measured (e.g., Early-Stage Pipeline Percentage, Deal Size, Pipeline Stage Stagnation).
  - **Use Cases**:
    - **Metric Education**: Help AEs understand what each metric means
    - **Manager Training**: Educate managers on performance metrics and their significance
    - **Coaching Clarity**: Provide clear definitions for coaching conversations
    - **Performance Context**: Help AEs understand how their performance is being measured
  - **Unique Values**: Metric definitions and explanations
  - **Variations**: `metric_definition`, `factor_definition`

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

## Advanced Analytics and Outlier Detection

### Outlier Detection System
The EBP Agent system includes sophisticated outlier detection capabilities using Z-Score analysis to identify AEs with unusual performance patterns:

#### **Z-Score Analysis**
- **Purpose**: Identifies AEs whose performance significantly deviates from the norm
- **Methodology**: Uses statistical Z-Score calculation to flag outliers
- **Threshold**: Typically 2-3 standard deviations from the mean
- **Use Cases**:
  - **Performance Anomalies**: Identify AEs with unusually high/low metrics
  - **Coaching Opportunities**: Flag AEs who need special attention
  - **Success Patterns**: Find top performers for best practice analysis
  - **Risk Management**: Identify AEs at risk of missing targets

#### **Supported Metrics for Outlier Detection**
- **ACV (Annual Contract Value)**: Revenue performance outliers
- **PG (Pipeline Generation)**: Pipeline creation outliers
- **Meetings**: Customer engagement outliers
- **Calls**: Activity level outliers
- **Coverage**: Pipeline health outliers
- **AI Mentions**: AI tool adoption outliers

### Growth Factors Analysis
The system analyzes multiple growth factors to provide actionable recommendations:

#### **Early-Stage Pipeline Percentage**
- **Purpose**: Measures percentage of pipeline in early stages
- **Business Context**: High early-stage percentage indicates good pipeline generation but may suggest closing challenges
- **Use Cases**: Identify AEs who need help with deal progression

#### **Deal Size Analysis**
- **Purpose**: Analyzes average deal size patterns
- **Business Context**: Helps identify AEs who may be focusing on wrong deal sizes
- **Use Cases**: Territory planning and coaching focus

#### **Pipeline Stage Stagnation**
- **Purpose**: Identifies opportunities stuck in specific stages
- **Business Context**: Indicates process bottlenecks or skill gaps
- **Use Cases**: Process optimization and targeted training

### Realism Guardrails
The system includes built-in guardrails to ensure realistic analysis:

#### **Days in Stage Analysis**
- **Outlier Cap**: 200 days to exclude ultra-outliers
- **Minimum Sample Size**: 2 opportunities per product for meaningful averages
- **Purpose**: Prevents skewed analysis from extreme outliers

#### **Governor Safety**
- **Memory Optimization**: Uses aggregate queries to prevent heap size issues
- **Selective SOQL**: Only loads essential fields
- **Limit Enforcement**: Built-in limits to prevent system overload

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
