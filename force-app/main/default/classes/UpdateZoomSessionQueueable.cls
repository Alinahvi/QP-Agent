public with sharing class UpdateZoomSessionQueueable implements Queueable, Database.AllowsCallouts {
    public Set<Id> sessionIds;
    
    public UpdateZoomSessionQueueable(Set<Id> sessionIds) {
        this.sessionIds = sessionIds;
    }

    public void execute(QueueableContext context) {
        List<Integration_Error__c> errors = new List<Integration_Error__c>();
        String accessToken = Utilities.getZoomAccessToken();
        Set<String> fields = SessionManager.getSessionFields();

        String soqlQuery = 'SELECT ' + String.join(new List<String>(fields), ',') + 
                           ' FROM Session__c ' +
                           ' WHERE Id IN :sessionIds' + 
                           ' WITH USER_MODE';

        for (Session__c session : Database.query(soqlQuery)) {
            if(Limits.getCallouts() == Limits.getLimitCallouts()){
                System.enqueueJob(new UpdateZoomSessionQueueable(sessionIds));
                return;
            }

            if (String.isNotEmpty(session.Zoom_Session_Id__c)) {
                ResponseData rd = new ResponseData();
                SessionManager.createZoomSession(session, rd, accessToken);

                if(!rd.isSuccess) {
                    errors.add(new Integration_Error__c(
                        Error_Message__c = 'Session Id : ' + session.Id + '  ' + rd.errMsg,
                        Http_Response_Body__c = JSON.serialize(rd.results.get('resBody')),
                        Type__c = 'Zoom Session Queueable Update'
                    ));
                }
            }

            sessionIds.remove(session.Id);
        }

        if(!errors.isEmpty()) {
            insert errors;
        }
    }
}