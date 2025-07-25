public with sharing class DeleteZoomSessionQueueable implements Queueable, Database.AllowsCallouts {
    public List<Session__c> sessions;
    
    public DeleteZoomSessionQueueable(List<Session__c> sessions) {
        this.sessions = sessions;
    }

    public void execute(QueueableContext context) {
        List<Session__c> remainingSessions = new List<Session__c>();
        List<Integration_Error__c> errors = new List<Integration_Error__c>();

        for (Session__c session : sessions) {
            if(Limits.getCallouts() == Limits.getLimitCallouts()){
                remainingSessions.add(session);
            }

            if (String.isNotEmpty(session.Zoom_Session_Id__c)) {
                ResponseData rd = new ResponseData();
                SessionManager.deleteZoomSession(session, rd);

                if(!rd.isSuccess) {
                    errors.add(new Integration_Error__c(
                        Error_Message__c = 'Session Id : ' + session.Id + '  ' + rd.errMsg,
                        Http_Response_Body__c = JSON.serialize(rd.results.get('resBody')),
                        Type__c = 'Zoom Session Queueable Update'
                    ));
                }
            }
        }

        if(!remainingSessions.isEmpty()){
            System.enqueueJob(new DeleteZoomSessionQueueable(remainingSessions));
        }

        if(!errors.isEmpty()) {
            insert errors;
        }
    }
}