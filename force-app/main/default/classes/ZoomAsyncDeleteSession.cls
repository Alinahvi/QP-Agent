public class ZoomAsyncDeleteSession implements Queueable, Database.AllowsCallouts {
    public List<Session__c> sessions;

    public ZoomAsyncDeleteSession(List<Session__c> sessions) {
        this.sessions = sessions;
    }

    public void execute(QueueableContext context) {
        for (Session__c session : sessions) {
            if (session.Virtual_Type__c == 'Zoom' && !String.isEmpty(session.Zoom_Session_Id__c)) {
                deleteSession(session);
            }
        }
    }

    public static void deleteSession(Session__c session) {
        String endPoint = Constants.ZOOM_BASE_URL + (session.Zoom_Type__c == 'Meeting' ? '/meetings' : '/webinars');
        endPoint += '/' + session.Zoom_Session_Id__c;

        Map<String, String> headers = new Map<String, String>{
            'Authorization' => 'Bearer ' + Utilities.getZoomAccessToken()
        };

        HttpResponse res = Utilities.makeCallout(endPoint, 'DELETE', headers);

        if (res.getStatusCode() != 200 && res.getStatusCode() != 204) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            insert as user new Integration_Error__c(
                Error_Message__c = (String) response.get('message'),
                Http_Response_Body__c = res.getBody(),
                Type__c = 'Zoom Meeting/Webinar Delete Request'
            );
        }
    }
}