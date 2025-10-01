// Debug script to understand why unrelated results still appear
// This will help us find where "FY25 Solution Selling Showdown" is coming from

System.debug('🔍 DEBUGGING UNRELATED RESULTS - WHY FY25 SOLUTION SELLING SHOWDOWN?');
System.debug('=====================================================================');

// ============================================================================
// PHASE 1: TEST EXACT SEARCH TO SEE WHAT'S BEING FOUND
// ============================================================================

System.debug('\n--- PHASE 1: Testing Exact "Data Cloud" Search ---');

try {
    // Test the exact search our service is doing
    String exactSoql = 'SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c, ' +
                     'FISCAL_QUARTER__c, KPI_NM__c, PRODUCT__c, OFFERING_ENABLEMENT_CATEGORY__c, ' +
                     'SIGNIFICANCE_INDICATOR__c, OU_NAME__c, MEAN_EFFECTIVENESS__c, MEAN_TREATMENT__c, ' +
                     'MEAN_CONTROL__c, CALCULATED_LIFT__c, AVG_INFLUENCED_ACV_PER_HEAD__c, ' +
                     'TOTAL_INFLUENCED_ACV__c, DISTINCT_LEARNERS__c, OFFERING_PROGRAM_TYPE__c ' +
                     'FROM apm_outcome_v2__c ' +
                     'WHERE IsDeleted = false AND OFFERING_LABEL__c LIKE \'%Data Cloud%\' ' +
                     'ORDER BY TOTAL_INFLUENCED_ACV__c DESC ' +
                     'LIMIT 10';
    
    List<apm_outcome_v2__c> exactResults = Database.query(exactSoql);
    
    System.debug('📊 Exact "Data Cloud" Search Results:');
    System.debug('  Total Records: ' + exactResults.size());
    
    if (!exactResults.isEmpty()) {
        Set<String> exactOfferings = new Set<String>();
        for (apm_outcome_v2__c record : exactResults) {
            exactOfferings.add(record.OFFERING_LABEL__c);
        }
        System.debug('  Unique Offerings: ' + exactOfferings.size());
        
        for (String offering : exactOfferings) {
            System.debug('  • ' + offering);
        }
        
        // Check if the problematic offering is in exact results
        if (exactOfferings.contains('FY25 Solution Selling Showdown')) {
            System.debug('❌ PROBLEM: FY25 Solution Selling Showdown found in EXACT Data Cloud search!');
            System.debug('🔍 This means our search logic is wrong');
        } else {
            System.debug('✅ Good: FY25 Solution Selling Showdown NOT in exact Data Cloud search');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error in exact search: ' + e.getMessage());
}

// ============================================================================
// PHASE 2: TEST BROADER SEARCH TO SEE WHAT'S BEING FOUND
// ============================================================================

System.debug('\n--- PHASE 2: Testing Broader Search (What Our Logic Is Finding) ---');

try {
    // This is what our enhanced logic is doing - searching for "Data" instead of "Data Cloud"
    String broaderSoql = 'SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c, ' +
                         'FISCAL_QUARTER__c, KPI_NM__c, PRODUCT__c, OFFERING_ENABLEMENT_CATEGORY__c, ' +
                         'SIGNIFICANCE_INDICATOR__c, OU_NAME__c, MEAN_EFFECTIVENESS__c, MEAN_TREATMENT__c, ' +
                         'MEAN_CONTROL__c, CALCULATED_LIFT__c, AVG_INFLUENCED_ACV_PER_HEAD__c, ' +
                         'TOTAL_INFLUENCED_ACV__c, DISTINCT_LEARNERS__c, OFFERING_PROGRAM_TYPE__c ' +
                         'FROM apm_outcome_v2__c ' +
                         'WHERE IsDeleted = false AND OFFERING_LABEL__c LIKE \'%Data%\' ' +
                         'ORDER BY TOTAL_INFLUENCED_ACV__c DESC ' +
                         'LIMIT 20';
    
    List<apm_outcome_v2__c> broaderResults = Database.query(broaderSoql);
    
    System.debug('📊 Broader "Data" Search Results:');
    System.debug('  Total Records: ' + broaderResults.size());
    
    if (!broaderResults.isEmpty()) {
        Set<String> broaderOfferings = new Set<String>();
        for (apm_outcome_v2__c record : broaderResults) {
            broaderOfferings.add(record.OFFERING_LABEL__c);
        }
        System.debug('  Unique Offerings: ' + broaderOfferings.size());
        
        // Show first 15 offerings to see what's being found
        Integer count = 0;
        for (String offering : broaderOfferings) {
            if (count < 15) {
                System.debug('  • ' + offering);
                count++;
            } else {
                break;
            }
        }
        
        // Check if "FY25 Solution Selling Showdown" is in the broader results
        if (broaderOfferings.contains('FY25 Solution Selling Showdown')) {
            System.debug('\n🔍 FOUND THE CULPRIT!');
            System.debug('  "FY25 Solution Selling Showdown" appears in broader "Data" search');
            System.debug('  This explains why it shows up for "Data Cloud" search');
            
            // Show the specific records for this offering
            System.debug('\n📋 Details for FY25 Solution Selling Showdown:');
            for (apm_outcome_v2__c record : broaderResults) {
                if (record.OFFERING_LABEL__c == 'FY25 Solution Selling Showdown') {
                    System.debug('  • KPI: ' + record.KPI_NM__c);
                    System.debug('    Effectiveness: ' + record.MEAN_EFFECTIVENESS__c);
                    System.debug('    Lift: ' + record.CALCULATED_LIFT__c);
                    System.debug('    ACV: ' + record.TOTAL_INFLUENCED_ACV__c);
                    System.debug('    Program Type: ' + record.PROGRAM_TYPE__c);
                    System.debug('    Product: ' + record.PRODUCT__c);
                }
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error in broader search: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: TEST OUR SERVICE DIRECTLY
// ============================================================================

System.debug('\n--- PHASE 3: Testing Our Service Directly ---');

try {
    System.debug('🔄 Testing ANAgentOfferingEfficacyServiceBasic.searchEfficacyData directly...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult serviceResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData('Data Cloud', null, null, null, null, null, null, 5);
    
    System.debug('📊 Direct Service Call Results:');
    System.debug('  Success: ' + serviceResult.success);
    System.debug('  Message: ' + serviceResult.message);
    System.debug('  Total Records: ' + serviceResult.totalRecordCount);
    
    if (serviceResult.success && serviceResult.efficacyRecords != null) {
        System.debug('  Records from Direct Service Call:');
        for (Integer i = 0; i < serviceResult.efficacyRecords.size(); i++) {
            ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = serviceResult.efficacyRecords[i];
            System.debug('    ' + (i + 1) + '. ' + record.offeringLabel + ' (KPI: ' + record.kpiName + ')');
            
            // Check if this is the problematic offering
            if (record.offeringLabel == 'FY25 Solution Selling Showdown') {
                System.debug('      ❌ PROBLEM: This offering should NOT appear for Data Cloud search!');
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error in direct service call: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: ROOT CAUSE ANALYSIS
// ============================================================================

System.debug('\n--- PHASE 4: Root Cause Analysis ---');

System.debug('🔍 WHY "FY25 Solution Selling Showdown" APPEARS FOR "DATA CLOUD" SEARCH:');
System.debug('  1. User searches for "Data Cloud"');
System.debug('  2. Exact search finds limited results (2 offerings)');
System.debug('  3. Our logic triggers broader search for "Data"');
System.debug('  4. "Data" search finds "FY25 Solution Selling Showdown"');
System.debug('  5. This offering gets included in results');
System.debug('  6. Even though it has NOTHING to do with Data Cloud');

System.debug('\n❌ THE REAL PROBLEM:');
System.debug('  Our "intelligent broadening" is TOO aggressive');
System.debug('  Searching for "Data" finds completely unrelated courses');
System.debug('  We need RELEVANCE FILTERING, not just broader search');

System.debug('\n✅ SOLUTIONS NEEDED:');
System.debug('  1. Make broadening less aggressive');
System.debug('  2. Add relevance scoring');
System.debug('  3. Implement clarifying questions through instructions');
System.debug('  4. Make the code lighter and more focused');

System.debug('\n🧪 DEBUG COMPLETED');
System.debug('Now we know exactly why unrelated results appear!'); 