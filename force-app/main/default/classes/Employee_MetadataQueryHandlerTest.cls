@isTest
private class Employee_MetadataQueryHandlerTest {

    @TestSetup
    static void makeData() {
        List<Learner_Profile__c> testProfiles = new List<Learner_Profile__c>();
        // Create 5 employees in AMER division
        for (Integer i = 0; i < 5; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'AMER User ' + i, Status__c = 'Active', Division__c = 'AMER', Job_Family__c = 'Sales'
            ));
        }
        // Create 5 employees in EMEA division
        for (Integer i = 0; i < 5; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'EMEA User ' + i, Status__c = 'Active', Division__c = 'EMEA', Job_Family__c = 'Support'
            ));
        }
        // Create 3 employees with a null division to ensure they are ignored
        for (Integer i = 0; i < 3; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'No Division User ' + i, Status__c = 'Active', Division__c = null, Job_Family__c = 'Sales'
            ));
        }
        insert testProfiles;
    }

    @isTest
    static void testGetAvailableFields_Success() {
        // Arrange
        Employee_MetadataQueryHandler handler = new Employee_MetadataQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{'METADATA_REQUEST' => 'AVAILABLE_FIELDS'};

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('**Job**'), 'Message should contain field categories.');
        System.assert(result.message.contains('Division'), 'Message should contain field names.');
    }

    @isTest
    static void testGetFieldValues_Success() {
        // Arrange
        Employee_MetadataQueryHandler handler = new Employee_MetadataQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{
            'METADATA_REQUEST' => 'FIELD_VALUES',
            'FIELD_NAME' => 'Division__c'
        };

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);
        
        // Assert
        System.assertEquals(true, result.success);
        System.assertEquals(2, result.totalRecords, 'Should find 2 unique, non-null divisions.');
        System.assert(result.message.contains('AMER'), 'Result message should list the division AMER.');
        System.assert(result.message.contains('EMEA'), 'Result message should list the division EMEA.');
    }

    @isTest
    static void testGetFieldValuesCount_Success() {
        // Arrange
        Employee_MetadataQueryHandler handler = new Employee_MetadataQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{
            'METADATA_REQUEST' => 'FIELD_VALUES_COUNT',
            'FIELD_NAME' => 'Job_Family__c'
        };
        
        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);
        
        // Assert
        System.assertEquals(true, result.success);
        System.assertEquals(2, result.totalRecords, 'Should count 2 unique job families.');
        System.assert(result.message.contains('There are 2 unique values'), 'Should return the correct count message.');
    }

    @isTest
    static void testGetFieldValues_WithPagination() {
        // Arrange
        // Lower the page size to 1 to easily test pagination.
        Employee_MetadataQueryHandler.PAGE_SIZE = 1;

        Employee_MetadataQueryHandler handler = new Employee_MetadataQueryHandler();
        Map<String, Object> queryData = new Map<String, Object>{
            'METADATA_REQUEST' => 'FIELD_VALUES',
            'FIELD_NAME' => 'Division__c'
        };

        // --- Test Page 1 ---
        Employee_QueryRequest page1Request = new Employee_QueryRequest();
        page1Request.pageNumber = 1;
        Employee_QueryResult page1Result = handler.handleQuery(page1Request, queryData);

        // Assert
        System.assertEquals(2, page1Result.totalRecords, 'Total unique records should be 2.');
        System.assertEquals(true, page1Result.hasMore, 'hasMore should be true on page 1.');
        System.assert(page1Result.message.contains('Displaying 1 of 2'), 'Message should show page 1 of 2.');
        
        // --- Test Page 2 ---
        Employee_QueryRequest page2Request = new Employee_QueryRequest();
        page2Request.pageNumber = 2;
        Employee_QueryResult page2Result = handler.handleQuery(page2Request, queryData);

        // Assert
        System.assertEquals(2, page2Result.totalRecords);
        System.assertEquals(false, page2Result.hasMore, 'hasMore should be false on the last page.');
    }
}