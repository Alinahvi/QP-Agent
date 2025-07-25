@isTest
private class TrainingQueryBuilderTest {

    @TestSetup
    static void makeData() {
        insert new Course__c(Name = 'Test Course', Status__c = 'Active');
    }

    @isTest
    static void testBuildSimpleQuery() {
        // Arrange
        TrainingQueryBuilder qb = new TrainingQueryBuilder(new TrainingQueryRequest());
        qb.selectFrom('Course__c')
          .addSelectField('Id')
          .addSelectField('Name')
          .addWhereCondition('Status__c = :status', 'status', 'Active')
          .setLimit(1);
        
        // Act
        String resultSoql = qb.buildSOQLString();
        
        // Assert
        System.assert(resultSoql.contains('SELECT Id, Name'), 'Should contain correct SELECT fields.');
        System.assert(resultSoql.contains('FROM Course__c'), 'Should contain correct FROM object.');
        System.assert(resultSoql.contains('WHERE Status__c = :status'), 'Should contain correct WHERE clause.');
        System.assert(resultSoql.endsWith('LIMIT 1'), 'Should contain correct LIMIT clause.');
    }

    @isTest
    static void testExecuteQuery_RunsSuccessfully() {
        // Arrange
        TrainingQueryBuilder qb = new TrainingQueryBuilder(new TrainingQueryRequest());
        qb.selectFrom('Course__c')
          .addSelectField('Name')
          .addWhereCondition('Name = :name', 'name', 'Test Course');
        
        // Act
        Test.startTest();
        List<SObject> results = qb.executeQuery();
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, results.size(), 'Should successfully query and return one record.');
    }
}