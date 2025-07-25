public with sharing class BitlyAsyncQrCodeCreate implements Queueable, Database.AllowsCallouts {
    List<Session__c> records;

    public BitlyAsyncQrCodeCreate(List<Session__c> sessions) {
        this.records = sessions;
    }

    public void execute(QueueableContext context) {
        try {
            List<Session__c> sessions = [SELECT Id, Bitly_QR_Code_Id__c, Attendance_Code_2__c FROM Session__c WHERE Id IN :records AND Bitly_QR_Code_Id__c = null];

            for (Session__c session : sessions) {
                if (session.Attendance_Code_2__c != null) {
                    String longUrl = SessionTriggerHelper.generateSessionDetailUrl(session.Id, session.Attendance_Code_2__c);
            
                    if (String.isNotEmpty(longUrl)) {
                        String qrId = createQrCodeInBitly(longUrl);
                        session.Bitly_QR_Code_Id__c = qrId;
                    }
                } else {
                    insert new Integration_Error__c(
                        Error_Message__c = 'Attendance Code is missing',
                        Type__c = Constants.STATUS_ERROR
                    );
                }
            }

            update sessions;
        } catch (Exception e) {
            insert new Integration_Error__c(
                Error_Message__c = e.getMessage(),
                Type__c = Constants.STATUS_ERROR
            );
        }
    }

    private String createQrCodeInBitly(String longUrl) {
        String qrId = '';

        Map<String, String> headers = new Map<String, String>{
            'Authorization' => 'Bearer ' + Constants.BITLY_API_TOKEN,
            'Accept' => '*/*'
        };

        Map<String, Object> body = new Map<String, Object>{
            'title' => 'Session QR Code',
            'group_guid' => Constants.BITLY_GROUP_GUID,
            'destination' => new Map<String, Object>{
                'long_url' => longUrl
            }
        };

        HttpResponse res =  Utilities.makeCallout(Constants.BITLY_QR_CODE_URL, 'POST', JSON.serialize(body), headers);

        if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
            insert new Integration_Error__c(
                Error_Message__c = res.getBody(),
                Type__c = Constants.STATUS_ERROR,
                Http_Response_Body__c = res.getBody()
            );
        } else {
            Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            qrId = (String)response.get('qrcode_id');
        }

        return qrId;
    }
}