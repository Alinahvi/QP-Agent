public with sharing class SEF_AssessmentConsumer implements SEF_ActivityConsumerInterface {
    static final String PASS = 'success';
    static final String FAIL = 'failures';

    /* Hardcoded test data */
    static final String DEV = 'a69D3000000JzWkIAK';
    static final String QA = 'a69D40000007vAGIAY';
    static final String UAT = 'a69Hu000001hKxSIAU';
    static final String PROD = 'a69Hu000001eP1wIAE';

    public void consume(List<SEF_ActivityStream> activities) {
        try {
            SEF_ActivityStream activity = activities.get(0);
            Map<String,Object> target = activity.getMetadata();
            Map<String,Object> results = activity.getResult();
            Map<String,Object> data = (Map<String,Object>)target.get('response');
            String assessmentResult = (String)data.get('type');
            String federationId = (String)data.get('federationId');
            String eventUuid = activity.getId();
            federationId = federationId.replace('appdev.it.', '');
            
            // String assetId = (String)target.get('certificationId');
            String assetId = (String)target.get('certificationId'); // Hardcoded for testing purposes.

            System.debug('target: ' + target);

            if (assessmentResult != PASS && assessmentResult != FAIL) {
                handleError('The following assessment result is not valid: ' + assessmentResult, activity.serialize());
            } else {
                List<Learner_Profile__c> learnerProfile = [SELECT Id FROM Learner_Profile__c WHERE User__r.FederationIdentifier = :federationId];

                if (learnerProfile.size() > 0) {
                    Quiz_Attempt__c quizAttempt = new Quiz_Attempt__c(
                        Asset__c = assetId,
                        Learner_Profile__c = learnerProfile[0].Id,
                        Platform_Event_Uuid__c = eventUuid,
                        Passed__c = false
                    );

                    if (assessmentResult == PASS) {
                        quizAttempt.Passed__c = true;

                        List<Assignment__c> assignment = [SELECT Id, Completed__c FROM Assignment__c WHERE Asset__c = :assetId AND Learner_Profile__c = :learnerProfile[0].Id];
                        
                        if (assignment.size() > 0) {
                            assignment[0].Completed__c = true;
                            update assignment;
                        } else {
                            handleError('An Assignment record was not found for the Asset Id: ' + assetId + ' and Learner Profile Id: ' + learnerProfile[0].Id, activity.serialize());
                        }
                    }

                    insert quizAttempt;
                } else {
                    handleError('A Learner Profile record was not found for the Federation Id: ' + federationId, activity.serialize());
                }
            }
        } catch (Exception e) {
            handleError(e.getMessage(), activities.get(0).serialize());
        }
    }

    private void handleError(String message, String responseBody) {
        System.debug('SEF_AssessmentConsumer Error: ' + message);
        Integration_Error__c error = new Integration_Error__c(
            Error_Message__c = message,
            Http_Response_Body__c = responseBody,
            Type__c = 'Slack AI Assessment Platform Event'
        );
        insert error;
    }
}