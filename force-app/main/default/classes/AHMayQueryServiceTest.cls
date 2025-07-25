@isTest
private class AHMayQueryServiceTest {
    @TestSetup
    static void setupTestData() {
        // Create test users and learner profiles
        List<Learner_Profile__c> testProfiles = new List<Learner_Profile__c>();
        
        // Create employees with various attributes
        testProfiles.add(new Learner_Profile__c(
            Name = 'John Doe',
            Primary_Email__c = 'john.doe@test.com',
            Manager__c = 'Jane Smith',
            Manager_Email__c = 'jane.smith@test.com',
            Division__c = 'AMER',
            Job_Family__c = 'Engineer',
            Employee_Location__c = 'New York',
            FTE__c = true,
            Commissionable__c = false,
            Status__c = 'Active',
            Hire_Date__c = Date.today().addYears(-1),
            Work_Location_Country__c = 'United States',
            Seller_Group__c = 'Prime AE',
            Macro_Segment__c = 'ENTR',
            em_Industry__c = 'Technology'
        ));
        
        // Add more test profiles with different attributes
        insert testProfiles;
    }
    
    @isTest
    static void testStandardQuery() {
        Test.startTest();
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.userInput = 'Show me employees in AMER division';
        request.pageNumber = 1;
        
        List<String> results = AHMayQueryEmployees.queryEmployees(new List<AHMayQueryRequest>{request});
        Test.stopTest();
        
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        
        AHMayQueryResult result = (AHMayQueryResult)JSON.deserialize(results[0], AHMayQueryResult.class);
        System.assertEquals(true, result.success);
        System.assertNotEquals(null, result.records);
    }
    
    @isTest
    static void testHierarchicalQuery() {
        Test.startTest();
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.userInput = 'Show me everyone in Jane Smith\'s organization';
        request.pageNumber = 1;
        
        List<String> results = AHMayQueryEmployees.queryEmployees(new List<AHMayQueryRequest>{request});
        Test.stopTest();
        
        System.assertNotEquals(null, results);
        AHMayQueryResult result = (AHMayQueryResult)JSON.deserialize(results[0], AHMayQueryResult.class);
        System.assertEquals(true, result.success);
    }
    
    @isTest
    static void testDirectReportsQuery() {
        Test.startTest();
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.userInput = 'Who reports to Jane Smith?';
        request.pageNumber = 1;
        
        List<String> results = AHMayQueryEmployees.queryEmployees(new List<AHMayQueryRequest>{request});
        Test.stopTest();
        
        System.assertNotEquals(null, results);
        AHMayQueryResult result = (AHMayQueryResult)JSON.deserialize(results[0], AHMayQueryResult.class);
        System.assertEquals(true, result.success);
    }
    
    @isTest
    static void testDateRangeQuery() {
        Test.startTest();
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.userInput = 'Show me employees hired in the last year';
        request.pageNumber = 1;
        
        List<String> results = AHMayQueryEmployees.queryEmployees(new List<AHMayQueryRequest>{request});
        Test.stopTest();
        
        System.assertNotEquals(null, results);
        AHMayQueryResult result = (AHMayQueryResult)JSON.deserialize(results[0], AHMayQueryResult.class);
        System.assertEquals(true, result.success);
    }
    
    @isTest
    static void testAggregationQuery() {
        Test.startTest();
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.userInput = 'Show me employees in AMER grouped by job family';
        request.pageNumber = 1;
        
        List<String> results = AHMayQueryEmployees.queryEmployees(new List<AHMayQueryRequest>{request});
        Test.stopTest();
        
        System.assertNotEquals(null, results);
        AHMayQueryResult result = (AHMayQueryResult)JSON.deserialize(results[0], AHMayQueryResult.class);
        System.assertEquals(true, result.success);
    }
    
    @isTest
    static void testMetadataQuery() {
        Test.startTest();
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.userInput = 'What employee fields do you have?';
        
        List<String> results = AHMayQueryEmployees.queryEmployees(new List<AHMayQueryRequest>{request});
        Test.stopTest();
        
        System.assertNotEquals(null, results);
        AHMayQueryResult result = (AHMayQueryResult)JSON.deserialize(results[0], AHMayQueryResult.class);
        System.assertEquals(true, result.success);
    }
    
    @isTest
    static void testFieldValuesQuery() {
        Test.startTest();
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.userInput = 'What are the possible values for Division?';
        
        List<String> results = AHMayQueryEmployees.queryEmployees(new List<AHMayQueryRequest>{request});
        Test.stopTest();
        
        System.assertNotEquals(null, results);
        AHMayQueryResult result = (AHMayQueryResult)JSON.deserialize(results[0], AHMayQueryResult.class);
        System.assertEquals(true, result.success);
    }
    
    @isTest
    static void testPaginationRequest() {
        Test.startTest();
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.userInput = 'Show me employees in AMER division';
        request.pageNumber = 2;
        
        List<String> results = AHMayQueryEmployees.queryEmployees(new List<AHMayQueryRequest>{request});
        Test.stopTest();
        
        System.assertNotEquals(null, results);
        AHMayQueryResult result = (AHMayQueryResult)JSON.deserialize(results[0], AHMayQueryResult.class);
        System.assertEquals(true, result.success);
        System.assertEquals(2, result.pageNumber);
    }
    
    @isTest
    static void testErrorHandling() {
        Test.startTest();
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.userInput = ''; // Empty query should trigger error handling
        
        List<String> results = AHMayQueryEmployees.queryEmployees(new List<AHMayQueryRequest>{request});
        Test.stopTest();
        
        System.assertNotEquals(null, results);
        AHMayQueryResult result = (AHMayQueryResult)JSON.deserialize(results[0], AHMayQueryResult.class);
        System.assertEquals(false, result.success);
    }
}