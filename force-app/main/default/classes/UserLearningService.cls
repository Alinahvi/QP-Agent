public with sharing class UserLearningService {

    public class GetLearningRequest {
        @InvocableVariable(label='Target User ID' description='ID of the user to query. If blank, defaults to the current user.')
        public Id targetUserId;
    }

    public class GetLearningResponse {
        @InvocableVariable(label='Assigned Learnings')
        public List<AssignedLearningResult> assignedLearnings;
    }

    @InvocableMethod(label='Get Open Assigned Learning for User' description='Fetches active, uncompleted assigned learning for a specified user, or the current user if none is specified.')
    public static List<GetLearningResponse> getOpenAssignedLearning(List<GetLearningRequest> requests) {
        
        Id userToQuery = (requests != null && !requests.isEmpty() && requests[0].targetUserId != null)
            ? requests[0].targetUserId
            : UserInfo.getUserId();

        List<AssignedLearningResult> results = new List<AssignedLearningResult>();
        GetLearningResponse response = new GetLearningResponse();
        
        List<Learner_Profile__c> lpList = [SELECT Id FROM Learner_Profile__c WHERE User__c = :userToQuery AND Status__c = 'Active' LIMIT 1];
        
        if (lpList.isEmpty()) {
            response.assignedLearnings = results;
            return new List<GetLearningResponse>{response};
        }
        
        Id learnerProfileId = lpList[0].Id;

        // 1. Query for open Assigned Curriculums with corrected formula field
        for (Assigned_Curriculum__c ac : [
            SELECT Id, Curriculum__r.Name, Self_Assigned__c, Content_Distribution_Organization__c 
            FROM Assigned_Curriculum__c 
            WHERE Learner_Profile__c = :learnerProfileId 
              AND Inactive__c = false 
              AND Completed__c = false
            WITH USER_MODE
        ]) {
            AssignedLearningResult res = new AssignedLearningResult();
            res.assignedLearningId = ac.Id;
            res.learningName = ac.Curriculum__r.Name;
            res.learningType = 'Curriculum';
            res.isSelfAssigned = ac.Self_Assigned__c;
            res.requiredBy = ac.Content_Distribution_Organization__c;
            results.add(res);
        }

        // 2. Query for open Assigned Courses with corrected formula field
        for (Assigned_Course__c ac : [
            SELECT Id, Course__r.Name, Self_Assigned__c, Content_Distribution_Organization__c 
            FROM Assigned_Course__c 
            WHERE Learner_Profile__c = :learnerProfileId 
              AND Inactive__c = false 
              AND Completed__c = false
              AND Assigned_Curriculum__c = null
            WITH USER_MODE
        ]) {
            AssignedLearningResult res = new AssignedLearningResult();
            res.assignedLearningId = ac.Id;
            res.learningName = ac.Course__r.Name;
            res.learningType = 'Course';
            res.isSelfAssigned = ac.Self_Assigned__c;
            res.requiredBy = ac.Content_Distribution_Organization__c;
            results.add(res);
        }

        // 3. Query for open, standalone Event Assignments with corrected formula field
        for (Assignment__c a : [
            SELECT Id, Asset__r.Name, Self_Assigned__c, Content_Distribution_Organization__c
            FROM Assignment__c 
            WHERE Learner_Profile__c = :learnerProfileId 
              AND Inactive__c = false 
              AND Completed__c = false 
              AND Assigned_Curriculum__c = null
              AND Assigned_Course__c = null
              AND Asset__r.RecordType.DeveloperName = 'Event'
            WITH USER_MODE
        ]) {
            AssignedLearningResult res = new AssignedLearningResult();
            res.assignedLearningId = a.Id;
            res.learningName = a.Asset__r.Name;
            res.learningType = 'Event';
            res.isSelfAssigned = a.Self_Assigned__c;
            res.requiredBy = a.Content_Distribution_Organization__c;
            results.add(res);
        }

        response.assignedLearnings = results;
        return new List<GetLearningResponse>{response};
    }
}