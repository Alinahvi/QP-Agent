@RestResource(urlMapping='/slack/nomination')
global with sharing class SlackNominationRestResource {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        String payload = req.requestBody.toString();

        // Slack sends payload as url-encoded, so parse if needed
        if (payload != null && payload.startsWith('payload=')) {
            payload = EncodingUtil.urlDecode(payload.substring(8), 'UTF-8');
        }

        // Call the handler
        Id nominationId;
        try {
            nominationId = AB_APMNominationFormHandler.processSlackNominationForm(payload);
        } catch (Exception e) {
            System.debug('Error processing Slack nomination: ' + e.getMessage());
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('{"ok":false, "error":"' + e.getMessage() + '"}');
            return;
        }

        // Respond to Slack
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf('{"ok":true, "id":"' + String.valueOf(nominationId) + '"}');
    }
}