// Debug script to investigate OU filtering issues
// This will help us understand why AMER filtering is not working

System.debug('🔍 DEBUGGING OU FILTERING ISSUES');
System.debug('==================================');

// ============================================================================
// PHASE 1: CHECK WHAT OU VALUES EXIST IN THE DATA
// ============================================================================

System.debug('\n--- PHASE 1: Checking Available OU Values ---');

try {
    // Query to see what OU values actually exist
    String ouCheckQuery = 'SELECT DISTINCT OU_NAME__c, COUNT(Id) recordCount ' +
                          'FROM apm_outcome_v2__c ' +
                          'WHERE IsDeleted = false ' +
                          'AND (PROGRAM_TYPE__c != null OR OFFERING_PROGRAM_TYPE__c != null) ' +
                          'GROUP BY OU_NAME__c ' +
                          'ORDER BY recordCount DESC';
    
    System.debug('🔍 OU Check Query: ' + ouCheckQuery);
    
    List<AggregateResult> ouResults = Database.query(ouCheckQuery);
    
    System.debug('📊 Available OU Values:');
    for (AggregateResult result : ouResults) {
        String ouName = (String) result.get('OU_NAME__c');
        Integer count = (Integer) result.get('recordCount');
        System.debug('  • ' + ouName + ': ' + count + ' records');
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking OU values: ' + e.getMessage());
}

// ============================================================================
// PHASE 2: TEST THE EXACT SOQL QUERY BEING GENERATED
// ============================================================================

System.debug('\n--- PHASE 2: Testing Generated SOQL Query ---');

try {
    // Test the exact query that would be generated for AMER
    String testQuery = 'SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c, ' +
                       'FISCAL_QUARTER__c, KPI_NM__c, PRODUCT__c, OFFERING_ENABLEMENT_CATEGORY__c, ' +
                       'SIGNIFICANCE_INDICATOR__c, OU_NAME__c, MEAN_EFFECTIVENESS__c, MEAN_TREATMENT__c, ' +
                       'MEAN_CONTROL__c, CALCULATED_LIFT__c, AVG_INFLUENCED_ACV_PER_HEAD__c, ' +
                       'TOTAL_INFLUENCED_ACV__c, DISTINCT_LEARNERS__c, OFFERING_PROGRAM_TYPE__c ' +
                       'FROM apm_outcome_v2__c ' +
                       'WHERE IsDeleted = false ' +
                       'AND (PROGRAM_TYPE__c != null OR OFFERING_PROGRAM_TYPE__c != null) ' +
                       'AND (OU_NAME__c LIKE \'%AMER%\' OR OU_NAME__c LIKE \'%CAN%\' OR OU_NAME__c LIKE \'%LATAM%\' OR OU_NAME__c = \'AMER FINS, HLS, CAN\') ' +
                       'ORDER BY MEAN_EFFECTIVENESS__c DESC NULLS LAST, TOTAL_INFLUENCED_ACV__c DESC NULLS LAST ' +
                       'LIMIT 50';
    
    System.debug('🔍 Test Query: ' + testQuery);
    
    List<apm_outcome_v2__c> testResults = Database.query(testQuery);
    
    System.debug('📊 Test Query Results:');
    System.debug('  Total Records: ' + testResults.size());
    
    if (testResults.size() > 0) {
        System.debug('  Sample Records:');
        for (Integer i = 0; i < Math.min(3, testResults.size()); i++) {
            apm_outcome_v2__c record = testResults[i];
            System.debug('    ' + (i+1) + '. ' + record.OFFERING_LABEL__c + ' (OU: ' + record.OU_NAME__c + ')');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing generated query: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: TEST INDIVIDUAL OU PATTERNS
// ============================================================================

System.debug('\n--- PHASE 3: Testing Individual OU Patterns ---');

try {
    // Test each OU pattern individually
    List<String> ouPatterns = new List<String>{
        'AMER',
        'CAN', 
        'LATAM',
        'AMER FINS, HLS, CAN'
    };
    
    for (String pattern : ouPatterns) {
        String patternQuery = 'SELECT COUNT() FROM apm_outcome_v2__c ' +
                             'WHERE IsDeleted = false ' +
                             'AND (PROGRAM_TYPE__c != null OR OFFERING_PROGRAM_TYPE__c != null) ' +
                             'AND OU_NAME__c LIKE \'%' + pattern + '%\'';
        
        Integer count = Database.countQuery(patternQuery);
        System.debug('🔍 Pattern "' + pattern + '": ' + count + ' records');
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing individual patterns: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: CHECK FOR NULL OU VALUES
// ============================================================================

System.debug('\n--- PHASE 4: Checking for NULL OU Values ---');

try {
    // Check how many records have null OU values
    String nullOuQuery = 'SELECT COUNT() FROM apm_outcome_v2__c ' +
                         'WHERE IsDeleted = false ' +
                         'AND (PROGRAM_TYPE__c != null OR OFFERING_PROGRAM_TYPE__c != null) ' +
                         'AND OU_NAME__c = null';
    
    Integer nullOuCount = Database.countQuery(nullOuQuery);
    System.debug('🔍 Records with NULL OU: ' + nullOuCount);
    
    // Check total program records
    String totalQuery = 'SELECT COUNT() FROM apm_outcome_v2__c ' +
                        'WHERE IsDeleted = false ' +
                        'AND (PROGRAM_TYPE__c != null OR OFFERING_PROGRAM_TYPE__c != null)';
    
    Integer totalCount = Database.countQuery(totalQuery);
    System.debug('🔍 Total program records: ' + totalCount);
    
    System.debug('🔍 Percentage with NULL OU: ' + (nullOuCount * 100.0 / totalCount).setScale(1) + '%');
    
} catch (Exception e) {
    System.debug('❌ Error checking NULL OU values: ' + e.getMessage());
}

// ============================================================================
// PHASE 5: TEST THE ACTUAL SERVICE METHOD
// ============================================================================

System.debug('\n--- PHASE 5: Testing Actual Service Method ---');

try {
    System.debug('🔄 Testing ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms with AMER...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult result = 
        ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms(null, null, 'AMER');
    
    System.debug('📊 Service Method Results:');
    System.debug('  Success: ' + result.success);
    System.debug('  Message: ' + result.message);
    System.debug('  Total Records: ' + result.totalRecordCount);
    
    if (result.success && result.totalRecordCount > 0) {
        System.debug('✅ SUCCESS: Found AMER program data!');
    } else {
        System.debug('❌ No AMER program data found');
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing service method: ' + e.getMessage());
}

System.debug('\n🔍 OU FILTERING DEBUG COMPLETED');
System.debug('Check the debug logs above to identify the issue!'); 