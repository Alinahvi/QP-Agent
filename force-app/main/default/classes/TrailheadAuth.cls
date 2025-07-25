public with sharing class TrailheadAuth {
    @AuraEnabled(cacheable=true)
    public static string getInitData(){
        responseData rd = new responseData();

        try {
            Auth_Setting__c authSetting = Auth_Setting__c.getOrgDefaults();
            
            rd.put('authed', authSetting.Refresh_Token__c != null);
            rd.put('clientId', Constants.CLIENT_ID);
        } catch (Exception e) {
            rd.addError(e);
        }
        System.debug('Constants.CLIENT_ID -------- '+Constants.CLIENT_ID);
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String doOauth(String code){
        responseData rd = new responseData();

        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();

            String connectionEndpoint = 'https://login.salesforce.com/services/oauth2/token';
            String clientId = Constants.CLIENT_ID;
            String clientSecret = Constants.CLIENT_SECRET;
            String redirectUrl = Constants.PUBLIC_SITE_REDIRECT_URL;

            req.setMethod('POST');
            req.setEndpoint(connectionEndpoint);
            req.setBody('grant_type=authorization_code&client_id=' + clientId + '&client_secret=' + clientSecret + '&redirect_uri=' + redirectUrl + '&code=' + code);

            res = http.send(req);

            if(res.getStatusCode() == 200){
                Map <String,Object> responseBody = (Map <String, Object>)JSON.deserializeUntyped(res.getBody());
                String refreshToken = (String)responseBody.get('refresh_token');

                Auth_Setting__c authSetting = Auth_Setting__c.getOrgDefaults();
                authSetting.Refresh_Token__c = refreshToken;

                upsert authSetting;
            } else {
                Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                rd.addError((String)parsedRes.get('error_description'));

                // Integration_Error__c errorObj = new Integration_Error__c(
                //     Error_Message__c = (String)parsedRes.get('error_description'),
                //     Http_Response_Body__c = res.getBody()
                // );

                // insert errorObj;
            }
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }
}