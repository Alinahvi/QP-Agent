public with sharing class transcriptTriggerHelper {
    Static String APP_NAME = 'MEDIA - Appinium';
    Static String CLASS_NAME = 'transcriptTriggerHelper';

    public transcriptTriggerHelper() {

    }

    public static void updateAssignmentStatus(Map<Id, scormanywhere__Transcript__c> dataMap) {
        Map<Id, Set<Id>> usersByMediaIdCompleted = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> usersByMediaIdInProgress = new Map<Id, Set<Id>>();
        List<Id> completedUserList = new List<Id>();
		List<Id> inprogressUserList = new List<Id>();
        for(scormanywhere__Transcript__c transcript : dataMap.values()) {
            if(!transcript.scormanywhere__Test_Launch__c) {
                if(transcript.scormanywhere__Status__c == 'Completed' || transcript.scormanywhere__Status__c == 'Passed') {
                    if(!usersByMediaIdCompleted.containsKey(transcript.scormanywhere__Course__c)) {
						usersByMediaIdCompleted.put(transcript.scormanywhere__Course__c, new Set<Id>());
					}
					usersByMediaIdCompleted.get(transcript.scormanywhere__Course__c).add(transcript.scormanywhere__User__c);
					completedUserList.add(transcript.scormanywhere__User__c);
                } else if(transcript.scormanywhere__Status__c == 'Incomplete' || String.isBlank(transcript.scormanywhere__Status__c)) {
                    if(!usersByMediaIdInProgress.containsKey(transcript.scormanywhere__Course__c)) {
						usersByMediaIdInProgress.put(transcript.scormanywhere__Course__c, new Set<Id>());
					}
					usersByMediaIdInProgress.get(transcript.scormanywhere__Course__c).add(transcript.scormanywhere__User__c);
					inprogressUserList.add(transcript.scormanywhere__User__c);
                }
            }           
            
        }
        updateAssignmentbyLearnerProfile(usersByMediaIdCompleted, completedUserList, 'Completed');   
        updateAssignmentbyLearnerProfile(usersByMediaIdInProgress, inprogressUserList, 'In Progress');        
    }

    public static void updateAssignmentStatus(Map<Id, scormanywhere__Transcript__c> newMap, Map<Id, scormanywhere__Transcript__c> oldMap) {
        Map<Id, Set<Id>> usersByMediaIdCompleted = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> usersByMediaIdInProgress = new Map<Id, Set<Id>>();
		
		List<Id> completedUserList = new List<Id>();
		List<Id> inprogressUserList = new List<Id>();
		for(Id key : newMap.keySet()) {
            scormanywhere__Transcript__c newData = newMap.get(key);
            scormanywhere__Transcript__c oldData = oldMap.get(key);
            if(!newData.scormanywhere__Test_Launch__c) {
                if((oldData.scormanywhere__Status__c != 'Completed' && newData.scormanywhere__Status__c == 'Completed') ||
                    (oldData.scormanywhere__Status__c != 'Passed' && newData.scormanywhere__Status__c == 'Passed')) {
                    if(!usersByMediaIdCompleted.containsKey(newData.scormanywhere__Course__c)) {
						usersByMediaIdCompleted.put(newData.scormanywhere__Course__c, new Set<Id>());
					}
					usersByMediaIdCompleted.get(newData.scormanywhere__Course__c).add(newData.scormanywhere__User__c);
					completedUserList.add(newData.scormanywhere__User__c);
                } else if(oldData == null || (newData.scormanywhere__Status__c == 'Incomplete' && oldData.scormanywhere__Status__c != newData.scormanywhere__Status__c)) {
                    if(!usersByMediaIdInProgress.containsKey(newData.scormanywhere__Course__c)) {
						usersByMediaIdInProgress.put(newData.scormanywhere__Course__c, new Set<Id>());
					}
					usersByMediaIdInProgress.get(newData.scormanywhere__Course__c).add(newData.scormanywhere__User__c);
					inprogressUserList.add(newData.scormanywhere__User__c);
                }
            }            
        }
        updateAssignmentbyLearnerProfile(usersByMediaIdCompleted, completedUserList, 'Completed');
        updateAssignmentbyLearnerProfile(usersByMediaIdInProgress, inprogressUserList, 'In Progress');
    }
	
	private static void updateAssignmentbyLearnerProfile(Map<Id, Set<Id>> usersByMediaId, List<Id> userList, String status) {
        /*
		if(!usersByMediaId.isEmpty()) {
			Map<Id, Id> mediaByLearnerProfileId = new Map<Id, Id>();
            Map<Id, Id> learnerProfileByUserId = learnerProfileByUserId(userList);
            for(Id mediaId : usersByMediaId.keySet()) {
                Set<Id> userSet = usersByMediaId.get(mediaId);
                for(Id userId : userSet) {
                    if(learnerProfileByUserId.containsKey(userId)) {
                        mediaByLearnerProfileId.put(learnerProfileByUserId.get(userId), mediaId);
                    }
                }
            }
            if(!mediaByLearnerProfileId.isEmpty()) {
                updateAssignment(mediaByLearnerProfileId, status);
            }                    
		}	
        */	
	}  

    /* Remove ACT 1 references
    public static Map<Id, Id> learnerProfileByUserId(List<Id> userId) {
        Map<Id, Id> learnerProfileByUserId = new Map<Id, Id>();
        if(userId == null || userId.isEmpty())
            return learnerProfileByUserId;
        // for(slj__Learner_Profile__c LP : [SELECT Id, slj__User__c 
        //                                     FROM slj__Learner_Profile__c
        //                                     WHERE slj__User__c IN :userId]) {
        //     learnerProfileByUserId.put(LP.slj__User__c, LP.Id);
        // }
        return learnerProfileByUserId;
    }
    
    private static void updateAssignment(Map<Id, Id> mediaByLearnerProfileId, String status) {
        List<slj__Assignment__c> assignmentToUpdate = new List<slj__Assignment__c>();
        Map<String, slj__Assignment__c> assignmentByLPmediaId = new Map<String, slj__Assignment__c>();
        for(slj__Assignment__c assignment : [SELECT Id, slj__Cancelled__c, slj__Learner_Profile__c, 
                                                Scorm_Media__c, slj__Status__c                                                
                                                FROM slj__Assignment__c
                                                WHERE slj__Cancelled__c = false
                                                AND slj__Status__c != 'Completed'
                                                AND RecordType.DeveloperName = 'eLearning_Video'
                                                AND Scorm_Media__c IN : mediaByLearnerProfileId.values()
                                                AND slj__Learner_Profile__c IN : mediaByLearnerProfileId.keySet()]) {
            String key = assignment.slj__Learner_Profile__c+'&&'+assignment.Scorm_Media__c;
            assignmentByLPmediaId.put(key, assignment);            
        }
        
        if(!assignmentByLPmediaId.isEmpty()) {
            for(Id key : mediaByLearnerProfileId.keySet()) {
                String tempKey = key+'&&'+mediaByLearnerProfileId.get(key);
                slj__Assignment__c assignment = assignmentByLPmediaId.get(tempKey);
                if(assignment != null) {
                    assignment.slj__Status__c = status; 
                    assignmentToUpdate.add(assignment);
                }
            }
        }
        // System.debug('Assignment to Update ************ '+assignmentToUpdate);
        if(!assignmentToUpdate.isEmpty()) {
            try {
                update assignmentToUpdate;
            } catch(Exception e) {
                System.debug(LoggingLevel.ERROR, 'e.getMessage(): ' + e.getMessage());
                System.debug(LoggingLevel.FINEST, 'e.getStackTraceString(): ' + e.getStackTraceString());
                ExceptionUtility.logError(APP_NAME, CLASS_NAME + 'Trigger', 'updateAssignment', e.getMessage());
            }            
        }
    }
    */
}