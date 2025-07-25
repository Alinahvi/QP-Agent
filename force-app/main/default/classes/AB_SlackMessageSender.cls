public class AB_SlackMessageSender {

    @future(callout=true)
    public static void sendMessageWithDropdown(String slackUserId) {
        // IMPORTANT: Replace this with your actual Slack Bot Token
        String botToken = 'xoxb-4909201991235-8635412316529-IpojPfCxNvoUrpwDMiOUk5qK';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://slack.com/api/chat.postMessage');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + botToken);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');

        // Build the message payload using Slack's Block Kit
        Map<String, Object> payload = new Map<String, Object>{
            'channel' => slackUserId, // Sends a DM to this user
            'blocks' => new List<Object>{
                // 1. A simple text block
                new Map<String, Object>{
                    'type' => 'section',
                    'text' => new Map<String, Object>{
                        'type' => 'mrkdwn',
                        'text' => 'Hello! Please select a priority for the new offering:'
                    }
                },
                // 2. An "actions" block containing the dropdown
                new Map<String, Object>{
                    'type' => 'actions',
                    'elements' => new List<Object>{
                        new Map<String, Object>{
                            'type' => 'static_select',
                            'placeholder' => new Map<String, Object>{
                                'type' => 'plain_text',
                                'text' => 'Select a priority...'
                            },
                            'action_id' => 'priority_selection_action', // An ID for your handler to identify this action
                            'options' => new List<Object>{
                                new Map<String, Object>{
                                    'text' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'High'},
                                    'value' => 'priority_high'
                                },
                                new Map<String, Object>{
                                    'text' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Medium'},
                                    'value' => 'priority_medium'
                                },
                                new Map<String, Object>{
                                    'text' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Low'},
                                    'value' => 'priority_low'
                                }
                            }
                        }
                    }
                }
            }
        };

        req.setBody(JSON.serialize(payload));

        // Send the request
        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('Slack API Response: ' + res.getBody());
        } catch (Exception e) {
            System.debug('Error sending Slack message: ' + e.getMessage());
        }
    }
}