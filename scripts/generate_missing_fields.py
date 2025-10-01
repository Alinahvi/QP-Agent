#!/usr/bin/env python3
"""
Script to generate all missing field metadata files for AGENT_OU_PIPELINE_V2__c
Based on the comprehensive field definitions provided by the user
"""

import os

# Field definitions with their metadata
fields = [
    # Basic Employee Fields
    {
        'name': 'EMP_ID__c',
        'label': 'Employee ID',
        'type': 'Text',
        'length': '18',
        'description': 'Unique employee identifier used to join to HR/Workday and performance data. Stable key for the person—not the role or device. Example values: 888674, 728599, 889718.'
    },
    {
        'name': 'FULL_NAME__c',
        'label': 'Employee Full Name',
        'type': 'Text',
        'length': '255',
        'description': 'The employee\'s full display name as \'First Last\'. Use for presentation only; do not join on this field. Example values: Camden Wentz, Aly Barnhart, Sean McMillan.'
    },
    {
        'name': 'EMP_EMAIL_ADDR__c',
        'label': 'Employee Email',
        'type': 'Email',
        'length': '80',
        'description': 'The employee\'s corporate email address. Use for contacting the user and as a secondary join key when necessary. Example values: cwentz@salesforce.com, abarnhart@salesforce.com, sean.mcmillan@salesforce.com.'
    },
    {
        'name': 'WORK_LOCATION_COUNTRY__c',
        'label': 'Work Country',
        'type': 'Text',
        'length': '255',
        'description': 'Country of the employee\'s primary work location, used for geo/region rollups and eligibility rules. Example values: US, Brazil, Canada.'
    },
    {
        'name': 'OU_NAME__c',
        'label': 'Operating Unit (OU)',
        'type': 'Text',
        'length': '255',
        'description': 'Operating Unit the employee belongs to (Salesforce OU taxonomy) used for planning, reporting, and targeting. Example values: AMER ACC, LATAM, AMER ICE.'
    },
    {
        'name': 'EMP_MGR_NM__c',
        'label': 'Direct Manager Name',
        'type': 'Text',
        'length': '255',
        'description': 'Direct manager\'s name (one level up). Use for routing approvals and manager rollups; not a skip‑level manager. Example values: Katie O\'Rourke, Seth Maybury, Loren Fraser.'
    },
    {
        'name': 'PRIMARY_INDUSTRY__c',
        'label': 'Primary Industry (L1)',
        'type': 'Text',
        'length': '255',
        'description': 'Top‑level industry classification (e.g., HLS, FINS, CMT) aligned to Salesforce industry taxonomy. Example values: Engineering, Construction, & Real Estate, Travel, Transportation, & Hospitality, Technology.'
    },
    {
        'name': 'LEARNER_PROFILE_ID__c',
        'label': 'Learner Profile ID',
        'type': 'Text',
        'length': '18',
        'description': 'Internal SEED/Enablement Learner Profile ID. Joins the person to enablement activity and coaching history (Foreign key to Learner_Profile__c) Example values: a5jHu000001XWPPIA4, a5jHu000001E7G6IAK, a5jHu000001XfoTIAS.'
    },
    
    # Growth Factor Fields
    {
        'name': 'DEFINITION__c',
        'label': 'Definition',
        'type': 'LongTextArea',
        'length': '32768',
        'description': 'This refers to Growth Factors (GF) that each AE has. GFs are captured from seller performance predictor (SPP) which is an AI model that rank the major growth area each AE has to meet their quota Example values: Early-Stage Pipeline Percentage, Deal Size, Pipeline Stage Stagnation Percentage.'
    },
    {
        'name': 'DESCRIPTION__c',
        'label': 'Description',
        'type': 'LongTextArea',
        'length': '32768',
        'description': 'This is referring to definition of each Growth factor (Field Name Definition). This describes what that GF really means. Example values: Measures the percentage of a salesperson\'s open pipeline that is currently in stages 2-3 of the sales process. Improving this can help you with reaching your quota by driving potential business towards the later stages of the sales process and increasing the likelihood of closing deals.'
    },
    {
        'name': 'ACTIONABLE__c',
        'label': 'Actionable',
        'type': 'LongTextArea',
        'length': '32768',
        'description': 'If growth factor has action that AE can take to meet their quota. Example values: A pipe assessment and more targeted client communication could help you reduce your early-stage deals and increase your pipe quality. Sellers like you realized an increase in {} after taking the recommended course.'
    },
    {
        'name': 'RECOMMENDED_ACTION__c',
        'label': 'Recommended Action',
        'type': 'LongTextArea',
        'length': '32768',
        'description': 'Recommended action for their Growth Factor: Impactful Executive Communication, Assess AE Deal Health, Strategies for Reviving a Stalled Deal with Niklas Kotman.'
    },
    {
        'name': 'ACTION_LINK__c',
        'label': 'Action Link',
        'type': 'Url',
        'length': '255',
        'description': 'This refers to a content that can help AE to improve their GFs (note content is outdated not recommend users to use this). Example values: https://readiness.my.site.com/act/share-nav?recordId=a6JHu000000POp1&type=course.'
    },
    
    # Upsell Fields (1-5)
    {
        'name': 'UPSELL_ACCT_ID_1__c',
        'label': 'Upsell Acct Id 1',
        'type': 'Text',
        'length': '18',
        'description': 'Upsell opportunity no 1. Example values: 0013y00001focD2, 0010M00001QqTzb, 0013000001Msa5V.'
    },
    {
        'name': 'UPSELL_ACCT_NM_1__c',
        'label': 'Upsell Acct Nm 1',
        'type': 'Text',
        'length': '255',
        'description': 'Account (customer) name tied to Upsell opportunity no 1. Example values: Baker Roofing Company, MONI Smart Security (Org 2), Echo Global Logistics.'
    },
    {
        'name': 'UPSELL_SUB_CATEGORY_1__c',
        'label': 'Upsell Sub Category 1',
        'type': 'Text',
        'length': '255',
        'description': 'Product tied to Upsell no 1. Example values: AppExchange, Account Engagement, Slack.'
    },
    
    # Cross-Sell Fields (1-5)
    {
        'name': 'CS_ACCT_ID_1__c',
        'label': 'Cross-Sell Acct Id 1',
        'type': 'Text',
        'length': '18',
        'description': 'Cross-sell opportunity 1 Account ID. Example values: 0010M00001Qlf7n, 0013000000M1a2r, 0013000000hLc7m.'
    },
    {
        'name': 'CS_ACCT_NM_1__c',
        'label': 'Cross-Sell Acct Nm 1',
        'type': 'Text',
        'length': '255',
        'description': 'Cross-sell opportunity 1 Account Name. Example values: isolved Inc. - People Services, Troy Construction, Llp, Idealease Inc. - Lease Program Org.'
    },
    {
        'name': 'CS_NEXT_BEST_PRODUCT_1__c',
        'label': 'Cross-Sell Next Best Product 1',
        'type': 'Text',
        'length': '255',
        'description': 'Cross-sell opportunity 1 - product associated with. Example values: Sales Cloud, Tableau Cloud Data Management, Tableau Cloud Analytics.'
    },
    
    # Renewal Fields
    {
        'name': 'RENEWAL_ACCT_ID__c',
        'label': 'Renewal Acct Id',
        'type': 'Text',
        'length': '18',
        'description': 'Renewal opportunity Account ID. Example values: 00130000016hQwM, 0010M00001QqTzb, 00130000002xWii.'
    },
    {
        'name': 'RENEWAL_ACCT_NM__c',
        'label': 'Renewal Acct Nm',
        'type': 'Text',
        'length': '255',
        'description': 'Renewal opportunity Account Name. Example values: The Pool Management Group Inc, MONI Smart Security (Org 2), Annett Holdings, Inc. d/b/a TMC Transportation.'
    },
    {
        'name': 'RENEWAL_OPTY_NM__c',
        'label': 'Renewal Opty Nm',
        'type': 'Text',
        'length': '255',
        'description': 'Renewal opportunity name. Example values: The Pool Management Group Inc Renewal 28 Call Center, MONI Smart Security (Org 2) Renewal 287 Pardot, 1 Platform, Annett Holdings, Inc. d/b/a TMC Transportation Renewal 10 Salesforce Maps.'
    },
    {
        'name': 'RENEWAL_OPTY_AMT__c',
        'label': 'Renewal Opty Amt',
        'type': 'Currency',
        'precision': '18',
        'scale': '2',
        'description': 'Renewal opportunity amount. Example values: 37728.0, 188237.13, 6000.0.'
    },
    
    # Current Quarter Fields
    {
        'name': 'VAL_QUOTA__c',
        'label': 'Val Quota',
        'type': 'Currency',
        'precision': '18',
        'scale': '2',
        'description': 'Quota value for each AE. Example values: 268321.0, 255543.98, 214959.0.'
    },
    {
        'name': 'CQ_CUSTOMER_MEETING__c',
        'label': 'Current Quarter Customer Meeting',
        'type': 'Number',
        'precision': '18',
        'scale': '2',
        'description': 'Current quarter number customer meetings for each AE. Example values: 10.0, 6.0, 8.0.'
    },
    {
        'name': 'CQ_PG__c',
        'label': 'Current Quarter Pg',
        'type': 'Currency',
        'precision': '18',
        'scale': '2',
        'description': 'Amount of pipe generated by an AE in this quarter. Example values: 197778.12, 154950.0, 25188.18.'
    },
    {
        'name': 'CQ_ACV__c',
        'label': 'Current Quarter Acv',
        'type': 'Currency',
        'precision': '18',
        'scale': '2',
        'description': 'Amount of ACV generated by an AE in this quarter. Example values: 1861.32, 0.0, 148.17999999999995.'
    },
    {
        'name': 'CQ_CALL_CONNECT__c',
        'label': 'Current Quarter Call Connect',
        'type': 'Number',
        'precision': '18',
        'scale': '2',
        'description': 'Number of calls during this quarter for an AE. Example values: 0.0, 6.0, 31.0.'
    },
    {
        'name': 'CQ_CC_ACV__c',
        'label': 'Current Quarter Cc Acv',
        'type': 'Currency',
        'precision': '18',
        'scale': '2',
        'description': 'Current quarter Create and Close (C&C). C&C refers to ACV generated from same-period opportunities over the past three months measures the effectiveness of sales efforts. Example values: 1861.32, 0.0, 148.17999999999995.'
    },
    
    # Previous Quarter Fields
    {
        'name': 'PQ_CUSTOMER_MEETING__c',
        'label': 'Previous Quarter Customer Meeting',
        'type': 'Number',
        'precision': '18',
        'scale': '2',
        'description': 'Number of customer meetings for an AE in the previous quarter. Example values: 124.0, 121.0, 119.0.'
    },
    {
        'name': 'PQ_PG__c',
        'label': 'Previous Quarter Pg',
        'type': 'Currency',
        'precision': '18',
        'scale': '2',
        'description': 'Previous quarter pipe generated amount by an AE. Example values: 2324625.7300000004, 918487.41, 2848517.9399999995.'
    },
    {
        'name': 'PQ_ACV__c',
        'label': 'Previous Quarter Acv',
        'type': 'Currency',
        'precision': '18',
        'scale': '2',
        'description': 'Previous quarter ACV generated amount by AE. Example values: 391831.07000000007, 670328.24, 67205.39.'
    },
    {
        'name': 'PQ_CALL_CONNECT__c',
        'label': 'Previous Quarter Call Connect',
        'type': 'Number',
        'precision': '18',
        'scale': '2',
        'description': 'Previous quarter Call Connect by AE. Example values: 8.0, 0.0, 22.0.'
    },
    {
        'name': 'PQ_CC_ACV__c',
        'label': 'Previous Quarter Cc Acv',
        'type': 'Currency',
        'precision': '18',
        'scale': '2',
        'description': 'Previous quarter Create and Close (C&C) by AE. C&C means ACV generated from same-period opportunities over the past three months measures the effectiveness of sales efforts. Example values: 258226.09, 248706.03, 67205.39.'
    },
    
    # Performance Metrics
    {
        'name': 'COVERAGE__c',
        'label': 'Coverage',
        'type': 'Number',
        'precision': '18',
        'scale': '2',
        'description': 'This is a ratio of open deals in the current quarter to the quota for the current quarter. This metric shows salesperson\'s progress towards their sales target. Example values: 7.365006950630029, 3.242023545223018, 3.300493582497128.'
    },
    {
        'name': 'RAMP_STATUS__c',
        'label': 'Ramp Status',
        'type': 'Text',
        'length': '255',
        'description': 'Ramp Status: "Fast Ramper" - Any new hire who has exceeded the average quota attainment of their peers for more than 50% of the time during a given reference period. "On Track" - Any new hire who is not a "Fast Ramper" and has crossed the "ML ACV Participation" threshold for the quarter. "Slow Ramper" - Any new hire who has closed ACV but not closed more than their peers and is not likely to participate in the quarter. "Not Ramping" - Any new hire who has not closed any ACV.'
    },
    {
        'name': 'TIME_SINCE_ONBOARDING__c',
        'label': 'Time Since Onboarding',
        'type': 'Number',
        'precision': '18',
        'scale': '2',
        'description': 'Time since an AE onboarded with their new role in months (tenure). Example values: 27.86, 34.86, 25.86.'
    },
    {
        'name': 'FULLTOTALACVQUOTAUSD__c',
        'label': 'Full Total ACV Quota USD',
        'type': 'Currency',
        'precision': '18',
        'scale': '2',
        'description': 'Total Quota attained so far. Example values: 1362036.4054, 1297177.53, 1091162.2856.'
    },
    {
        'name': 'ACV_THRESHOLD__c',
        'label': 'ACV Threshold',
        'type': 'Currency',
        'precision': '18',
        'scale': '2',
        'description': 'ACV threshold based on their peer characteristics (region and segment). Example values: 75000.0, 100000.0.'
    },
    {
        'name': 'DAYS_TO_PRODUCTIVITY__c',
        'label': 'Days To Productivity',
        'type': 'Number',
        'precision': '18',
        'scale': '2',
        'description': 'The number of days it takes an AE to meet or exceed the average ACV attainment of their peers. Example values: 184.0, 225.0, 107.0.'
    }
]

def generate_field_xml(field):
    """Generate XML content for a field"""
    
    if field['type'] == 'Text':
        xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>{field['name']}</fullName>
    <description>{field['description']}</description>
    <externalId>false</externalId>
    <label>{field['label']}</label>
    <length>{field['length']}</length>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Text</type>
    <unique>false</unique>
</CustomField>'''
    
    elif field['type'] == 'Email':
        xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>{field['name']}</fullName>
    <description>{field['description']}</description>
    <externalId>false</externalId>
    <label>{field['label']}</label>
    <length>{field['length']}</length>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Email</type>
    <unique>false</unique>
</CustomField>'''
    
    elif field['type'] == 'Url':
        xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>{field['name']}</fullName>
    <description>{field['description']}</description>
    <externalId>false</externalId>
    <label>{field['label']}</label>
    <length>{field['length']}</length>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Url</type>
    <unique>false</unique>
</CustomField>'''
    
    elif field['type'] == 'LongTextArea':
        xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>{field['name']}</fullName>
    <description>{field['description']}</description>
    <externalId>false</externalId>
    <label>{field['label']}</label>
    <length>{field['length']}</length>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>LongTextArea</type>
    <visibleLines>3</visibleLines>
</CustomField>'''
    
    elif field['type'] == 'Number':
        xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>{field['name']}</fullName>
    <description>{field['description']}</description>
    <externalId>false</externalId>
    <label>{field['label']}</label>
    <precision>{field['precision']}</precision>
    <required>false</required>
    <scale>{field['scale']}</scale>
    <trackTrending>false</trackTrending>
    <type>Number</type>
    <unique>false</unique>
</CustomField>'''
    
    elif field['type'] == 'Currency':
        xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>{field['name']}</fullName>
    <description>{field['description']}</description>
    <externalId>false</externalId>
    <label>{field['label']}</label>
    <precision>{field['precision']}</precision>
    <required>false</required>
    <scale>{field['scale']}</scale>
    <trackTrending>false</trackTrending>
    <type>Currency</type>
    <unique>false</unique>
</CustomField>'''
    
    return xml

def main():
    """Main function to generate all field files"""
    
    # Create fields directory if it doesn't exist
    fields_dir = 'force-app/main/default/objects/AGENT_OU_PIPELINE_V2__c/fields'
    os.makedirs(fields_dir, exist_ok=True)
    
    print(f"🔧 Generating {len(fields)} missing field metadata files...")
    print("=" * 60)
    
    generated_count = 0
    
    for field in fields:
        filename = f"{fields_dir}/{field['name']}.field-meta.xml"
        
        # Check if file already exists
        if os.path.exists(filename):
            print(f"⚠️  SKIP: {field['name']} (already exists)")
            continue
        
        # Generate XML content
        xml_content = generate_field_xml(field)
        
        # Write to file
        with open(filename, 'w') as f:
            f.write(xml_content)
        
        print(f"✅ CREATED: {field['name']} - {field['label']}")
        generated_count += 1
    
    print("=" * 60)
    print(f"🎉 COMPLETED: Generated {generated_count} new field files")
    print(f"📁 Location: {fields_dir}")
    
    if generated_count > 0:
        print("\n🚀 NEXT STEPS:")
        print("1. Deploy the new fields: sf project deploy start --source-dir force-app/main/default/objects/AGENT_OU_PIPELINE_V2__c/fields")
        print("2. Verify field creation in Salesforce")
        print("3. Continue with Apex development")

if __name__ == "__main__":
    main() 