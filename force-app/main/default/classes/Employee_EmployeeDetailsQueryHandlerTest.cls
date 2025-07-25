@isTest
private class Employee_EmployeeDetailsQueryHandlerTest {

    @TestSetup
    static void makeData() {
        List<Learner_Profile__c> testProfiles = new List<Learner_Profile__c>{
            new Learner_Profile__c(
                Name = 'Smith, John', Status__c = 'Active', Division__c = 'AMER'
            ),
            new Learner_Profile__c(
                Name = 'Smith, Jane', Status__c = 'Active', Division__c = 'EMEA'
            ),
            new Learner_Profile__c(
                Name = 'Jones, David', Status__c = 'Active', Division__c = 'AMER'
            )
        };
        insert testProfiles;
    }

    @isTest
    static void testQueryForSingleEmployee_Success() {
        // Arrange
        Employee_EmployeeDetailsQueryHandler handler = new Employee_EmployeeDetailsQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{'EMPLOYEE_NAME' => 'Jones, David'};

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success, 'Query should be successful.');
        System.assertEquals(1, result.totalRecords, 'Should find exactly one employee.');
        System.assertEquals(1, result.records.size());
        System.assert(result.message.contains('Details for: Jones, David'), 'Message should show the employee details.');
    }

    @isTest
    static void testQuery_AmbiguousNameReturnsClarification() {
        // Arrange: "Smith" will match both "Smith, John" and "Smith, Jane"
        Employee_EmployeeDetailsQueryHandler handler = new Employee_EmployeeDetailsQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{'EMPLOYEE_NAME' => 'Smith'};

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success, 'Query should be successful.');
        System.assertEquals(2, result.totalRecords, 'Should find two matching employees.');
        System.assert(result.message.contains('Found multiple people'), 'Should return the ambiguous name message.');
    }
    
    @isTest
    static void testQuery_NonexistentEmployee() {
        // Arrange
        Employee_EmployeeDetailsQueryHandler handler = new Employee_EmployeeDetailsQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{'EMPLOYEE_NAME' => 'Unknown, Bob'};

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(false, result.success, 'Query should fail for a nonexistent employee.');
        System.assertEquals(0, result.totalRecords);
        System.assert(result.message.contains('could not find an employee'), 'Should return a clear error message.');
    }
}