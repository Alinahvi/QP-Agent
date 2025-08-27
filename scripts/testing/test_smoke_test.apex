System.debug('Testing Test Data Factory...');

try {
    // Test basic seeding
    ANAgentTestDataFactory.SeedOptions opt = new ANAgentTestDataFactory.SeedOptions(5);
    List<AGENT_OU_PIPELINE_V2__c> records = ANAgentTestDataFactory.seedKPIs(opt);
    
    System.debug('Created ' + records.size() + ' records');
    System.debug('First record: ' + records[0]);
    
    // Test single record creation
    AGENT_OU_PIPELINE_V2__c singleRecord = ANAgentTestDataFactory.createTestRecord('US', 'TEST_OU', 12, 50000, 8);
    System.debug('Single record: ' + singleRecord);
    
    // Test comparison data
    List<AGENT_OU_PIPELINE_V2__c> comparisonRecords = ANAgentTestDataFactory.createComparisonTestData('US', 'Brazil', 3);
    System.debug('Comparison records: ' + comparisonRecords.size());
    
    System.debug('Test completed successfully!');
    
} catch (Exception e) {
    System.debug('Test failed with error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 