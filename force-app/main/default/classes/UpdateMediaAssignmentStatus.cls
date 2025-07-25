public with sharing class UpdateMediaAssignmentStatus {
    
    public static void updateMediaStatus(Map<Id, scormanywhere__Transcript__c> transcriptId) {
        Set<String> completedMediaList = new Set<String>();
        for(scormanywhere__Transcript__c newData : transcriptId.values()) {
            if(!newData.scormanywhere__Test_Launch__c) {
                if(newData.scormanywhere__SCORM_Satisfied_Status__c && newData.scormanywhere__SCORM_Progress_Status__c) {
                    String mediaKey = String.valueOf(newData.scormanywhere__Course__c).substring(0, 15) + '-' + String.valueOf(newData.scormanywhere__User__c).substring(0, 15);
                    completedMediaList.add(mediaKey);
                } else if(!newData.scormanywhere__SCORM_Satisfied_Status__c && !newData.scormanywhere__SCORM_Progress_Status__c && 
                    newData.scormanywhere__SCORM_Attempt_Completion_Status__c && newData.scormanywhere__SCORM_Attempt_Progress_Status__c) {
                    String mediaKey = String.valueOf(newData.scormanywhere__Course__c).substring(0, 15) + '-' + String.valueOf(newData.scormanywhere__User__c).substring(0, 15);
                    completedMediaList.add(mediaKey);
                }
            }                
        }  

        if(!completedMediaList.isEmpty()) {
            setMediaAssignmentToComplete(completedMediaList);
        }
    }

    public static void setMediaAssignmentToComplete(Set<String> mediaKey) {
        List<Assignment__c> assignmentToUpdate = new List<Assignment__c>();
        for(Assignment__c data : [SELECT Id, Completed__c 
                                    FROM Assignment__c 
                                    WHERE Media_Key__c IN: mediaKey 
                                    AND Completed__c != true
                                    WITH USER_MODE]) {
            data.Completed__c = true;
            assignmentToUpdate.add(data);            
        }
        if(!assignmentToUpdate.isEmpty()) {
            try {
                update as user assignmentToUpdate;                
            } catch(Exception e) {
                insert new Integration_Error__c(Error_Message__c = 'Error:: while updating the media assignment', Http_Response_Body__c = e.getMessage() +' :: ' + e.getStackTraceString(), Type__c = 'Media Assignment');
                System.debug('Error:: UpdateMediaAssignmentStatus *********** :: ' + e.getMessage());
                System.debug('Error:: UpdateMediaAssignmentStatus *********** :: ' + e.getStackTraceString());                
            }
        }
    }
}