// Simple Territory KPI Test Runner
System.debug('🧪 Running Simple Territory KPI Tests...');

// Test 1: Query AMER ICE records and analyze ACV QoQ
System.debug('=== TEST 1: ACB QoQ Difference Analysis ===');
try {
    List<AGENT_OU_PIPELINE_V2__c> amerIceRecords = [
        SELECT cq_acv__c, pq_acv__c, full_name__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE ou_name__c = 'AMER ICE' 
        AND cq_acv__c != null 
        AND pq_acv__c != null
        LIMIT 5
    ];
    
    if (!amerIceRecords.isEmpty()) {
        Decimal totalCurrentACV = 0, totalPreviousACV = 0;
        for (AGENT_OU_PIPELINE_V2__c record : amerIceRecords) {
            totalCurrentACV += record.cq_acv__c;
            totalPreviousACV += record.pq_acv__c;
        }
        
        Decimal totalDifference = totalCurrentACV - totalPreviousACV;
        
        System.debug('✅ ACB QoQ Analysis Results:');
        System.debug('- Total Current Quarter ACV: $' + totalCurrentACV);
        System.debug('- Total Previous Quarter ACV: $' + totalPreviousACV);
        System.debug('- Total Difference: $' + totalDifference);
    } else {
        System.debug('⚠️ No AMER ICE records found with ACV data');
    }
} catch (Exception e) {
    System.debug('❌ ACB QoQ Analysis Failed: ' + e.getMessage());
}

// Test 2: Query UKI records and analyze all KPIs
System.debug('=== TEST 2: All QoQ KPIs Analysis ===');
try {
    List<AGENT_OU_PIPELINE_V2__c> ukiRecords = [
        SELECT cq_pg__c, cq_acv__c, cq_customer_meeting__c, cq_call_connect__c, cq_cc_acv__c,
               pq_pg__c, pq_acv__c, pq_customer_meeting__c, pq_call_connect__c, pq_cc_acv__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE ou_name__c = 'UKI' 
        AND cq_pg__c != null AND pq_pg__c != null
        LIMIT 5
    ];
    
    if (!ukiRecords.isEmpty()) {
        Decimal cqPG = 0, cqACV = 0, cqMeetings = 0, cqCalls = 0, cqCCACV = 0;
        Decimal pqPG = 0, pqACV = 0, pqMeetings = 0, pqCalls = 0, pqCCACV = 0;
        
        for (AGENT_OU_PIPELINE_V2__c record : ukiRecords) {
            cqPG += record.cq_pg__c != null ? record.cq_pg__c : 0;
            cqACV += record.cq_acv__c != null ? record.cq_acv__c : 0;
            cqMeetings += record.cq_customer_meeting__c != null ? record.cq_customer_meeting__c : 0;
            cqCalls += record.cq_call_connect__c != null ? record.cq_call_connect__c : 0;
            cqCCACV += record.cq_cc_acv__c != null ? record.cq_cc_acv__c : 0;
            
            pqPG += record.pq_pg__c != null ? record.pq_pg__c : 0;
            pqACV += record.pq_acv__c != null ? record.pq_acv__c : 0;
            pqMeetings += record.pq_customer_meeting__c != null ? record.pq_customer_meeting__c : 0;
            pqCalls += record.pq_call_connect__c != null ? record.pq_call_connect__c : 0;
            pqCCACV += record.pq_cc_acv__c != null ? record.pq_cc_acv__c : 0;
        }
        
        System.debug('✅ UKI QoQ KPI Analysis Results:');
        System.debug('- Pipeline Generation: CQ=$' + cqPG + ', PQ=$' + pqPG + ', Diff=$' + (cqPG - pqPG));
        System.debug('- ACV: CQ=$' + cqACV + ', PQ=$' + pqACV + ', Diff=$' + (cqACV - pqACV));
        System.debug('- Customer Meetings: CQ=' + cqMeetings + ', PQ=' + pqMeetings + ', Diff=' + (cqMeetings - pqMeetings));
        System.debug('- Call Connect: CQ=' + cqCalls + ', PQ=' + pqCalls + ', Diff=' + (cqCalls - pqCalls));
        System.debug('- Create & Close ACV: CQ=$' + cqCCACV + ', PQ=$' + pqCCACV + ', Diff=$' + (cqCCACV - pqCCACV));
    } else {
        System.debug('⚠️ No UKI records found with KPI data');
    }
} catch (Exception e) {
    System.debug('❌ UKI QoQ KPI Analysis Failed: ' + e.getMessage());
}

// Test 3: Current-only KPIs (LATAM)
System.debug('=== TEST 3: Current-Only KPIs Analysis ===');
try {
    List<AGENT_OU_PIPELINE_V2__c> latamRecords = [
        SELECT cq_pg__c, cq_acv__c, coverage__c, call_ai_mention__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE ou_name__c = 'LATAM'
        LIMIT 5
    ];
    
    if (!latamRecords.isEmpty()) {
        Decimal totalCoverage = 0, totalAICalls = 0;
        Integer recordsWithCoverage = 0, recordsWithAICalls = 0;
        
        for (AGENT_OU_PIPELINE_V2__c record : latamRecords) {
            if (record.coverage__c != null) {
                totalCoverage += record.coverage__c;
                recordsWithCoverage++;
            }
            if (record.call_ai_mention__c != null) {
                totalAICalls += record.call_ai_mention__c;
                recordsWithAICalls++;
            }
        }
        
        Decimal avgCoverage = recordsWithCoverage > 0 ? totalCoverage / recordsWithCoverage : 0;
        Decimal avgAICalls = recordsWithAICalls > 0 ? totalAICalls / recordsWithAICalls : 0;
        
        System.debug('✅ LATAM Current-Only KPIs Results:');
        System.debug('- Total Coverage: ' + totalCoverage + ' (Average: ' + avgCoverage + ')');
        System.debug('- Total AI Calls: ' + totalAICalls + ' (Average: ' + avgAICalls + ')');
        System.debug('- Records with Coverage: ' + recordsWithCoverage);
        System.debug('- Records with AI Calls: ' + recordsWithAICalls);
    } else {
        System.debug('⚠️ No LATAM records found');
    }
} catch (Exception e) {
    System.debug('❌ LATAM Current-Only KPIs Analysis Failed: ' + e.getMessage());
}

// Test 4: OU-to-OU Comparison (AMER ICE vs UKI)
System.debug('=== TEST 4: OU-to-OU KPI Comparison ===');
try {
    List<AGENT_OU_PIPELINE_V2__c> amerIceRecords = [
        SELECT cq_customer_meeting__c, cq_call_connect__c, cq_acv__c, cq_pg__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE ou_name__c = 'AMER ICE'
        LIMIT 5
    ];
    
    List<AGENT_OU_PIPELINE_V2__c> ukiRecords = [
        SELECT cq_customer_meeting__c, cq_call_connect__c, cq_acv__c, cq_pg__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE ou_name__c = 'UKI'
        LIMIT 5
    ];
    
    if (!amerIceRecords.isEmpty() && !ukiRecords.isEmpty()) {
        Decimal amerIceMeetings = 0, amerIceCalls = 0, amerIceACV = 0, amerIcePG = 0;
        for (AGENT_OU_PIPELINE_V2__c record : amerIceRecords) {
            if (record.cq_customer_meeting__c != null) amerIceMeetings += record.cq_customer_meeting__c;
            if (record.cq_call_connect__c != null) amerIceCalls += record.cq_call_connect__c;
            if (record.cq_acv__c != null) amerIceACV += record.cq_acv__c;
            if (record.cq_pg__c != null) amerIcePG += record.cq_pg__c;
        }
        
        Decimal ukiMeetings = 0, ukiCalls = 0, ukiACV = 0, ukiPG = 0;
        for (AGENT_OU_PIPELINE_V2__c record : ukiRecords) {
            if (record.cq_customer_meeting__c != null) ukiMeetings += record.cq_customer_meeting__c;
            if (record.cq_call_connect__c != null) ukiCalls += record.cq_call_connect__c;
            if (record.cq_acv__c != null) ukiACV += record.cq_acv__c;
            if (record.cq_pg__c != null) ukiPG += record.cq_pg__c;
        }
        
        Decimal meetingDiff = amerIceMeetings - ukiMeetings;
        Decimal callDiff = amerIceCalls - ukiCalls;
        Decimal acvDiff = amerIceACV - ukiACV;
        Decimal pgDiff = amerIcePG - ukiPG;
        
        System.debug('✅ OU-to-OU Comparison Results (AMER ICE vs UKI):');
        System.debug('- AMER ICE: Meetings=' + amerIceMeetings + ', Calls=' + amerIceCalls + ', ACV=$' + amerIceACV + ', PG=$' + amerIcePG);
        System.debug('- UKI: Meetings=' + ukiMeetings + ', Calls=' + ukiCalls + ', ACV=$' + ukiACV + ', PG=$' + ukiPG);
        System.debug('- Differences: Meetings=' + meetingDiff + ', Calls=' + callDiff + ', ACV=$' + acvDiff + ', PG=$' + pgDiff);
    } else {
        System.debug('⚠️ Missing data for OU comparison');
    }
} catch (Exception e) {
    System.debug('❌ OU-to-OU Comparison Failed: ' + e.getMessage());
}

System.debug('🎯 All Simple Territory KPI Tests Completed!'); 