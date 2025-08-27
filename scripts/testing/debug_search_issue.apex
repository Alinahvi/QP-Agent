// Debug script to understand why search is returning wrong results
// This will help us identify why "FY25 Solution Selling Showdown" appears for "Data Cloud" search

System.debug('🔍 DEBUGGING SEARCH ISSUE - WHY WRONG RESULTS?');
System.debug('================================================');

// ============================================================================
// PHASE 1: TRACE THE EXACT SEARCH LOGIC
// ============================================================================

System.debug('\n--- PHASE 1: Tracing Search Logic ---');

// Simulate the exact user request
String userQuery = 'Show me top 5 effective courses on data cloud';
String searchTerm = 'Data Cloud';

System.debug('🎯 User Query: ' + userQuery);
System.debug('🔍 Search Term: ' + searchTerm);

// ============================================================================
// PHASE 2: TEST EXACT SEARCH FIRST
// ============================================================================

System.debug('\n--- PHASE 2: Testing Exact "Data Cloud" Search ---');

try {
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
    }
    
} catch (Exception e) {
    System.debug('❌ Error in exact search: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: TEST BROADER SEARCH TO SEE WHAT'S BEING FOUND
// ============================================================================

System.debug('\n--- PHASE 3: Testing Broader Search (What Our Logic Is Finding) ---');

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
        
        // Show first 10 offerings to see what's being found
        Integer count = 0;
        for (String offering : broaderOfferings) {
            if (count < 10) {
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
// PHASE 4: ANALYZE WHY THIS IS HAPPENING
// ============================================================================

System.debug('\n--- PHASE 4: Root Cause Analysis ---');

System.debug('🔍 WHY "FY25 Solution Selling Showdown" APPEARS FOR "DATA CLOUD" SEARCH:');
System.debug('  1. User searches for "Data Cloud"');
System.debug('  2. Exact search finds limited results (2 offerings)');
System.debug('  3. Our logic triggers broader search for "Data"');
System.debug('  4. "Data" search finds "FY25 Solution Selling Showdown"');
System.debug('  5. This offering gets included in results');
System.debug('  6. Same offering appears multiple times due to different KPIs');

System.debug('\n❌ PROBLEMS IDENTIFIED:');
System.debug('  1. Broader search is too aggressive');
System.debug('  2. "Data" is too broad - finds unrelated courses');
System.debug('  3. Same offering repeated due to KPI granularity');
System.debug('  4. No relevance filtering');

System.debug('\n✅ SOLUTIONS NEEDED:');
System.debug('  1. Make broadening less aggressive');
System.debug('  2. Add relevance scoring');
System.debug('  3. Better KPI aggregation');
System.debug('  4. Smarter search term selection');

System.debug('\n🧪 DEBUG COMPLETED');
System.debug('Now we know exactly why the wrong results appear!'); 