public with sharing class AB_APM_Nomination_Form {
    // Invocable input class
    public class NominationFormInput {
        @InvocableVariable(label='Utterance' required=true)
        public String utterance;
    }
    // Invocable output class
    public class NominationFormOutput {
        @InvocableVariable(label='Success')
        public Boolean success;
        @InvocableVariable(label='Message')
        public String message;
    }
    // Invocable method for Flow/Action
    @InvocableMethod(label='Send APM Nomination Form on Utterance' description='Triggers the APM Nomination Form if the utterance matches nomination intent')
    public static List<NominationFormOutput> submitNominationForm(List<NominationFormInput> inputs) {
        List<NominationFormOutput> results = new List<NominationFormOutput>();
        for (NominationFormInput input : inputs) {
            NominationFormOutput output = new NominationFormOutput();
            try {
                if (input.utterance != null &&
                    (input.utterance.toLowerCase().contains('nominate') ||
                     input.utterance.toLowerCase().contains('i want to nominate'))
                ) {
                    // TODO: Replace with logic to determine Slack user from utterance or context
                    String slackUserId = 'U05FP8CPW04'; // Placeholder/test Slack user ID
                    sendNominationForm(slackUserId);
                    output.success = true;
                    output.message = 'Nomination intent detected. Form sent to Slack user.';
                } else {
                    output.success = false;
                    output.message = 'No nomination intent detected in utterance.';
                }
            } catch (Exception e) {
                output.success = false;
                output.message = 'Error: ' + e.getMessage();
            }
            results.add(output);
        }
        return results;
    }
    public static void triggerForm(String slackUserId) {
        sendNominationForm(slackUserId);
    }
    @future(callout=true)
    public static void sendNominationForm(String slackUserId) {
        // 1. Query 5 unique records from each object
        List<Curriculum__c> curricula = [SELECT Id, Name, Primary_Category__c FROM Curriculum__c WHERE Status__c = 'Active' LIMIT 5];
        List<Session__c> sessions = [SELECT Id, Name FROM Session__c WHERE Status__c = 'Active' LIMIT 5];
        List<Course__c> courses = [SELECT Id, Name, Primary_Category__c FROM Course__c WHERE Status__c = 'Active' LIMIT 5];
        List<Asset__c> assets = [SELECT Id, Name, Primary_Category__c FROM Asset__c WHERE Status__c = 'Active' LIMIT 5];

        List<Object> offeringOptions = new List<Object>();
        for (Curriculum__c c : curricula) {
            String displayName = c.Name;
            if (displayName.length() > 75) {
                displayName = displayName.substring(0, 75);
            }
            offeringOptions.add(new Map<String, Object>{
                'text' => new Map<String, Object>{'type' => 'plain_text', 'text' => displayName},
                'value' => 'Curriculum__c:' + c.Id
            });
        }
        for (Session__c s : sessions) {
            String displayName = s.Name;
            if (displayName.length() > 75) {
                displayName = displayName.substring(0, 75);
            }
            offeringOptions.add(new Map<String, Object>{
                'text' => new Map<String, Object>{'type' => 'plain_text', 'text' => displayName},
                'value' => 'Session__c:' + s.Id
            });
        }
        for (Course__c c : courses) {
            String displayName = c.Name;
            if (displayName.length() > 75) {
                displayName = displayName.substring(0, 75);
            }
            offeringOptions.add(new Map<String, Object>{
                'text' => new Map<String, Object>{'type' => 'plain_text', 'text' => displayName},
                'value' => 'Course__c:' + c.Id
            });
        }
        for (Asset__c a : assets) {
            String displayName = a.Name;
            if (displayName.length() > 75) {
                displayName = displayName.substring(0, 75);
            }
            offeringOptions.add(new Map<String, Object>{
                'text' => new Map<String, Object>{'type' => 'plain_text', 'text' => displayName},
                'value' => 'Asset__c:' + a.Id
            });
        }

        // 2. Program Type dropdown values
        List<String> programTypeDropdown = new List<String>{
            'Skills', 'Globally Required Learning', 'Do My Job', 'Fast Start',
            'Learning Circles', 'Product Immersion', 'Other',
            'Excellence Academies', 'Product & Industry', 'CVI Win Room',
            'Program & Industry', 'Negotiate Success',
            'Storytelling in Business', 'Effective Sales Prospecting',
            'Impactful Executive Communication', 'Strategic Consulting',
            'Salesfuel', 'Customer Centric Discovery', 'CxO', 'Demo2Win'
        };
        List<Object> programTypeOptions = new List<Object>();
        for (String val : programTypeDropdown) {
            programTypeOptions.add(new Map<String, Object>{
                'text' => new Map<String, Object>{'type' => 'plain_text', 'text' => val},
                'value' => val
            });
        }

        // 3. Enablement Tool dropdown options
        List<String> enablementToolDropdown = new List<String>{'Course', 'Curriculum', 'Asset', 'Session'};
        List<Object> enablementToolOptions = new List<Object>();
        for (String val : enablementToolDropdown) {
            enablementToolOptions.add(new Map<String, Object>{
                'text' => new Map<String, Object>{'type' => 'plain_text', 'text' => val},
                'value' => val
            });
        }

        // 4. Build Slack Block Kit payload
        List<Object> blocks = new List<Object>{
            new Map<String, Object>{
                'type' => 'section',
                'text' => new Map<String, Object>{'type' => 'mrkdwn', 'text' => 'Please fill out the APM Nomination Form:'}
            },
            // Offering Name dropdown (required)
            new Map<String, Object>{
                'type' => 'input',
                'block_id' => 'offering_name_block',
                'label' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Offering Name'},
                'element' => new Map<String, Object>{
                    'type' => 'static_select',
                    'action_id' => 'offering_name_action',
                    'placeholder' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Select an offering...'},
                    'options' => offeringOptions
                },
                'optional' => false
            },
            // Program Type (required)
            new Map<String, Object>{
                'type' => 'input',
                'block_id' => 'program_type_block',
                'label' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Program Type'},
                'element' => new Map<String, Object>{
                    'type' => 'static_select',
                    'action_id' => 'program_type_action',
                    'placeholder' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Select or will be auto-populated...'},
                    'options' => programTypeOptions
                },
                'optional' => false
            },
            // Enablement Tool dropdown (required)
            new Map<String, Object>{
                'type' => 'input',
                'block_id' => 'enablement_tool_block',
                'label' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Enablement Tool'},
                'element' => new Map<String, Object>{
                    'type' => 'static_select',
                    'action_id' => 'enablement_tool_action',
                    'placeholder' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Select an enablement tool...'},
                    'options' => enablementToolOptions
                },
                'optional' => false
            },
            // Start Date (required)
            new Map<String, Object>{
                'type' => 'input',
                'block_id' => 'start_date_block',
                'label' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Start Date'},
                'element' => new Map<String, Object>{
                    'type' => 'datepicker',
                    'action_id' => 'start_date_action',
                    'placeholder' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Select a start date'}
                },
                'optional' => false
            },
            // End Date (required)
            new Map<String, Object>{
                'type' => 'input',
                'block_id' => 'end_date_block',
                'label' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'End Date'},
                'element' => new Map<String, Object>{
                    'type' => 'datepicker',
                    'action_id' => 'end_date_action',
                    'placeholder' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Select an end date'}
                },
                'optional' => false
            },
            // Notes (optional, slightly wider)
            new Map<String, Object>{
                'type' => 'input',
                'block_id' => 'notes_block',
                'label' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Notes'},
                'element' => new Map<String, Object>{
                    'type' => 'plain_text_input',
                    'action_id' => 'notes_action',
                    'placeholder' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Enter any notes...'},
                    'multiline' => false,
                    'min_length' => 0,
                    'max_length' => 300
                },
                'optional' => true
            },
            // Submit button
            new Map<String, Object>{
                'type' => 'actions',
                'elements' => new List<Object>{
                    new Map<String, Object>{
                        'type' => 'button',
                        'text' => new Map<String, Object>{'type' => 'plain_text', 'text' => 'Submit'},
                        'action_id' => 'submit_nomination_form',
                        'style' => 'primary'
                    }
                }
            }
        };

        // 5. Send the form to Slack
        String botToken = 'xoxb-4909201991235-8635412316529-IpojPfCxNvoUrpwDMiOUk5qK';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://slack.com/api/chat.postMessage');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + botToken);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        Map<String, Object> payload = new Map<String, Object>{
            'channel' => slackUserId,
            'blocks' => blocks,
            'text' => 'APM Nomination Form'
        };
        req.setBody(JSON.serialize(payload));
        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('Slack API Response: ' + res.getBody());
        } catch (Exception e) {
            System.debug('Error sending Slack form: ' + e.getMessage());
        }
    }
}