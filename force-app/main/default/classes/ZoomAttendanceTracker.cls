@RestResource(urlMapping='/attendance/*')
global without sharing class ZoomAttendanceTracker {
    private static Map<String, Object> event;
    /*
        Zoom will post a meeting/webinar even ended. Check if the event relates to any ACT Session based on the Zoom Id.
        If it exists mark the session as needing reports to be processed so that the zoomAttendanceBatch will pick it up
    */
    @HttpPost
    global static void trackAttendance() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(req.requestBody)).toString();
                    
        event = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        String eventType = (String)event.get('event');
        String responsePayload = '';

        if(eventType == 'endpoint.url_validation'){
            res.responseBody = Blob.valueOf(JSON.serialize(validateEndpoint()));
        } else if(eventType == 'webinar.ended' || eventType == 'meeting.ended'){
            processZoomEvent();
        }
    }

    private static Map<String, Object> validateEndpoint(){
        Map<String, Object> payload = (Map<String,Object>)event.get('payload');
        String plainToken = (String)payload.get('plainToken');
        String key = constants.ZOOM_VALIDATION_TOKEN;

        Blob mac = Crypto.generateMac('HmacSHA256', Blob.valueOf(plainToken), Blob.valueOf(key));
        String encryptedToken = EncodingUtil.convertToHex(mac);


        Map<String, Object> responsePayload = new Map<String, Object>{
            'plainToken' => plainToken,
            'encryptedToken' => encryptedToken
        };


        return responsePayload;
    }

    private static void processZoomEvent(){
        String meetingId;
        String parentId;
        
        try{
            String eventType = (String)event.get('event');
            String zoomType = eventType == 'webinar.ended' ? 'webinars' : 'meetings';
            Map<String, Object> payload = (Map<String, Object>)event.get('payload');
            Map<String, Object> objectMap = (Map<String, Object>)payload.get('object');
            meetingId = (String)objectMap.get('id');
            String hostId = (String)objectMap.get('host_id');
            sObject parentSession = withoutSharingUtilities.findZoomSession(meetingId);

            if(parentSession == null){
                return;
            }

            parentSession.put('Process_Zoom_Report__c', true);
            parentSession.put('Total_Zoom_Report_Retries__c', 0);
            parentSession.put('Zoom_Host_Id__c', hostId);

            withoutSharingUtilities.updateRecords(new List<sObject>{parentSession});
        } catch(Exception e){
            String parentType = '';

            if(parentId != null){
                parentType = '' + (Id.valueOf(parentId)).getSObjectType();
            }

            System.debug('******** error ' +  e.getMessage());
            System.debug('******** stack ' +  e.getStackTraceString());

            insert as user new Integration_Error__c(
                Type__c = 'Session_Attendance',
                Error_Message__c = 'Zoom Attendance webhook for ' + parentType + ' with ID ' + parentId + ' and meeting ' + meetingId + ' errored on line: ' + e.getLineNumber() + '\n\n' + e.getMessage()
            );
        }
    }
}