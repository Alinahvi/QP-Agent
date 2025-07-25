@isTest
private class TrainingUnenrollmentHandlerTest {

    @TestSetup
    static void makeData() {
        Learner_Profile__c unenrolledUser = new Learner_Profile__c(Name = 'Unenrolled User', Status__c = 'Active');
        Learner_Profile__c activeUser = new Learner_Profile__c(Name = 'Active User', Status__c = 'Active');
        insert new List<Learner_Profile__c>{unenrolledUser, activeUser};

        Course__c course = new Course__c(Name = 'Sales Methodology');
        insert course;

        List<Assigned_Course__c> assignments = new List<Assigned_Course__c>{
            // An unenrolled (inactive) assignment
            new Assigned_Course__c(
                Learner_Profile__c = unenrolledUser.Id, Course__c = course.Id, Inactive__c = true
            ),
            // An active assignment that should be ignored by this handler
            new Assigned_Course__c(
                Learner_Profile__c = activeUser.Id, Course__c = course.Id, Inactive__c = false
            )
        };
        insert assignments;
    }

    @isTest
    static void testUnenrollmentQuery_FindsCorrectUser() {
        // Arrange
        TrainingUnenrollmentListHandler handler = new TrainingUnenrollmentListHandler();
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.FILTERS = new TrainingQueryRequest.Filters();
        request.FILTERS.Training_Name = 'Sales Methodology';
        request.RESPONSE_CRITERIA = new TrainingQueryRequest.ResponseCriteria();

        // Act
        String result = handler.process(request);

        // Assert
        System.assert(result.contains('Unenrolled User'), 'Result should list the user who unenrolled.');
        System.assert(!result.contains('Active User'), 'Result should NOT list the user who is still active.');
        System.assertEquals(1, request.RESPONSE_CRITERIA.totalRecords, 'Total records count should be 1.');
    }
}