public with sharing class scheduleAssessment {
    @AuraEnabled
    public static String checkForExistingInvite(Id assessmentId, Id learnerId) {
        responseData rd = new responseData();

        try{
            

            Learner_Profile__c lp = [SELECT User__c FROM Learner_Profile__c WHERE Id = :learnerId AND Status__c = 'Active' WITH USER_MODE];

            // Integer inviteCount = [SELECT COUNT() 
            //                        FROM Assessment_Invitation__c 
            //                        WHERE Assessment__c = :assessmentId
            //                        AND Assessee__c = :lp.User__c
            //                        AND Status__c != 'Submitted'
            //                        AND Type__c = 'Employee'];
                                   
            // rd.put('hasExistingInvite', inviteCount > 0);
        } catch(Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String processEmails(List<String> emails, Id assessmentId) {
        responseData rd = new responseData();

        try {
            List<String> lowercaseEmails = new List<String>();

            for (String email : emails) {
                lowercaseEmails.add(email.toLowerCase());
            }

            Map<Id, CsvRow> lpByUserId = new Map<Id, CsvRow>();

            //get active lps that match emails
            for (Learner_Profile__c lp : [SELECT Id, Name, Primary_Email__c, User__c
                                          FROM Learner_Profile__c
                                          WHERE Primary_Email__c = :emails
                                          AND Primary_Email__c != null
                                          AND Status__c = 'Active'
                                          WITH USER_MODE]) {
                String lowercasePrimaryEmail = lp.Primary_Email__c.toLowerCase();

                //found emails removed from list
                if (lowercaseEmails.contains(lowercasePrimaryEmail)) {
                    lowercaseEmails.remove(lowercaseEmails.indexOf(lowercasePrimaryEmail));
                    lpByUserId.put(lp.User__c, new CsvRow(lp));
                }
            }

            List<CsvRow> duplicates = new List<CsvRow>();
            List<CsvRow> notFounds = new List<CsvRow>(); 
            // //get dupes
            // for(Assessment_Invitation__c ai : [SELECT Assessee__c
            //                                    FROM Assessment_Invitation__c
            //                                    WHERE Assessment__c = :assessmentId
            //                                      AND Assessee__c = :lpByUserId.keySet()
            //                                      AND Status__c != 'Submitted'
            //                                      AND Type__c = 'Employee']) {
            //     //dupe members removed from map
            //     if(lpByUserId.containsKey(ai.Assessee__c)) {
            //         duplicates.add(lpByUserId.remove(ai.Assessee__c));
            //     }
            // }
 
            for(String email : lowercaseEmails){
                notFounds.add(new CsvRow(email));
            }

            rd.put('newMembers', lpByUserId.values());
            rd.put('duplicates', duplicates);
            rd.put('notFound', notFounds);
        } catch(Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String createAssessmentInvitations(List<Id> learnerIds, Id assessmentId, String sendDateStr, String dueDateStr, String dueTimeStr) {
        responseData rd = new responseData();

        try {
            

            /*
            List<Learner_Profile__c> lps = [SELECT User__c, User__r.ManagerId 
                                                 FROM Learner_Profile__c 
                                                 WHERE Id = :learnerIds];
            */

            Date dueDate = Date.valueOf(dueDateStr);
            Date sendDate = Date.valueOf(sendDateStr);


            Id batchJobId = Database.executeBatch(new createAssessmentResponseBatchJob(learnerIds, assessmentId, sendDate, dueDate), 200);


            /*

            List<Assessment_Invitation__c> managerInvitations = new List<Assessment_Invitation__c>();
            Map<Id, Assessment_Invitation__c> employeeInvitationByEmployeeUserId = new Map<Id, Assessment_Invitation__c>();


            Boolean sendNotification = sendDate == Date.today();

            for(Learner_Profile__c lp : lps) {
                //add employee assessment
                employeeInvitationByEmployeeUserId.put(lp.User__c, new Assessment_Invitation__c(
                    Assessment_Taker__c = lp.User__c,
                    Assessor__c = lp.User__c,
                    Assessment__c = assessmentId,
                    Send_Date__c = sendDate,
                    Type__c = 'Employee',
                    Send_Notification__c = sendNotification,
                    OwnerId = lp.User__c,
                    Due_Date__c = dueDate
                ));

                if(String.isNotEmpty(lp.User__r.ManagerId)) {
                    //add manager assessment
                    managerInvitations.add(new Assessment_Invitation__c(
                        Assessment_Taker__c = lp.User__c,
                        Assessor__c = lp.User__r.ManagerId,
                        Assessment__c = assessmentId,
                        Send_Date__c = sendDate,
                        Type__c = 'Manager',
                        Send_Notification__c = sendNotification,
                        OwnerId = lp.User__c,
                        Due_Date__c = dueDate
                    ));
                }
            }
            insert managerInvitations;

            //populate lookups to manager invitations on employee invitations
            for(Assessment_Invitation__c ai : managerInvitations) {
                if(employeeInvitationByEmployeeUserId.containsKey(ai.Assessment_Taker__c)) {
                    employeeInvitationByEmployeeUserId.get(ai.Assessment_Taker__c).Manager_Invitation__c = ai.Id;
                }
            }

            insert employeeInvitationByEmployeeUserId.values();
            */
        } catch(Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    private class CsvRow{
        @AuraEnabled public Id lpId;
        @AuraEnabled public String name;
        @AuraEnabled public String email;

        private CsvRow(Learner_Profile__c lp) {
            this.lpId = lp.Id;
            this.name = lp.Name;
            this.email = lp.Primary_Email__c;
        }

        private CsvRow(String email) {
            this.email = email;
        }
    }
}