@isTest
private class Employee_HierarchicalQueryHandlerTest {

    @TestSetup
    static void makeData() {
        // Create a 3-level hierarchy: Manager -> Director -> VP
        Learner_Profile__c vp = new Learner_Profile__c(
            Name = 'VP, Vivian',
            Primary_Email__c = 'vivian.vp@example.com',
            Status__c = 'Active',
            Job_Family__c = 'Executive',
            Division__c = 'AMER'
        );
        // A VP has no one above them in this hierarchy
        
        Learner_Profile__c director = new Learner_Profile__c(
            Name = 'Director, David',
            Primary_Email__c = 'david.director@example.com',
            Status__c = 'Active',
            Job_Family__c = 'Management',
            Division__c = 'AMER',
            Manager__c = 'VP, Vivian',
            Emp_Mgt_Chain_Lvl_01_Nm__c = 'vivian.vp@example.com' // Reports to VP
        );
        
        Learner_Profile__c manager = new Learner_Profile__c(
            Name = 'Manager, Mary',
            Primary_Email__c = 'mary.manager@example.com',
            Status__c = 'Active',
            Job_Family__c = 'Management',
            Division__c = 'AMER',
            Manager__c = 'Director, David',
            Emp_Mgt_Chain_Lvl_01_Nm__c = 'david.director@example.com', // Reports to Director
            Emp_Mgt_Chain_Lvl_02_Nm__c = 'vivian.vp@example.com'      // Who reports to VP
        );
        
        // Create another employee who is NOT in this org chain
        Learner_Profile__c otherEmployee = new Learner_Profile__c(
            Name = 'Other, Otto',
            Primary_Email__c = 'otto.other@example.com',
            Status__c = 'Active',
            Job_Family__c = 'Engineer',
            Division__c = 'EMEA'
        );

        insert new List<Learner_Profile__c>{vp, director, manager, otherEmployee};
    }

    @isTest
    static void testQueryForMidLevelOrg() {
        // Arrange: Query for the organization of the Director.
        // This should return the Director and their report (the Manager), but not the VP.
        Employee_HierarchicalQueryHandler handler = new Employee_HierarchicalQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{'HIERARCHICAL_QUERY' => 'Director, David'};

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success, 'Query should be successful.');
        // The result should contain the Director himself, plus the Manager who reports to him.
        System.assertEquals(2, result.totalRecords, 'Should find 2 employees in the Director\'s org.');
    }
    
    @isTest
    static void testQueryWithAdditionalFilter() {
        // Arrange: Query for the VP's entire org, but only those in the "Management" job family.
        // This should find the Director and the Manager, but not the VP (Executive).
        Employee_HierarchicalQueryHandler handler = new Employee_HierarchicalQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{
            'HIERARCHICAL_QUERY' => 'VP, Vivian',
            'Job_Family__c' => 'Management'
        };

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success);
        System.assertEquals(2, result.totalRecords, 'Should find 2 "Management" employees in the VP\'s org.');
    }
    
    @isTest
    static void testQueryForNonexistentManager() {
        // Arrange
        Employee_HierarchicalQueryHandler handler = new Employee_HierarchicalQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{'HIERARCHICAL_QUERY' => 'Unknown, Bob'};

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);
        
        // Assert
        System.assertEquals(false, result.success, 'Query should fail cleanly for a nonexistent manager.');
        System.assert(result.message.contains('Could not find a manager'), 'Should return a clear error message.');
    }
}