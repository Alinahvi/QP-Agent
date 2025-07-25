@isTest
private class TrainingIndividualQueryHandlerTest {

    private static Learner_Profile__c testLearner;
    private static Course__c completedCourse;
    private static Course__c pendingCourse;
    private static Course__c unenrolledCourse;

    @TestSetup
    static void makeData() {
        testLearner = new Learner_Profile__c(Name = 'Jane Doe', Status__c = 'Active');
        insert testLearner;

        completedCourse = new Course__c(Name = 'Completed Course 101');
        pendingCourse = new Course__c(Name = 'Pending Course 202');
        unenrolledCourse = new Course__c(Name = 'History Course 303');
        insert new List<Course__c>{completedCourse, pendingCourse, unenrolledCourse};

        List<Assigned_Course__c> assignments = new List<Assigned_Course__c>{
            // Completed
            new Assigned_Course__c(Learner_Profile__c = testLearner.Id, Course__c = completedCourse.Id, Completed__c = true, Inactive__c = false),
            // Pending
            new Assigned_Course__c(Learner_Profile__c = testLearner.Id, Course__c = pendingCourse.Id, Completed__c = false, Inactive__c = false),
            // Unenrolled (Inactive)
            new Assigned_Course__c(Learner_Profile__c = testLearner.Id, Course__c = unenrolledCourse.Id, Completed__c = false, Inactive__c = true)
        };
        insert assignments;
    }

    @isTest
    static void testGetPendingAssignments() {
        // Arrange
        TrainingIndividualLearnerQueryHandler handler = new TrainingIndividualLearnerQueryHandler();
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.AGENT_ACTION = 'GET_INDIVIDUAL_ASSIGNED_TRAINING';
        request.LEARNER_CONTEXT = new TrainingQueryRequest.LearnerContext();
        request.LEARNER_CONTEXT.LEARNER_NAME = 'Jane Doe';
        request.FILTERS = new TrainingQueryRequest.Filters();
        request.FILTERS.Assignment_Status_Category = 'ACTIVE_PENDING';
        request.RESPONSE_CRITERIA = new TrainingQueryRequest.ResponseCriteria();
        request.RESPONSE_CRITERIA.RETURN_FIELDS = new List<String>{'Course__r.Name'};

        // Act
        String result = handler.process(request);

        // Assert
        System.assert(result.contains('Pending Course 202'), 'Result should list the pending course.');
        System.assert(!result.contains('Completed Course 101'), 'Result should NOT list the completed course.');
    }

    @isTest
    static void testCheckSpecificAssignmentStatus() {
        // Arrange
        TrainingIndividualLearnerQueryHandler handler = new TrainingIndividualLearnerQueryHandler();
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.AGENT_ACTION = 'CHECK_INDIVIDUAL_TRAINING_STATUS';
        request.LEARNER_CONTEXT = new TrainingQueryRequest.LearnerContext();
        request.LEARNER_CONTEXT.LEARNER_NAME = 'Jane Doe';
        request.FILTERS = new TrainingQueryRequest.Filters();
        request.FILTERS.Training_Name = 'Completed Course';

        // Act
        String result = handler.process(request);

        // Assert
        System.assert(result.contains('has completed'), 'Should return that the user has completed the course.');
    }
    
    @isTest
    static void testCheckUnenrollmentStatus() {
        // Arrange
        TrainingIndividualLearnerQueryHandler handler = new TrainingIndividualLearnerQueryHandler();
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.AGENT_ACTION = 'CHECK_INDIVIDUAL_UNENROLLMENT';
        request.LEARNER_CONTEXT = new TrainingQueryRequest.LearnerContext();
        request.LEARNER_CONTEXT.LEARNER_NAME = 'Jane Doe';
        request.FILTERS = new TrainingQueryRequest.Filters();
        request.FILTERS.Training_Name = 'History Course';

        // Act
        String result = handler.process(request);

        // Assert
        System.assert(result.contains('Yes'), 'Should confirm that the user has unenrolled.');
    }
}