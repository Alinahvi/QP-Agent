@isTest
private class TrainingMetadataHandlerTest {

    @TestSetup
    static void makeData() {
        // Create sample courses for testing
        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Alpha Course', Status__c = 'Active'),
            new Course__c(Name = 'Bravo Course', Status__c = 'Active'),
            new Course__c(Name = 'Charlie Course (Inactive)', Status__c = 'Inactive')
        };
        insert courses;
    }

    @isTest
    static void testGetAvailableCourses() {
        // Arrange
        TrainingMetadataQueryHandler handler = new TrainingMetadataQueryHandler();
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.METADATA_REQUEST_TYPE = 'AVAILABLE_COURSES';

        // Act
        String result = handler.process(request);

        // Assert
        System.assert(result.contains('Alpha Course'), 'Result should list active courses.');
        System.assert(result.contains('Bravo Course'), 'Result should list active courses.');
        System.assert(!result.contains('Charlie Course'), 'Result should NOT list inactive courses.');
    }

    @isTest
    static void testGetFieldValues_Success() {
        // Arrange: Test getting picklist values from a standard object for simplicity.
        // The logic is dynamic and will work for custom objects too.
        TrainingMetadataQueryHandler handler = new TrainingMetadataQueryHandler();
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.METADATA_REQUEST_TYPE = 'FIELD_VALUES';
        request.TARGET_OBJECT_API_NAME = 'Account';
        request.TARGET_FIELD_API_NAME = 'Industry'; // A standard picklist field

        // Act
        String result = handler.process(request);

        // Assert
        System.assert(result.contains('Possible values for Industry'), 'The response intro should be correct.');
        System.assert(result.contains('Agriculture'), 'Should contain standard industry picklist values.');
        System.assert(result.contains('Banking'), 'Should contain standard industry picklist values.');
    }

    @isTest
    static void testGetFieldValues_InvalidField() {
        // Arrange
        TrainingMetadataQueryHandler handler = new TrainingMetadataQueryHandler();
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.METADATA_REQUEST_TYPE = 'FIELD_VALUES';
        request.TARGET_OBJECT_API_NAME = 'Account';
        request.TARGET_FIELD_API_NAME = 'NonExistentField__c';

        // Act
        String result = handler.process(request);
        
        // Assert
        System.assert(result.contains('could not find a field named'), 'Should return a clear error for an invalid field.');
    }
}