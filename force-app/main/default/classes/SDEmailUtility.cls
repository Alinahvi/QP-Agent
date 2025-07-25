public with sharing class SDEmailUtility {
    
    public static Boolean SEND_EMAIL_ENABLED = true;
    public Static String APP_NAME = 'SD - LevelJump';
    public Static String CLASS_NAME = 'SDEmailUtility';

    
    public static void triggerEmails(Id emailTemplateId, Map<Id, List<Id>> objectUsersMap) {
        if(objectUsersMap != null && !objectUsersMap.isEmpty() && emailTemplateId != null) {
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            for(Id whatId : objectUsersMap.keySet()) {
                sendVSDEmailToMutipleRecipient(emailTemplateId, objectUsersMap.get(whatId), whatId);
            }
        }        
    }
    
    public static boolean sendVSDEmail(Id emailTemplateId, Id whoId, Id whatId) {
        if(emailTemplateId == null || whoId == null || whatId == null)
            return false;
        
        OrgWideEmailAddress[] emailAddress = [SELECT Id, Address 
                                                FROM OrgWideEmailAddress 
                                                WHERE Address = 'astrocoursetracker@salesforce.com'];
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplateId, whoId, whatId);
        if ( emailAddress.size() > 0 ) {
            email.setOrgWideEmailAddressId(emailAddress[0].Id);
        }
        email.setTargetObjectId(whoId);
        email.setSubject(email.getSubject());
        email.setHtmlBody(email.getHtmlBody());
        email.saveAsActivity = false;
        emailList.add(email);

        return sendEmails(emailList);
    }

    public static boolean sendVSDEmailToMutipleRecipient(Id emailTemplateId, List<Id> whoId, Id whatId) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        if(emailTemplateId == null || whoId == null || whoId.isEmpty() || whatId == null)
            return false;
        
        OrgWideEmailAddress[] emailAddress = [SELECT Id, Address 
                                                FROM OrgWideEmailAddress 
                                                WHERE Address = 'astrocoursetracker@salesforce.com'];

        for(Id recipentId : whoId) {
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplateId, recipentId, whatId);
            if ( emailAddress.size() > 0 ) {
                email.setOrgWideEmailAddressId(emailAddress[0].Id);
            }
            email.setTargetObjectId(recipentId);
            email.setSubject(email.getSubject());
            email.setHtmlBody(email.getHtmlBody());
            email.saveAsActivity = false;
            emailList.add(email);
        }
        return sendEmails(emailList);
    }

    public static boolean sendEmails(List<Messaging.SingleEmailMessage> emails) {
        if(emails == null && emails.isEmpty())
            return false;

        try {
            Messaging.reserveSingleEmailCapacity(emails.size());
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'Email ERROR :: ' + e.getMessage());
            System.debug(LoggingLevel.FINEST, 'Email ERROR :: ' + e.getStackTraceString());
            //ExceptionUtility.logError(APP_NAME, CLASS_NAME + 'sendVSDEmailToMutipleRecipient', 'SingleEmailMessage', e.getMessage());
            return false;
        }

        List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
        return isEmailSentSuccessfully(results);
    }


    private static boolean isEmailSentSuccessfully(List<Messaging.SendEmailResult> results) {
        if(results != null && !results.isEmpty()) {
            //List<slj__Integration_Error__c> errors = new List<slj__Integration_Error__c>();
            for(Messaging.SendEmailResult result : results) {
                if(!result.isSuccess()) {
                    List<Messaging.SendEmailError> emailErrors = result.getErrors();
                    if(emailErrors != null && !emailErrors.isEmpty()) {
                        for(Messaging.SendEmailError emailError : emailErrors) {
                            System.debug(LoggingLevel.ERROR, 'Email Error Fields ::  ' + emailError.getFields());
                            //errors.add(ExceptionUtility.createErrorLog(APP_NAME, CLASS_NAME + 'isEmailSentSuccessfully', 'sendVSDEmails', emailError.getMessage()));
                        }
                    }
                }
            }
            //if(!errors.isEmpty()) {
                //ExceptionUtility.insertErrorLogs(errors);
              //  return false;
            //} else {
                return true;
            //}
        } else {
            return false;
        }
    }
}