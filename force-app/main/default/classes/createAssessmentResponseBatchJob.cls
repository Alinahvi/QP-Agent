global with sharing class createAssessmentResponseBatchJob implements Database.Stateful, Database.Batchable<sObject>{
    public List<Id> learnerIds = new List<Id>();
    public Date sendDate;
    public Date dueDate;
    public Id assessmentId;
    public String emailTemplate = 'Assigned_Excellence_Assessment_Team';
    public Map<String, Assessment_Response__c> managerResponseByManagerAssetId;
    Map<String, String> managerLPIdByUser;
    Set<String> failedManagerLPIds;
    Set<String> assignmentIds;
    Boolean fromAssignmentBatch = false;
    Boolean continueToNextJob = true;


    public createAssessmentResponseBatchJob(List<Id> learnersToProcess, Id assessmentId, Date sendDate, Date dueDate) {
        fromAssignmentBatch = false;
        this.learnerIds = learnersToProcess;
        this.assessmentId = assessmentId;
        this.sendDate = sendDate; 
        this.dueDate = dueDate;

        managerResponseByManagerAssetId = new Map<String, Assessment_Response__c>();
        managerLPIdByUser = new Map<String, String>();
        failedManagerLPIds = new Set<String>();
    }

    public createAssessmentResponseBatchJob(Set<String> assignmentIds, Boolean continueToNextJob) {
        this.fromAssignmentBatch = true;
        this.continueToNextJob = continueToNextJob;
        this.assignmentIds = assignmentIds;

        managerResponseByManagerAssetId = new Map<String, Assessment_Response__c>();
        managerLPIdByUser = new Map<String, String>();
        failedManagerLPIds = new Set<String>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return getAssignmentQuery();
        // return Database.getQueryLocator([SELECT Id, Name, User__c, Primary_Email__c,User__r.ManagerId, Manager_Email__c, Job_Code__c
        //                                     FROM Learner_Profile__c 
        //                                     WHERE Id = :learnerIds
        //                                     AND Status__c = 'Active'
        //                                     WITH USER_MODE]);

    }

    global void execute(Database.BatchableContext BC, List<Assignment__c> scope){
        createAssessmentResponses(scope);
    }

    public Database.QueryLocator getAssignmentQuery(){
        return Database.getQueryLocator([SELECT Id, Asset__c, Asset__r.Assessment__c, Learner_Profile__c, Learner_Profile__r.Name, Learner_Profile__r.User__r.ManagerId,
                                                Learner_Profile__r.Job_Code__c, Learner_Profile__r.Manager_Email__c, Learner_Profile__r.Primary_Email__c, Learner_Profile__r.User__c,
                                                Due_Date__c
                                         FROM Assignment__c
                                         WHERE Id =: assignmentIds]);
    }

    public void createAssessmentResponses(List<Assignment__c> assignments) {
        try {
            List<Assessment_Response__c> newResponses = new List<Assessment_Response__c>();
            // List<String> managerIds = new List<String>();
    
            // for(Assignment__c assignment : assignments){
            //     managerIds.add(assignment.Learner_Profile__r.User__r.ManagerId);
            // }
        
            // Map<Id, Learner_Profile__c> managerLPById = new Map<Id, Learner_Profile__c>([SELECT Id, Name, User__c, Job_Code__c
            //                                             FROM Learner_Profile__c
            //                                             WHERE User__c =: managerIds
            //                                             AND Id !=: failedManagerLPIds
            //                                             AND Status__c = 'Active'
            //                                             WITH USER_MODE]);
    
            // List<Assessment_Response__c> newManagerResponses = new List<Assessment_Response__c>();

            // for(Learner_Profile__c lp : managerLPById.values()){
            //     managerLPIdByUser.put(lp.User__c, lp.Id);
            // }

            // for(Assignment__c assignment : assignments){
            //     String managerLPId = managerLPIdByUser.get(assignment.Learner_Profile__r.User__r.ManagerId);
            //     Learner_Profile__c lp = managerLPById.get(managerLPId);
            //     Assessment_Response__c response = createStubResponse(lp, null, assignment);
    
            //     response.Is_Manager__c = true;
            //     response.OwnerId = lp.User__c;
    
            //     if(!managerResponseByManagerAssetId.containsKey(lp.User__c + '|' + assignment.Asset__c)){
            //         managerResponseByManagerAssetId.put(lp.User__c + '|' + assignment.Asset__c, response);
            //         newManagerResponses.add(response);
            //     }
            // }
    
            List<Integration_Error__c> errors = new List<Integration_Error__c>();
            // List<Database.SaveResult> saveResults = Database.insert(newManagerResponses, false, AccessLevel.USER_MODE);
    
            // for(Integer i = 0; i < saveResults.size(); i++){
            //     Database.SaveResult res = saveResults.get(i);
    
            //     if(!res.isSuccess()){
            //         Assessment_Response__c failedResponse = newManagerResponses.get(i);
            //         Learner_Profile__c managerLP = managerLPById.get(failedResponse.Assessment_Taker__c);
    
            //         managerResponseByManagerAssetId.remove(failedResponse.OwnerId);
            //         managerLPIdByUser.remove(failedResponse.OwnerId + '|' + failedResponse.Asset__c);
    
            //         failedManagerLPIds.add(failedResponse.Assessment_Taker__c);
    
            //         String errMsg = 'Failed to create Manager assessment response for ' + managerLP.Name + ' with LP Id : ' + managerLP.Id + ' \n\nError: ';

            //         for(Database.Error err : res.getErrors()) {
            //             errMsg += err.getStatusCode() + ': ' + err.getMessage() + ' fields ' + err.getFields() + '\n\n';
            //         }
    
            //         errors.add(new Integration_Error__c(
            //             Error_Message__c = errMsg,
            //             Type__c = 'Assessment Response Creation'
            //         ));
            //     }
            // }
    
            
    
            for(Assignment__c assignment : assignments){
                Learner_Profile__c lp = assignment.Learner_Profile__r;
                String managerId = lp.User__r.ManagerId;
    
                // if(!managerResponseByManagerAssetId.containsKey(managerId + '|' + assignment.Asset__c)){
                //     errors.add(new Integration_Error__c(
                //         Error_Message__c = 'Failed to create assessment response for ' + lp.Name + ' with LP Id : ' + lp.Id + ' and assignment ' + assignment.Id + 
                //                            '. No Manager Response found for manager Id : ' + managerId,
                //         Type__c = 'Assessment Response Creation'
                //     ));
    
                //     continue;
                // }
    
                System.debug('************* ' + assignment);
                Assessment_Response__c response = createStubResponse(lp, managerLPIdByUser.get(managerId), assignment);
                // Assessment_Response__c managerResponse = managerResponseByManagerAssetId.get(managerId + '|' + assignment.Asset__c);
                System.debug('************* response ' + response);
                response.OwnerId = lp.User__c;
                // response.Manager_Response__c = managerResponse.Id;

                newResponses.add(response);
            }
    
            List<Database.SaveResult> saveResults = Database.insert(newResponses, false, AccessLevel.USER_MODE);
    
            for(Integer i = 0; i < saveResults.size(); i++){
                Database.SaveResult res = saveResults.get(i);
    
                if(!res.isSuccess()){
                    Assessment_Response__c failedResponse = newResponses.get(i);
                    String errMsg = 'Failed to create Employee response for : ' + failedResponse.Assessment_Taker__r.Name + ' with Id : ' + failedResponse.Assessment_Taker__c;
    
                    for(Database.Error err : res.getErrors()) {
                        errMsg += err.getStatusCode() + ': ' + err.getMessage() + ' fields ' + err.getFields() + '\n\n';
                    }
    
                    errors.add(new Integration_Error__c(
                        Error_Message__c = errMsg,
                        Type__c = 'Assessment Response Creation'
                    ));
                }
            }
    
            insert errors;

        } catch(Exception e){
            String errMsg = utilities.getErrorMessage(e);

            insert as user new Integration_Error__c(
                Error_Message__c = errMsg,
                Http_Response_Body__c = e.getStackTraceString(),
                Type__c = 'Assessment Response Creation'
            );
        }
    }
/*
    public void createAssessmentResponses(List<Assignment__c> assignments) {
        try {
            List<Assessment_Response__c> newResponses = new List<Assessment_Response__c>();
            List<String> managerIds = new List<String>();
    
            for(Assignment__c assignment : assignments){
                managerIds.add(assignment.Learner_Profile__r.User__r.ManagerId);
            }
        
            Map<Id, Learner_Profile__c> managerLPById = new Map<Id, Learner_Profile__c>([SELECT Id, Name, User__c, Job_Code__c
                                                        FROM Learner_Profile__c
                                                        WHERE User__c =: managerIds
                                                        AND Id !=: failedManagerLPIds
                                                        AND Status__c = 'Active'
                                                        WITH USER_MODE]);
    
            List<Assessment_Response__c> newManagerResponses = new List<Assessment_Response__c>();

            for(Learner_Profile__c lp : managerLPById.values()){
                managerLPIdByUser.put(lp.User__c, lp.Id);
            }

            for(Assignment__c assignment : assignments){
                String managerLPId = managerLPIdByUser.get(assignment.Learner_Profile__r.User__r.ManagerId);
                Learner_Profile__c lp = managerLPById.get(managerLPId);
                Assessment_Response__c response = createStubResponse(lp, null, assignment);
    
                response.Is_Manager__c = true;
                response.OwnerId = lp.User__c;
    
                if(!managerResponseByManagerAssetId.containsKey(lp.User__c + '|' + assignment.Asset__c)){
                    managerResponseByManagerAssetId.put(lp.User__c + '|' + assignment.Asset__c, response);
                    newManagerResponses.add(response);
                }
            }
    
            List<Integration_Error__c> errors = new List<Integration_Error__c>();
            List<Database.SaveResult> saveResults = Database.insert(newManagerResponses, false, AccessLevel.USER_MODE);
    
            for(Integer i = 0; i < saveResults.size(); i++){
                Database.SaveResult res = saveResults.get(i);
    
                if(!res.isSuccess()){
                    Assessment_Response__c failedResponse = newManagerResponses.get(i);
                    Learner_Profile__c managerLP = managerLPById.get(failedResponse.Assessment_Taker__c);
    
                    managerResponseByManagerAssetId.remove(failedResponse.OwnerId);
                    managerLPIdByUser.remove(failedResponse.OwnerId + '|' + failedResponse.Asset__c);
    
                    failedManagerLPIds.add(failedResponse.Assessment_Taker__c);
    
                    String errMsg = 'Failed to create Manager assessment response for ' + managerLP.Name + ' with LP Id : ' + managerLP.Id + ' \n\nError: ';

                    for(Database.Error err : res.getErrors()) {
                        errMsg += err.getStatusCode() + ': ' + err.getMessage() + ' fields ' + err.getFields() + '\n\n';
                    }
    
                    errors.add(new Integration_Error__c(
                        Error_Message__c = errMsg,
                        Type__c = 'Assessment Response Creation'
                    ));
                }
            }
    
            
    
            for(Assignment__c assignment : assignments){
                Learner_Profile__c lp = assignment.Learner_Profile__r;
                String managerId = lp.User__r.ManagerId;
    
                if(!managerResponseByManagerAssetId.containsKey(managerId + '|' + assignment.Asset__c)){
                    errors.add(new Integration_Error__c(
                        Error_Message__c = 'Failed to create assessment response for ' + lp.Name + ' with LP Id : ' + lp.Id + ' and assignment ' + assignment.Id + 
                                           '. No Manager Response found for manager Id : ' + managerId,
                        Type__c = 'Assessment Response Creation'
                    ));
    
                    continue;
                }
    
    
                Assessment_Response__c response = createStubResponse(lp, managerLPIdByUser.get(managerId), assignment);
                Assessment_Response__c managerResponse = managerResponseByManagerAssetId.get(managerId + '|' + assignment.Asset__c);
                System.debug('**************** ' + managerResponseByManagerAssetId);
                System.debug('**************** ' + managerId + '|' + assignment.Asset__c);
                System.debug('**************** ' + managerResponse);
                response.OwnerId = lp.User__c;
                response.Manager_Response__c = managerResponse.Id;
    
                newResponses.add(response);
            }
    
            saveResults = Database.insert(newResponses, false, AccessLevel.USER_MODE);
    
            for(Integer i = 0; i < saveResults.size(); i++){
                Database.SaveResult res = saveResults.get(i);
    
                if(!res.isSuccess()){
                    Assessment_Response__c failedResponse = newResponses.get(i);
                    String errMsg = 'Failed to create Employee response for : ' + failedResponse.Assessment_Taker__r.Name + ' with Id : ' + failedResponse.Assessment_Taker__c;
    
                    for(Database.Error err : res.getErrors()) {
                        errMsg += err.getStatusCode() + ': ' + err.getMessage() + ' fields ' + err.getFields() + '\n\n';
                    }
    
                    errors.add(new Integration_Error__c(
                        Error_Message__c = errMsg,
                        Type__c = 'Assessment Response Creation'
                    ));
                }
            }
    
            insert as user errors;
    
            //Deprecated as we're no longer handling communications
            // if(sendDate == Date.today()){
            //     List<Assessment_Response__c> arWithData = [SELECT Id, Assessment_Taker__c, Assessment_Taker__r.User__c, Assessment_Taker__r.Primary_Email__c, Is_Manager__c
            //                                                FROM Assessment_Response__c
            //                                                WHERE Id =: newResponses
            //                                                OR Id =: managerResponseByManagerAssetId.values()];
        
        
            //     sendAssessmentEmails(arWithData);
            // }
        } catch(Exception e){
            String errMsg = utilities.getErrorMessage(e);

            insert as user new Integration_Error__c(
                Error_Message__c = errMsg,
                Http_Response_Body__c = e.getStackTraceString(),
                Type__c = 'Assessment Response Creation'
            );
        }
    }
*/
    public Assessment_Response__c createStubResponse(Learner_Profile__c assessmentTakerLP, String managerId, Assignment__c assignment) {
        // return new Assessment_Response__c(
        //     Assessment__c = assignment.Asset__r.Assessment__c,
        //     Asset__c = assignment.Asset__c,
        //     Assessment_Taker__c = assessmentTakerLP.Id,
        //     Manager__c = managerId,
        //     Status__c = 'Not Started',
        //     Due_Date__c = assignment.Due_Date__c,
        //     Send_Date__c = Date.today(),
        //     Job_Code__c = assessmentTakerLP.Job_Code__c,
        //     Assignment__c = managerId != null ? assignment.Id : null
        // );

        return new Assessment_Response__c(
            Assessment__c = assignment.Asset__r.Assessment__c,
            Asset__c = assignment.Asset__c,
            Assessment_Taker__c = assessmentTakerLP.Id,
            Status__c = 'Not Started',
            Due_Date__c = assignment.Due_Date__c,
            Send_Date__c = Date.today(),
            Job_Code__c = assessmentTakerLP.Job_Code__c,
            Assignment__c = assignment.Id
        );
    }
    
    global void finish(Database.BatchableContext BC){
        if(fromAssignmentBatch && continueToNextJob){
            Database.executeBatch(new SlackNotificationBatch(), 15);
        }
    }
}