//Deprecated for now as we don't send communications
global with sharing class sendCompetencyAssessmentReminderBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {}

    global void finish(Database.BatchableContext BC) {}


    // public String managerLateEmail = 'Time_is_Up_Manager';
    // public String managerUpcomingEmail = 'Time_is_Almost_Up_Manager';
    // public String learnerLateEmail = 'Time_is_Up_IC';
    // public String learnerUpcomingEmail = 'Time_is_Almost_Up_IC';
    // public Map<String, Object> sentManagerEmail = new Map<String, Object>();

    // List<String> emailTemplateList = new List<String>{
    //     'Time_is_Up_Manager', 'Time_is_Almost_Up_Manager', 'Time_is_Up_IC', 'Time_is_Almost_Up_IC'
    // };
    // Map<String, EmailTemplate> emailTemplates = new Map<String, EmailTemplate>();

    // public sendCompetencyAssessmentReminderBatch() {
    //     List<EmailTemplate> templates = [SELECT Id, DeveloperName 
    //                                      FROM EmailTemplate 
    //                                      WHERE DeveloperName IN :emailTemplateList];

    //     for (EmailTemplate et : templates) {
    //         emailTemplates.put(et.DeveloperName, et);
    //     }
    // }

    // global Database.QueryLocator start(Database.BatchableContext BC) {
    //     dmlManager.checkAccess(accessChecks);
    //     return Database.getQueryLocator([SELECT Id, Assessor__c, Due_Date__c, Assessment__c, Status__c, Assessor__r.Email, Assessor__r.Name, Assessment__r.Name, Type__c
    //                                      FROM Assessment_Invitation__c
    //                                      WHERE Status__c != 'Submitted'
    //                                      AND Due_Date__c >= :Date.today()
    //                                      ORDER BY Assessment__r.Name, Due_Date__c DESC]);
    // }

    // global void execute(Database.BatchableContext BC, List<Assessment_Invitation__c> scope) {
    //     Date todayDate = Date.today();
    //     List<Assessment_Invitation__c> lateInvitations = new List<Assessment_Invitation__c>();
    //     List<Assessment_Invitation__c> upcommingInvitations = new List<Assessment_Invitation__c>();
    //     for (Assessment_Invitation__c ai : scope) {
    //         Date dueDate = Date.valueOf(ai.Due_Date__c);
    //         Date pastDate = dueDate.addDays(-2);

    //         if (todayDate == dueDate) {
    //             lateInvitations.add(ai);
    //         }
    //         if (todayDate == pastDate) {
    //             upcommingInvitations.add(ai);
    //         }
    //     }

    //     //need to be in this order, late assessments take priority
    //     if (!lateInvitations.isEmpty()) {
    //         sendEmail(lateInvitations, true);
    //     }

    //     if (!upcommingInvitations.isEmpty()) {
    //         sendEmail(upcommingInvitations, false);
    //     }

    // }

    // private void sendEmail(List<Assessment_Invitation__c> invitations, Boolean isLate) {
    //     Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
    //     OrgWideEmailAddress orgEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'astrocoursetracker@salesforce.com'];

    //     for (Assessment_Invitation__c ai : invitations) {
    //         String template = isLate ? learnerLateEmail : learnerUpcomingEmail;

    //         if (this.sentManagerEmail.containsKey((String)ai.Assessor__c + (String)ai.Assessment__c)) {
    //             continue;
    //         }

    //         if (ai.Type__c == 'Manager') {
    //             this.sentManagerEmail.put((String)ai.Assessor__c + (String)ai.Assessment__c, ai.Assessor__c);
    //             template = isLate ? managerLateEmail : managerUpcomingEmail;
    //         }

    //         Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    //         // message.setSenderDisplayName(ai.Assessor__r.Name); 
    //         message.setTargetObjectId(ai.Assessor__c);
    //         message.setUseSignature(false); 
    //         message.setBccSender(false); 
    //         message.setSaveAsActivity(false); 
    //         message.setTemplateID(emailTemplates.get(template).Id);
    //         message.setWhatId(ai.Id);
    //         message.setOrgWideEmailAddressId(orgEmail.Id);
    //         message.toAddresses = new String[] { ai.Assessor__r.Email};

    //         //add email to list
    //         messages.add(message);

    //     }
    //     Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    // }

    // global void finish(Database.BatchableContext BC) {}

    // private static Map<String, Map<String, List<String>>> accessChecks = new Map<String, Map<String, List<String>>> {
    //     'Assessment_Invitation__c' => new Map<String, List<String>> {
    //         'Read' => new List<String> {
    //             'Id', 'Assessor__c', 'Due_Date__c', 'Assessment__c', 'Status__c', 'Type__c'
    //         }
    //     },
    //     'Assessment__c' => new Map<String, List<String>> {
    //         'Read' => new List<String> {
    //             'Status__c', 'Name'
    //         }
    //     },
    //     'User' => new Map<String, List<String>> {
    //         'Read' => new List<String> {
    //             'Email', 'Name'
    //         }
    //     }
    // };
}