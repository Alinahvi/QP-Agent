/**
 * Verification Script for UKI AE Count
 * 
 * This script verifies whether we actually have 2358 AEs in UKI
 * by checking multiple data sources and approaches.
 */

System.debug('=== VERIFYING UKI AE COUNT ===');
System.debug('Checking if 2358 AEs in UKI is accurate...');

// Test 1: Check Agent_Open_Pipe__c for UKI AEs
System.debug('--- Test 1: Agent_Open_Pipe__c UKI AE Count ---');
try {
    List<AggregateResult> openPipeCount = [
        SELECT COUNT_DISTINCT(EMP_ID__c) aeCount
        FROM Agent_Open_Pipe__c 
        WHERE OU_NAME__c = 'UKI'
        AND EMP_ID__c != null
    ];
    
    if (!openPipeCount.isEmpty()) {
        Integer count = (Integer)openPipeCount[0].get('aeCount');
        System.debug('Agent_Open_Pipe__c UKI AEs: ' + count);
        
        if (count == 2358) {
            System.debug('✅ Matches expected count of 2358');
        } else {
            System.debug('⚠️ Count mismatch - Expected: 2358, Actual: ' + count);
        }
    }
} catch (Exception e) {
    System.debug('❌ Agent_Open_Pipe__c count failed: ' + e.getMessage());
}

// Test 2: Check AGENT_OU_PIPELINE_V2__c for UKI AEs
System.debug('--- Test 2: AGENT_OU_PIPELINE_V2__c UKI AE Count ---');
try {
    List<AggregateResult> pipelineCount = [
        SELECT COUNT_DISTINCT(EMP_ID__c) aeCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c = 'UKI'
        AND EMP_ID__c != null
    ];
    
    if (!pipelineCount.isEmpty()) {
        Integer count = (Integer)pipelineCount[0].get('aeCount');
        System.debug('AGENT_OU_PIPELINE_V2__c UKI AEs: ' + count);
    }
} catch (Exception e) {
    System.debug('❌ AGENT_OU_PIPELINE_V2__c count failed: ' + e.getMessage());
}

// Test 3: Check what OU values actually exist
System.debug('--- Test 3: Available OU Values ---');
try {
    List<AggregateResult> allOUs = [
        SELECT OU_NAME__c, COUNT_DISTINCT(EMP_ID__c) aeCount
        FROM Agent_Open_Pipe__c 
        WHERE OU_NAME__c != null 
        AND EMP_ID__c != null
        GROUP BY OU_NAME__c 
        ORDER BY COUNT_DISTINCT(EMP_ID__c) DESC
        LIMIT 20
    ];
    
    System.debug('Top OUs by AE count:');
    for (AggregateResult ar : allOUs) {
        String ouName = (String)ar.get('OU_NAME__c');
        Integer count = (Integer)ar.get('aeCount');
        System.debug('  - ' + ouName + ': ' + count + ' AEs');
        
        if (ouName != null && ouName.containsIgnoreCase('UKI')) {
            System.debug('    *** UKI-related OU found ***');
        }
    }
} catch (Exception e) {
    System.debug('❌ OU values check failed: ' + e.getMessage());
}

// Test 4: Check for UKI variations
System.debug('--- Test 4: UKI Variations Search ---');
try {
    List<String> ukiVariations = new List<String>{
        'UKI', 'UK', 'United Kingdom', 'Britain', 'England', 'Scotland', 'Wales'
    };
    
    for (String variation : ukiVariations) {
        List<AggregateResult> variationCount = [
            SELECT COUNT_DISTINCT(EMP_ID__c) aeCount
            FROM Agent_Open_Pipe__c 
            WHERE (OU_NAME__c LIKE '%' + :variation + '%' 
                   OR WORK_LOCATION_COUNTRY__c LIKE '%' + :variation + '%')
            AND EMP_ID__c != null
        ];
        
        if (!variationCount.isEmpty()) {
            Integer count = (Integer)variationCount[0].get('aeCount');
            if (count > 0) {
                System.debug('Variation "' + variation + '": ' + count + ' AEs');
            }
        }
    }
} catch (Exception e) {
    System.debug('❌ UKI variations search failed: ' + e.getMessage());
}

// Test 5: Check sample UKI AEs to verify data quality
System.debug('--- Test 5: Sample UKI AEs Data Quality ---');
try {
    List<Agent_Open_Pipe__c> sampleAEs = [
        SELECT EMP_ID__c, FULL_NAME__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c, 
               OPEN_PIPE_PROD_NM__c, OPEN_PIPE_AE_SCORE__c
        FROM Agent_Open_Pipe__c 
        WHERE OU_NAME__c = 'UKI'
        AND EMP_ID__c != null
        LIMIT 10
    ];
    
    System.debug('Sample UKI AEs (' + sampleAEs.size() + ' records):');
    for (Agent_Open_Pipe__c ae : sampleAEs) {
        System.debug('  - ' + ae.FULL_NAME__c + ' (ID: ' + ae.EMP_ID__c + ')');
        System.debug('    OU: ' + ae.OU_NAME__c + ', Country: ' + ae.WORK_LOCATION_COUNTRY__c);
        System.debug('    Product: ' + ae.OPEN_PIPE_PROD_NM__c + ', Score: ' + ae.OPEN_PIPE_AE_SCORE__c);
    }
} catch (Exception e) {
    System.debug('❌ Sample UKI AEs check failed: ' + e.getMessage());
}

// Test 6: Check if the number might be inflated by duplicates
System.debug('--- Test 6: Duplicate Check ---');
try {
    // Check for potential duplicates in EMP_ID__c
    List<AggregateResult> duplicateCheck = [
        SELECT EMP_ID__c, COUNT(Id) recordCount
        FROM Agent_Open_Pipe__c 
        WHERE OU_NAME__c = 'UKI'
        AND EMP_ID__c != null
        GROUP BY EMP_ID__c
        HAVING COUNT(Id) > 1
        ORDER BY COUNT(Id) DESC
        LIMIT 10
    ];
    
    if (!duplicateCheck.isEmpty()) {
        System.debug('Potential duplicates found:');
        for (AggregateResult ar : duplicateCheck) {
            String empId = (String)ar.get('EMP_ID__c');
            Integer count = (Integer)ar.get('recordCount');
            System.debug('  - EMP_ID ' + empId + ': ' + count + ' records');
        }
    } else {
        System.debug('No obvious duplicates found in EMP_ID__c');
    }
} catch (Exception e) {
    System.debug('❌ Duplicate check failed: ' + e.getMessage());
}

// Test 7: Check total AEs across all OUs for context
System.debug('--- Test 7: Total AEs Across All OUs ---');
try {
    List<AggregateResult> totalAEs = [
        SELECT COUNT_DISTINCT(EMP_ID__c) totalCount
        FROM Agent_Open_Pipe__c 
        WHERE EMP_ID__c != null
    ];
    
    if (!totalAEs.isEmpty()) {
        Integer total = (Integer)totalAEs[0].get('totalCount');
        System.debug('Total AEs across all OUs: ' + total);
        
        if (total > 0) {
            Decimal ukiPercentage = (2358.0 / total) * 100;
            System.debug('UKI would represent ' + ukiPercentage.setScale(2) + '% of total AEs');
        }
    }
} catch (Exception e) {
    System.debug('❌ Total AEs count failed: ' + e.getMessage());
}

System.debug('=== UKI AE COUNT VERIFICATION COMPLETE ===');
System.debug('');
System.debug('Analysis Summary:');
System.debug('1. Checked Agent_Open_Pipe__c for UKI AEs');
System.debug('2. Checked AGENT_OU_PIPELINE_V2__c for UKI AEs');
System.debug('3. Listed all available OU values');
System.debug('4. Searched for UKI variations');
System.debug('5. Examined sample UKI AE data quality');
System.debug('6. Checked for potential duplicates');
System.debug('7. Provided context with total AE count');
System.debug('');
System.debug('The 2358 figure should be verified against actual data.');
