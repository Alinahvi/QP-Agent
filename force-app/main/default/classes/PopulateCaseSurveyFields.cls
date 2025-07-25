public with sharing class PopulateCaseSurveyFields {
    @InvocableMethod( label='Set Case Survey Fields' description='set case survey fields using related survey invitation')
    public static void setCaseSurveyFields(List<Case> newList) {
        String CASE_TYPE_LEARNER = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ACT_Learning_Case_Type').getRecordTypeId();
        String CASE_TYPE_OPERATIONS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ACT_Operations_Case_Type').getRecordTypeId();
        String CASE_ENABLEMENT_OPERATIONS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enablement_Operations_General').getRecordTypeId();

        List<Survey> sfSurvey = [SELECT Id 
                                 FROM Survey 
                                 WHERE DeveloperName =: Label.ACT2_Support_Survey // 'act_support_survey' 
                                 WITH USER_MODE
                                 LIMIT 1];
        Map<String, SurveyInvitation> invitationByCaseId = new Map<String, SurveyInvitation>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for(Case temp : newList) {
            if(temp.recordTypeId == CASE_TYPE_OPERATIONS || temp.recordTypeId == CASE_TYPE_LEARNER 
            || temp.recordTypeId == CASE_ENABLEMENT_OPERATIONS) {
                caseMap.put(temp.Id, temp); 
            }
        }

        if(sfSurvey.isEmpty() || caseMap.isEmpty()) {
            return;
        }
        for(Case data : caseMap.values()) {
            data.Survey__c = sfSurvey[0].Id;
            SurveyInvitation invitation = getSurveyInvitation(data);
            invitationByCaseId.put(data.Id, invitation);            
        }

        try {
            insert invitationByCaseId.values();
            // insert as user invitationByCaseId.values();
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'e.getMessage(): ' + e.getMessage());
            ExceptionUtility2.logError('SF_SURVEY', 'LearningAppCaseNotification :: ' + 'PopulateCaseSurveyFields()', 'SurveyInvitation', e.getMessage());
            return; 
        }

        Map<Id, SurveyInvitation> invitationMap = new Map<Id, SurveyInvitation>([SELECT Id, InvitationLink 
                                                                                        FROM SurveyInvitation 
                                                                                        WHERE Id IN : invitationByCaseId.values()
                                                                                        WITH USER_MODE]);
        for(Case data : caseMap.values()) {
            SurveyInvitation invitation = invitationMap.get(invitationByCaseId.get(data.Id).Id);
            data.Survey_Invitation__c = invitation.Id;
            data.Survey_URL__c = invitation.InvitationLink;           
        }

        try {
            update caseMap.values();
            // update as user Security.stripInaccessible(AccessType.UPDATABLE, caseMap.values()).getRecords();
        } catch(DMLException  e) {
            System.debug('The case field(s) "' + String.join(e.getDmlFieldNames(0), ', ') + '" are not accessible for update of Case');
            System.debug(LoggingLevel.ERROR, 'Errro while updating Survey Fields :: ' + e.getMessage());
            ExceptionUtility2.logError('SF_SURVEY', 'LearningAppCaseNotification' + 'setCaseSurveyFields()', 'SurveyInvitation', e.getMessage());
            return; 
        }
    }

    private static SurveyInvitation getSurveyInvitation(Case actCase) {
        SurveyInvitation invitation = new SurveyInvitation(
            SurveyId =  actCase.Survey__c,
            Name = 'Case - ' + actCase.CaseNumber + ' - Invitation' + '-' + Integer.valueof((Math.random() * 1000)),
            ACT2_Case__c = actCase.Id
        );
        return invitation;
    }    
}