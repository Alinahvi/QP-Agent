/**
 * @description Test script to verify existing KPI functionality
 * This tests what we already have in the org without deploying new classes
 */
System.debug('🧪 Testing Existing KPI Functionality...');

// Test 1: Check if AGENT_OU_PIPELINE_V2__c object exists and has data
System.debug('=== Test 1: Object and Data Verification ===');
try {
    // Check if object exists
    Schema.SObjectType objType = Schema.getGlobalDescribe().get('AGENT_OU_PIPELINE_V2__c');
    if (objType != null) {
        System.debug('✅ AGENT_OU_PIPELINE_V2__c object exists');
        
        // Check record count
        Integer recordCount = Database.countQuery('SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c');
        System.debug('📊 Total records: ' + recordCount);
        
        if (recordCount > 0) {
            // Sample a few records to see structure
            List<AGENT_OU_PIPELINE_V2__c> sampleRecords = [
                SELECT Id, emp_id__c, full_name__c, ou_name__c, primary_industry__c, 
                       work_location_country__c, val_quota__c, cq_pg__c, cq_acv__c,
                       cq_customer_meeting__c, cq_call_connect__c, cq_cc_acv__c,
                       pq_pg__c, pq_acv__c, pq_customer_meeting__c, pq_call_connect__c,
                       pq_cc_acv__c, coverage__c, call_ai_mention__c,
                       definition__c, description__c, actionable__c, recommended_action__c, action_link__c
                FROM AGENT_OU_PIPELINE_V2__c 
                LIMIT 5
            ];
            
            System.debug('📋 Sample records structure:');
            for (AGENT_OU_PIPELINE_V2__c record : sampleRecords) {
                System.debug('  - Employee: ' + record.full_name__c + ' (' + record.emp_id__c + ')');
                System.debug('    OU: ' + record.ou_name__c + ', Vertical: ' + record.primary_industry__c);
                System.debug('    CQ PG: ' + record.cq_pg__c + ', CQ ACV: ' + record.cq_acv__c);
                System.debug('    PQ PG: ' + record.pq_pg__c + ', PQ ACV: ' + record.pq_acv__c);
                System.debug('    Coverage: ' + record.coverage__c + ', AI Calls: ' + record.call_ai_mention__c);
                System.debug('    Growth Factor: ' + record.definition__c);
                System.debug('---');
            }
        } else {
            System.debug('⚠️ No records found in AGENT_OU_PIPELINE_V2__c');
        }
    } else {
        System.debug('❌ AGENT_OU_PIPELINE_V2__c object does not exist');
    }
} catch (Exception e) {
    System.debug('❌ Error checking object: ' + e.getMessage());
}

// Test 2: Test KPI Calculations Manually
System.debug('=== Test 2: Manual KPI Calculations ===');
try {
    // Get all records for KPI calculation
    List<AGENT_OU_PIPELINE_V2__c> allRecords = [
        SELECT cq_pg__c, cq_acv__c, cq_customer_meeting__c, cq_call_connect__c, cq_cc_acv__c,
               pq_pg__c, pq_acv__c, pq_customer_meeting__c, pq_call_connect__c, pq_cc_acv__c,
               coverage__c, call_ai_mention__c
        FROM AGENT_OU_PIPELINE_V2__c
    ];
    
    if (!allRecords.isEmpty()) {
        // Calculate KPIs manually
        Decimal totalCQPG = 0, totalCQACV = 0, totalCQMeetings = 0, totalCQCalls = 0, totalCQCCACV = 0;
        Decimal totalPQPG = 0, totalPQACV = 0, totalPQMeetings = 0, totalPQCalls = 0, totalPQCCACV = 0;
        Decimal totalCoverage = 0, totalAICalls = 0;
        
        Integer recordsWithPQ = 0;
        
        for (AGENT_OU_PIPELINE_V2__c record : allRecords) {
            // Current Quarter
            if (record.cq_pg__c != null) totalCQPG += record.cq_pg__c;
            if (record.cq_acv__c != null) totalCQACV += record.cq_acv__c;
            if (record.cq_customer_meeting__c != null) totalCQMeetings += record.cq_customer_meeting__c;
            if (record.cq_call_connect__c != null) totalCQCalls += record.cq_call_connect__c;
            if (record.cq_cc_acv__c != null) totalCQCCACV += record.cq_cc_acv__c;
            
            // Previous Quarter
            if (record.pq_pg__c != null) {
                totalPQPG += record.pq_pg__c;
                recordsWithPQ++;
            }
            if (record.pq_acv__c != null) totalPQACV += record.pq_acv__c;
            if (record.pq_customer_meeting__c != null) totalPQMeetings += record.pq_customer_meeting__c;
            if (record.pq_call_connect__c != null) totalPQCalls += record.pq_call_connect__c;
            if (record.pq_cc_acv__c != null) totalPQCCACV += record.pq_cc_acv__c;
            
            // Other KPIs
            if (record.coverage__c != null) totalCoverage += record.coverage__c;
            if (record.call_ai_mention__c != null) totalAICalls += record.call_ai_mention__c;
        }
        
        System.debug('📊 KPI Summary:');
        System.debug('  Pipeline Generation: CQ=$' + totalCQPG + ', PQ=$' + totalPQPG + ', Change=$' + (totalCQPG - totalPQPG));
        System.debug('  ACV: CQ=$' + totalCQACV + ', PQ=$' + totalPQACV + ', Change=$' + (totalCQACV - totalPQACV));
        System.debug('  Customer Meetings: CQ=' + totalCQMeetings + ', PQ=' + totalPQMeetings + ', Change=' + (totalCQMeetings - totalPQMeetings));
        System.debug('  Call Connect: CQ=' + totalCQCalls + ', PQ=' + totalPQCalls + ', Change=' + (totalCQCalls - totalPQCalls));
        System.debug('  Create & Close ACV: CQ=$' + totalCQCCACV + ', PQ=$' + totalPQCCACV + ', Change=$' + (totalCQCCACV - totalPQCCACV));
        System.debug('  Coverage: ' + totalCoverage + ' (average: ' + (totalCoverage / allRecords.size()) + ')');
        System.debug('  AI Calls Mentioned: ' + totalAICalls);
        System.debug('  Records with Previous Quarter data: ' + recordsWithPQ + '/' + allRecords.size());
        
    } else {
        System.debug('⚠️ No records available for KPI calculation');
    }
} catch (Exception e) {
    System.debug('❌ Error calculating KPIs: ' + e.getMessage());
}

// Test 3: Test OU-to-OU Comparison
System.debug('=== Test 3: OU-to-OU Comparison ===');
try {
    // Get unique OUs
    List<AggregateResult> ouList = [
        SELECT ou_name__c, COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        GROUP BY ou_name__c 
        ORDER BY COUNT(Id) DESC
        LIMIT 5
    ];
    
    if (ouList.size() >= 2) {
        String ou1 = (String) ouList[0].get('ou_name__c');
        String ou2 = (String) ouList[1].get('ou_name__c');
        
        System.debug('🔄 Comparing ' + ou1 + ' vs ' + ou2);
        
        // Get data for both OUs
        List<AGENT_OU_PIPELINE_V2__c> ou1Records = [
            SELECT cq_pg__c, cq_acv__c, cq_customer_meeting__c, cq_call_connect__c, cq_cc_acv__c
            FROM AGENT_OU_PIPELINE_V2__c 
            WHERE ou_name__c = :ou1
        ];
        
        List<AGENT_OU_PIPELINE_V2__c> ou2Records = [
            SELECT cq_pg__c, cq_acv__c, cq_customer_meeting__c, cq_call_connect__c, cq_cc_acv__c
            FROM AGENT_OU_PIPELINE_V2__c 
            WHERE ou_name__c = :ou2
        ];
        
        // Calculate totals for OU1
        Decimal ou1PG = 0, ou1ACV = 0, ou1Meetings = 0, ou1Calls = 0, ou1CCACV = 0;
        for (AGENT_OU_PIPELINE_V2__c record : ou1Records) {
            if (record.cq_pg__c != null) ou1PG += record.cq_pg__c;
            if (record.cq_acv__c != null) ou1ACV += record.cq_acv__c;
            if (record.cq_customer_meeting__c != null) ou1Meetings += record.cq_customer_meeting__c;
            if (record.cq_call_connect__c != null) ou1Calls += record.cq_call_connect__c;
            if (record.cq_cc_acv__c != null) ou1CCACV += record.cq_cc_acv__c;
        }
        
        // Calculate totals for OU2
        Decimal ou2PG = 0, ou2ACV = 0, ou2Meetings = 0, ou2Calls = 0, ou2CCACV = 0;
        for (AGENT_OU_PIPELINE_V2__c record : ou2Records) {
            if (record.cq_pg__c != null) ou2PG += record.cq_pg__c;
            if (record.cq_acv__c != null) ou2ACV += record.cq_acv__c;
            if (record.cq_customer_meeting__c != null) ou2Meetings += record.cq_customer_meeting__c;
            if (record.cq_call_connect__c != null) ou2Calls += record.cq_call_connect__c;
            if (record.cq_cc_acv__c != null) ou2CCACV += record.cq_cc_acv__c;
        }
        
        System.debug('📊 OU Comparison Results:');
        System.debug('  ' + ou1 + ' (Records: ' + ou1Records.size() + '):');
        System.debug('    PG: $' + ou1PG + ', ACV: $' + ou1ACV + ', Meetings: ' + ou1Meetings + ', Calls: ' + ou1Calls + ', CC ACV: $' + ou1CCACV);
        System.debug('  ' + ou2 + ' (Records: ' + ou2Records.size() + '):');
        System.debug('    PG: $' + ou2PG + ', ACV: $' + ou2ACV + ', Meetings: ' + ou2Meetings + ', Calls: ' + ou2Calls + ', CC ACV: $' + ou2CCACV);
        System.debug('  Differences:');
        System.debug('    PG: $' + (ou1PG - ou2PG) + ' (' + (ou1PG > ou2PG ? ou1 : ou2) + ' advantage)');
        System.debug('    ACV: $' + (ou1ACV - ou2ACV) + ' (' + (ou1ACV > ou2ACV ? ou1 : ou2) + ' advantage)');
        System.debug('    Meetings: ' + (ou1Meetings - ou2Meetings) + ' (' + (ou1Meetings > ou2Meetings ? ou1 : ou2) + ' advantage)');
        System.debug('    Calls: ' + (ou1Calls - ou2Calls) + ' (' + (ou1Calls > ou2Calls ? ou1 : ou2) + ' advantage)');
        System.debug('    CC ACV: $' + (ou1CCACV - ou2CCACV) + ' (' + (ou1CCACV > ou2CCACV ? ou1 : ou2) + ' advantage)');
        
    } else {
        System.debug('⚠️ Not enough OUs for comparison');
    }
} catch (Exception e) {
    System.debug('❌ Error in OU comparison: ' + e.getMessage());
}

// Test 4: Test Growth Factor Analysis
System.debug('=== Test 4: Growth Factor Analysis ===');
try {
    // Get growth factors
    List<AggregateResult> growthFactors = [
        SELECT definition__c, COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE definition__c != null
        GROUP BY definition__c 
        ORDER BY COUNT(Id) DESC
        LIMIT 5
    ];
    
    if (!growthFactors.isEmpty()) {
        System.debug('📈 Top Growth Factors:');
        for (AggregateResult gf : growthFactors) {
            String definition = (String) gf.get('definition__c');
            Integer count = (Integer) gf.get('recordCount');
            System.debug('  - ' + definition + ': ' + count + ' occurrences');
        }
    } else {
        System.debug('⚠️ No growth factors found');
    }
} catch (Exception e) {
    System.debug('❌ Error in growth factor analysis: ' + e.getMessage());
}

System.debug('✅ KPI Functionality Testing Complete!'); 