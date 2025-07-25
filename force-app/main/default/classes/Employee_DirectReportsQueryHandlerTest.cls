@isTest
private class Employee_DirectReportsQueryHandlerTest {

    @TestSetup
    static void makeData() {
        // Create a 3-level hierarchy: VP -> Director -> Manager
        Learner_Profile__c vp = new Learner_Profile__c(
            Name = 'VP, Vivian', Primary_Email__c = 'vivian.vp@example.com', Status__c = 'Active', Division__c = 'AMER'
        );
        insert vp; // Insert separately to get ID

        Learner_Profile__c director = new Learner_Profile__c(
            Name = 'Director, David', Primary_Email__c = 'david.director@example.com', Status__c = 'Active', Division__c = 'AMER',
            Manager__c = vp.Name, Manager_Email__c = vp.Primary_Email__c
        );
        insert director; // Insert separately to get ID

        Learner_Profile__c manager = new Learner_Profile__c(
            Name = 'Manager, Mary', Primary_Email__c = 'mary.manager@example.com', Status__c = 'Active', Division__c = 'AMER',
            Job_Family__c = 'Management', Manager__c = director.Name, Manager_Email__c = director.Primary_Email__c
        );

        // Add a second direct report to the Director to test filtering
        Learner_Profile__c engineer = new Learner_Profile__c(
            Name = 'Engineer, Ed', Primary_Email__c = 'ed.engineer@example.com', Status__c = 'Active', Division__c = 'AMER',
            Job_Family__c = 'Engineer', Manager__c = director.Name, Manager_Email__c = director.Primary_Email__c
        );
        
        insert new List<Learner_Profile__c>{manager, engineer};
    }

    @isTest
    static void testQueryDirectReports_Success() {
        // Arrange: Query for the direct reports of the Director.
        // Should return the Manager and the Engineer (2 total).
        Employee_DirectReportsQueryHandler handler = new Employee_DirectReportsQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{'DIRECT_REPORTS' => 'Director, David'};

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success, 'Query should be successful.');
        System.assertEquals(2, result.totalRecords, 'Should find 2 direct reports for the Director.');
        System.assertEquals(2, result.records.size());
    }
    
    @isTest
    static void testQueryDirectReports_WithAdditionalFilter() {
        // Arrange: Query for the Director's reports who are in the "Engineer" job family.
        Employee_DirectReportsQueryHandler handler = new Employee_DirectReportsQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{
            'DIRECT_REPORTS' => 'Director, David',
            'Job_Family__c' => 'Engineer'
        };

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success);
        System.assertEquals(1, result.totalRecords, 'Should find only 1 report matching the filter.');
        System.assertEquals('Engineer, Ed', result.records[0].name, 'The found report should be the engineer.');
    }
    
    @isTest
    static void testQueryForManager_WithNoDirectReports() {
        // Arrange: Query for the reports of "Manager, Mary", who has none.
        Employee_DirectReportsQueryHandler handler = new Employee_DirectReportsQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{'DIRECT_REPORTS' => 'Manager, Mary'};

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);
        
        // Assert
        System.assertEquals(true, result.success, 'A query for no reports should still be successful.');
        System.assertEquals(0, result.totalRecords, 'Should find 0 direct reports.');
    }
}