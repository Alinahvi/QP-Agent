@isTest
private class TrainingHierarchicalQueryHandlerTest {

    @TestSetup
    static void makeData() {
        // Create a 2-level hierarchy: VP -> Manager
        Learner_Profile__c vp = new Learner_Profile__c(
            Name = 'Vivian VP', Status__c = 'Active', Primary_Email__c = 'vivian.vp@example.com'
        );
        insert vp;

        Learner_Profile__c manager = new Learner_Profile__c(
            Name = 'David Director', Status__c = 'Active', Manager__c = 'Vivian VP',
            Emp_Mgt_Chain_Lvl_01_Nm__c = 'vivian.vp@example.com'
        );
        insert manager;

        // Create a course
        Course__c course = new Course__c(Name = 'Leadership 101');
        insert course;

        // Assign the course to the Manager, but not the VP
        Assigned_Course__c assignment = new Assigned_Course__c(
            Learner_Profile__c = manager.Id,
            Course__c = course.Id,
            Completed__c = true,
            Inactive__c = false
        );
        insert assignment;
    }

    @isTest
    static void testOrgQuery_WithCompletionFilter() {
        // Arrange: Find who in Vivian VP's organization has completed "Leadership 101"
        // This should only find David Director.
        TrainingHierarchicalQueryHandler handler = new TrainingHierarchicalQueryHandler();
        
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.HIERARCHY_CONTEXT = new TrainingQueryRequest.HierarchyContext();
        request.HIERARCHY_CONTEXT.TYPE = 'ORGANIZATION_MEMBERS';
        request.HIERARCHY_CONTEXT.ANCHOR_NAME = 'Vivian VP';
        
        request.FILTERS = new TrainingQueryRequest.Filters();
        request.FILTERS.Training_Name = 'Leadership';
        request.FILTERS.Completion_Status = 'COMPLETED';
        
        request.RESPONSE_CRITERIA = new TrainingQueryRequest.ResponseCriteria();
        request.RESPONSE_CRITERIA.RETURN_FIELDS = new List<String>{'Learner_Profile__r.Name'};

        // Act
        String result = handler.process(request);

        // Assert
        System.assert(result.contains('David Director'), 'Result should contain the direct report who completed the course.');
        System.assert(!result.contains('Vivian VP'), 'Result should not contain the VP, who was not assigned the course.');
    }
}