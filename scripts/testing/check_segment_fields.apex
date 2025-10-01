/**
 * Check Available Segment-Related Fields in AGENT_OU_PIPELINE_V2__c
 * 
 * This script investigates what segment-related fields are available
 * and what values they contain to support segment-based analysis.
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */

System.debug('🔍 INVESTIGATING SEGMENT-RELATED FIELDS');
System.debug('=====================================');

// Check what segment-related fields exist and their values
List<String> segmentFields = new List<String>{
    'PRIMARY_INDUSTRY__c',
    'OPEN_PIPE_REVISED_SUB_SECTOR_1__c',
    'OPEN_PIPE_REVISED_SUB_SECTOR_2__c',
    'OPEN_PIPE_REVISED_SUB_SECTOR_3__c',
    'OPEN_PIPE_REVISED_SUB_SECTOR_4__c',
    'OPEN_PIPE_REVISED_SUB_SECTOR_5__c'
};

for (String fieldName : segmentFields) {
    System.debug('\n--- Checking ' + fieldName + ' ---');
    
    try {
        // Get distinct values for this field
        String query = 'SELECT ' + fieldName + ', COUNT(Id) recordCount ' +
                      'FROM AGENT_OU_PIPELINE_V2__c ' +
                      'WHERE IsDeleted = false ' +
                      'AND ' + fieldName + ' != null ' +
                      'GROUP BY ' + fieldName + ' ' +
                      'ORDER BY COUNT(Id) DESC ' +
                      'LIMIT 10';
        
        List<AggregateResult> results = Database.query(query);
        
        System.debug('📊 Top 10 values for ' + fieldName + ':');
        for (AggregateResult result : results) {
            String value = (String) result.get(fieldName);
            Integer count = (Integer) result.get('recordCount');
            System.debug('  • ' + value + ': ' + count + ' records');
        }
        
        // Get total count of non-null values
        String countQuery = 'SELECT COUNT(Id) totalCount, COUNT(' + fieldName + ') nonNullCount ' +
                           'FROM AGENT_OU_PIPELINE_V2__c ' +
                           'WHERE IsDeleted = false';
        
        List<AggregateResult> countResults = Database.query(countQuery);
        for (AggregateResult countResult : countResults) {
            Integer totalCount = (Integer) countResult.get('totalCount');
            Integer nonNullCount = (Integer) countResult.get('nonNullCount');
            Decimal percentage = totalCount > 0 ? (nonNullCount * 100.0 / totalCount) : 0;
            
            System.debug('  📈 Coverage: ' + nonNullCount + '/' + totalCount + ' (' + percentage.setScale(1) + '%)');
        }
        
    } catch (Exception e) {
        System.debug('❌ ERROR checking ' + fieldName + ': ' + e.getMessage());
    }
}

// Check for any other potential segment fields
System.debug('\n--- Checking for Other Segment-Related Fields ---');

try {
    // Get a sample record to see what fields are available
    String sampleQuery = 'SELECT Id, PRIMARY_INDUSTRY__c, ' +
                        'OPEN_PIPE_REVISED_SUB_SECTOR_1__c, ' +
                        'OPEN_PIPE_REVISED_SUB_SECTOR_2__c, ' +
                        'OPEN_PIPE_REVISED_SUB_SECTOR_3__c, ' +
                        'OPEN_PIPE_REVISED_SUB_SECTOR_4__c, ' +
                        'OPEN_PIPE_REVISED_SUB_SECTOR_5__c ' +
                        'FROM AGENT_OU_PIPELINE_V2__c ' +
                        'WHERE IsDeleted = false ' +
                        'AND OU_NAME__c = \'AMER ACC\' ' +
                        'LIMIT 5';
    
    List<AGENT_OU_PIPELINE_V2__c> sampleRecords = Database.query(sampleQuery);
    
    System.debug('📋 Sample records for AMER ACC:');
    for (AGENT_OU_PIPELINE_V2__c record : sampleRecords) {
        System.debug('  Record ID: ' + record.Id);
        System.debug('    PRIMARY_INDUSTRY__c: ' + record.PRIMARY_INDUSTRY__c);
        System.debug('    SUB_SECTOR_1__c: ' + record.OPEN_PIPE_REVISED_SUB_SECTOR_1__c);
        System.debug('    SUB_SECTOR_2__c: ' + record.OPEN_PIPE_REVISED_SUB_SECTOR_2__c);
        System.debug('    SUB_SECTOR_3__c: ' + record.OPEN_PIPE_REVISED_SUB_SECTOR_3__c);
        System.debug('    SUB_SECTOR_4__c: ' + record.OPEN_PIPE_REVISED_SUB_SECTOR_4__c);
        System.debug('    SUB_SECTOR_5__c: ' + record.OPEN_PIPE_REVISED_SUB_SECTOR_5__c);
        System.debug('  ---');
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR getting sample records: ' + e.getMessage());
}

System.debug('\n--- RECOMMENDATIONS ---');
System.debug('Based on the available fields, here are the options for segment-based analysis:');
System.debug('1. PRIMARY_INDUSTRY__c - Top-level industry classification');
System.debug('2. OPEN_PIPE_REVISED_SUB_SECTOR_1__c through 5__c - Detailed sub-sectors');
System.debug('3. Consider adding support for these fields in the KPI analysis service');

System.debug('\n✅ Segment Field Investigation Complete!');
