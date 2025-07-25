// AB_SlackActionReceiver.cls
@RestResource(urlMapping='/slack/actions/*')
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AB_SlackActionReceiver {

    @HttpPost
    global static void handleAction() {
        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();

        Map<String, String> params = new Map<String, String>();
        List<String> bodyParts = requestBody.split('&');
        for (String part : bodyParts) {
            List<String> paramParts = part.split('=');
            if (paramParts.size() == 2) {
                params.put(paramParts[0], EncodingUtil.urlDecode(paramParts[1], 'UTF-8'));
            }
        }
        
        String command = params.get('command');
        String text = params.get('text');
        String channelId = params.get('channel_id');
        
        if (command == '/agent') {
            String ackMessage = 'Acknowledged your command: ' + text;
            
            // Calling the updated method. Pass null for thread_ts for now.
            AB_SlackMessenger.postMessage(channelId, ackMessage, null);
        }
    }
}