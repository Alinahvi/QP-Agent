public with sharing class GetNotificationLogs {
    public static List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
    
    // @InvocableMethod( label='Get Notification Log' description='Get Notification Log')
    @future(callout=true)
    public static void triggerLogService() {
        Map<String, String> headers = new Map<String, String> {
            'Authentication' => 'Bearer '+ Constants.HEROKU_API_KEY            
        };

        String endPoint = Constants.HEROKU_ENDPOINT + '/postLog';
        try {
            HttpResponse res = Utilities.makeCallout(endPoint, 'GET', headers);
            Integer statusCode = res.getStatusCode();
            System.debug('res body ------- '+res.getBody());
            if(statusCode != 200 && statusCode != 201) {
                Slack_Notification_Error__c se = new Slack_Notification_Error__c(
                    Learner_Profile__c = null,
                    Request_Body__c =  '',
                    Response_Body__c =  res.getBody(),
                    Time_Sent__c =  DateTime.now()
                );
                errorList.add(se);
            }
            
            if(!errorList.isEmpty()) {
                insert as user errorList;
            }
        }catch(Exception e) {
            System.debug('Error:: Heroku api *********** :: ' + e.getMessage());
            System.debug('Error:: Heroku api *********** :: ' + e.getStackTraceString());
        }
    }
}