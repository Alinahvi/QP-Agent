// Test script to search for broader Data Cloud offerings
// This will help us understand if there are more diverse courses available

System.debug('🔍 TESTING BROADER DATA CLOUD SEARCH');
System.debug('=====================================');

// ============================================================================
// PHASE 1: SEARCH FOR ALL DATA CLOUD RELATED OFFERINGS
// ============================================================================

System.debug('\n--- PHASE 1: Broad Data Cloud Search ---');

try {
    // Search for any offering containing "Data Cloud" (broader search)
    String soql = 'SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c, ' +
                 'FISCAL_QUARTER__c, KPI_NM__c, PRODUCT__c, OFFERING_ENABLEMENT_CATEGORY__c, ' +
                 'SIGNIFICANCE_INDICATOR__c, OU_NAME__c, MEAN_EFFECTIVENESS__c, MEAN_TREATMENT__c, ' +
                 'MEAN_CONTROL__c, CALCULATED_LIFT__c, AVG_INFLUENCED_ACV_PER_HEAD__c, ' +
                 'TOTAL_INFLUENCED_ACV__c, DISTINCT_LEARNERS__c, OFFERING_PROGRAM_TYPE__c ' +
                 'FROM apm_outcome_v2__c ' +
                 'WHERE IsDeleted = false AND OFFERING_LABEL__c LIKE \'%Data Cloud%\' ' +
                 'ORDER BY TOTAL_INFLUENCED_ACV__c DESC ' +
                 'LIMIT 50';
    
    List<apm_outcome_v2__c> records = Database.query(soql);
    
    System.debug('📊 Search Results:');
    System.debug('  Total Records Found: ' + records.size());
    
    if (!records.isEmpty()) {
        // Group by offering label to see variety
        Map<String, List<apm_outcome_v2__c>> offeringsByLabel = new Map<String, List<apm_outcome_v2__c>>();
        
        for (apm_outcome_v2__c record : records) {
            String offeringLabel = record.OFFERING_LABEL__c;
            if (!offeringsByLabel.containsKey(offeringLabel)) {
                offeringsByLabel.put(offeringLabel, new List<apm_outcome_v2__c>());
            }
            offeringsByLabel.get(offeringLabel).add(record);
        }
        
        System.debug('\n🔍 Unique Offerings Found:');
        System.debug('  Total Unique Offerings: ' + offeringsByLabel.size());
        
        for (String offeringLabel : offeringsByLabel.keySet()) {
            List<apm_outcome_v2__c> offeringRecords = offeringsByLabel.get(offeringLabel);
            
            // Calculate aggregated metrics for this offering
            Decimal totalAcv = 0;
            Decimal totalLift = 0;
            Integer recordsWithLift = 0;
            Set<String> segments = new Set<String>();
            Set<String> regions = new Set<String>();
            Set<String> programTypes = new Set<String>();
            
            for (apm_outcome_v2__c record : offeringRecords) {
                if (record.TOTAL_INFLUENCED_ACV__c != null) totalAcv += record.TOTAL_INFLUENCED_ACV__c;
                if (record.CALCULATED_LIFT__c != null) {
                    totalLift += record.CALCULATED_LIFT__c;
                    recordsWithLift++;
                }
                if (record.MACRO_SEGMENT__c != null) segments.add(record.MACRO_SEGMENT__c);
                if (record.REGION__c != null) regions.add(record.REGION__c);
                if (record.PROGRAM_TYPE__c != null) programTypes.add(record.PROGRAM_TYPE__c);
            }
            
            Decimal avgLift = recordsWithLift > 0 ? totalLift / recordsWithLift : 0;
            
            System.debug('\n  • ' + offeringLabel);
            System.debug('    Records: ' + offeringRecords.size());
            System.debug('    Total ACV: ' + formatCurrency(totalAcv));
            System.debug('    Avg Lift: ' + formatPercentage(avgLift));
            System.debug('    Segments: ' + String.join(new List<String>(segments), ', '));
            System.debug('    Regions: ' + String.join(new List<String>(regions), ', '));
            System.debug('    Program Types: ' + String.join(new List<String>(programTypes), ', '));
        }
        
        // ============================================================================
        // PHASE 2: ANALYZE DATA VARIETY
        // ============================================================================
        
        System.debug('\n--- PHASE 2: Data Variety Analysis ---');
        
        if (offeringsByLabel.size() >= 5) {
            System.debug('✅ SUCCESS: Found ' + offeringsByLabel.size() + ' different Data Cloud offerings!');
            System.debug('🎯 This means the aggregation logic should work properly');
        } else if (offeringsByLabel.size() > 1) {
            System.debug('⚠️  PARTIAL: Found ' + offeringsByLabel.size() + ' different Data Cloud offerings');
            System.debug('🎯 Some variety exists, but may need broader search terms');
        } else {
            System.debug('❌ ISSUE: Only found 1 unique Data Cloud offering');
            System.debug('🎯 The data itself may not have enough variety');
        }
        
        // ============================================================================
        // PHASE 3: SUGGEST IMPROVEMENTS
        // ============================================================================
        
        System.debug('\n--- PHASE 3: Suggested Improvements ---');
        
        if (offeringsByLabel.size() < 5) {
            System.debug('🔍 To get more variety, try searching for:');
            System.debug('  • "Data" (broader than "Data Cloud")');
            System.debug('  • "Analytics" (related to data)');
            System.debug('  • "Cloud" (broader cloud offerings)');
            System.debug('  • Specific product names from the data');
        }
        
        System.debug('\n📊 Current Data Summary:');
        System.debug('  • Total Records: ' + records.size());
        System.debug('  • Unique Offerings: ' + offeringsByLabel.size());
        System.debug('  • Data Variety: ' + (offeringsByLabel.size() >= 5 ? 'Good' : 'Limited'));
        
    } else {
        System.debug('❌ No Data Cloud offerings found');
        System.debug('🔍 Try searching for broader terms like "Data" or "Analytics"');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in broad search: ' + e.getMessage());
}

System.debug('\n🧪 BROADER SEARCH TEST COMPLETED');

// Helper methods
private static String formatCurrency(Decimal value) {
    if (value == null) return 'N/A';
    if (value >= 1000000) {
        return '$' + (value / 1000000).setScale(1) + 'M';
    } else if (value >= 1000) {
        return '$' + (value / 1000).setScale(1) + 'K';
    } else {
        return '$' + value.setScale(0);
    }
}

private static String formatPercentage(Decimal value) {
    if (value == null) return 'N/A';
    return (value * 100).setScale(1) + '%';
} 