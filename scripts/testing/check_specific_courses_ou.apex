// Check specific courses that are appearing in AMER results
// This will help us understand why they're not being filtered out

System.debug('🔍 CHECKING SPECIFIC COURSES OU/REGION VALUES');
System.debug('=============================================');

// ============================================================================
// PHASE 1: CHECK THE SPECIFIC COURSES FROM THE USER'S OUTPUT
// ============================================================================

System.debug('\n--- PHASE 1: Checking Specific Courses ---');

List<String> courseNames = new List<String>{
    '[Korea] FY25 Q1 Slack Certification',
    'FY26 Q2 Product Decoded: MuleSoft for Flow: Integration',
    'FY25 Q4 Product Decoded: Agentforce & Slack',
    'Product Decoded: Slack Elevate',
    'C2 AE Academy: Sales Manager Readiness: Leader as a Coach (AMER/EMEA)'
};

try {
    for (String courseName : courseNames) {
        System.debug('\n🔍 Checking course: ' + courseName);
        
        // Query for this specific course
        String query = 'SELECT Id, OFFERING_LABEL__c, OU_NAME__c, REGION__c, MACRO_SEGMENT__c, ' +
                       'PROGRAM_TYPE__c, OFFERING_PROGRAM_TYPE__c, KPI_NM__c, TOTAL_INFLUENCED_ACV__c ' +
                       'FROM apm_outcome_v2__c ' +
                       'WHERE IsDeleted = false ' +
                       'AND OFFERING_LABEL__c = \'' + String.escapeSingleQuotes(courseName) + '\'';
        
        List<apm_outcome_v2__c> records = Database.query(query);
        
        if (records.size() > 0) {
            for (apm_outcome_v2__c record : records) {
                System.debug('📋 Course Details:');
                System.debug('  • OU_NAME__c: ' + record.OU_NAME__c);
                System.debug('  • REGION__c: ' + record.REGION__c);
                System.debug('  • MACRO_SEGMENT__c: ' + record.MACRO_SEGMENT__c);
                System.debug('  • PROGRAM_TYPE__c: ' + record.PROGRAM_TYPE__c);
                System.debug('  • OFFERING_PROGRAM_TYPE__c: ' + record.OFFERING_PROGRAM_TYPE__c);
                System.debug('  • KPI_NM__c: ' + record.KPI_NM__c);
                System.debug('  • TOTAL_INFLUENCED_ACV__c: ' + record.TOTAL_INFLUENCED_ACV__c);
                
                // Check if this should be considered AMER
                Boolean isAmer = false;
                if (String.isNotBlank(record.OU_NAME__c)) {
                    isAmer = record.OU_NAME__c.contains('AMER') || 
                             record.OU_NAME__c.contains('CAN') || 
                             record.OU_NAME__c.contains('LATAM') ||
                             record.OU_NAME__c == 'AMER FINS, HLS, CAN';
                }
                
                System.debug('  • Should be AMER: ' + isAmer);
                
                if (!isAmer) {
                    System.debug('  ⚠️  WARNING: This course should NOT appear in AMER results!');
                    System.debug('  🔍 Reason: OU_NAME__c does not contain AMER, CAN, or LATAM');
                }
            }
        } else {
            System.debug('❌ No records found for this course name');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking specific courses: ' + e.getMessage());
}

// ============================================================================
// PHASE 2: CHECK WHAT THE TOPIC IS ACTUALLY SENDING
// ============================================================================

System.debug('\n--- PHASE 2: Simulating What Topic Should Send ---');

System.debug('🎯 The topic SHOULD send this (CORRECT):');
System.debug('{');
System.debug('  "action": "ProgramEfficacy",');
System.debug('  "kpiName": "ACV",');
System.debug('  "operatingUnit": "AMER"  // ✅ CORRECT - filters OU_NAME__c');
System.debug('}');

System.debug('\n❌ The topic is PROBABLY sending this (WRONG):');
System.debug('{');
System.debug('  "action": "ProgramEfficacy",');
System.debug('  "kpiName": "ACV",');
System.debug('  "region": "AMER"  // ❌ WRONG - filters REGION__c (mostly null)');
System.debug('}');

// ============================================================================
// PHASE 3: TEST BOTH PARAMETER APPROACHES
// ============================================================================

System.debug('\n--- PHASE 3: Testing Both Parameter Approaches ---');

try {
    System.debug('🔄 Testing with CORRECT parameters (operatingUnit: "AMER")...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult correctResult = 
        ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms(null, null, 'AMER');
    
    System.debug('📊 CORRECT Parameters Results:');
    System.debug('  Success: ' + correctResult.success);
    System.debug('  Total Records: ' + correctResult.totalRecordCount);
    System.debug('  Message: ' + correctResult.message);
    
    if (correctResult.success && correctResult.totalRecordCount > 0) {
        System.debug('✅ SUCCESS: Found ' + correctResult.totalRecordCount + ' AMER programs!');
        
        // Show first few results to verify they're actually AMER
        if (correctResult.efficacyRecords != null && !correctResult.efficacyRecords.isEmpty()) {
            System.debug('\n📋 First 3 AMER Results:');
            for (Integer i = 0; i < Math.min(3, correctResult.efficacyRecords.size()); i++) {
                ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = correctResult.efficacyRecords[i];
                System.debug('  ' + (i+1) + '. ' + record.offeringLabel + ' (OU: ' + record.ouName + ')');
            }
        }
    } else {
        System.debug('❌ No AMER programs found with correct parameters');
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing correct parameters: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: CHECK IF REGION FIELD HAS ANY AMER VALUES
// ============================================================================

System.debug('\n--- PHASE 4: Checking REGION Field for AMER Values ---');

try {
    // Check if REGION__c field has any AMER values
    String regionQuery = 'SELECT DISTINCT REGION__c, COUNT(Id) recordCount ' +
                         'FROM apm_outcome_v2__c ' +
                         'WHERE IsDeleted = false ' +
                         'AND REGION__c != null ' +
                         'GROUP BY REGION__c ' +
                         'ORDER BY recordCount DESC';
    
    List<AggregateResult> regionResults = Database.query(regionQuery);
    
    System.debug('📊 Available REGION__c Values:');
    for (AggregateResult result : regionResults) {
        String region = (String) result.get('REGION__c');
        Integer count = (Integer) result.get('recordCount');
        System.debug('  • ' + region + ': ' + count + ' records');
    }
    
    // Check specifically for AMER in REGION__c
    String amerRegionQuery = 'SELECT COUNT() FROM apm_outcome_v2__c ' +
                             'WHERE IsDeleted = false ' +
                             'AND REGION__c LIKE \'%AMER%\'';
    
    Integer amerRegionCount = Database.countQuery(amerRegionQuery);
    System.debug('🔍 Records with REGION__c containing AMER: ' + amerRegionCount);
    
} catch (Exception e) {
    System.debug('❌ Error checking REGION field: ' + e.getMessage());
}

System.debug('\n🔍 SPECIFIC COURSES CHECK COMPLETED');
System.debug('This will show us exactly why these courses are appearing in AMER results!'); 