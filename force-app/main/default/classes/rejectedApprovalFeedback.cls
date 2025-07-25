public with sharing class rejectedApprovalFeedback {
     public String sourceId{get;set;}
     
     public String getRejectedFeedback(){
         String rejectedComments = 'No Comments';
         List<ProcessInstanceStep> rejectedSteps = [SELECT Id, Comments 
                                                    FROM ProcessInstanceStep 
                                                    WHERE ProcessInstance.TargetObjectId =: sourceId 
                                                    AND StepStatus = 'Rejected'
                                                    ORDER BY CreatedDate DESC
                                                    LIMIT 1];
        
        if(!rejectedSteps.isEmpty()){
            rejectedComments = rejectedSteps.get(0).Comments;
        }
        
        return rejectedComments;
     }
}