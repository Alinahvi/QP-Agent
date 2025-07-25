// SlackMessenger.cls
public class AB_SlackMessenger {
    
    // Updated method signature to include thread_ts
    @future(callout=true)
    public static void postMessage(String channelId, String messageText, String thread_ts) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://slack.com/api/chat.postMessage');
        req.setMethod('POST');
        
        req.setHeader('Authorization', 'Bearer ' + 'xoxb-4909201991235-8635412316529-IpojPfCxNvoUrpwDMiOUk5qK'); 
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        
        Map<String, Object> bodyMap = new Map<String, Object>{
            'channel' => channelId,
            'text' => messageText
        };
        
        // If a thread_ts is provided, add it to the request body
        if (String.isNotBlank(thread_ts)) {
            bodyMap.put('thread_ts', thread_ts);
        }
        
        req.setBody(JSON.serialize(bodyMap));
        
        Http http = new Http();
        if(!Test.isRunningTest()){
            try {
                HttpResponse res = http.send(req);
                if (res.getStatusCode() != 200) {
                    System.debug('Slack API Error: ' + res.getBody());
                }
            } catch (Exception e) {
                System.debug('Error sending Slack message: ' + e.getMessage());
            }
        }
    }
}