@RestResource(urlMapping='/slack/formSubmit')
global with sharing class AB_APMNominationFormHandler {
    /**
     * Processes a Slack interaction payload and saves the form data to apm_nomination__c.
     * @param payload JSON string from Slack interaction (view_submission or block_actions)
     * @return The Id of the created apm_nomination__c record
     */
    global static Id processSlackNominationForm(String payload) {
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(payload);

        // Try to get state.values from either view.state.values or state.values
        Map<String, Object> state = null;
        if (data.containsKey('view')) {
            Map<String, Object> view = (Map<String, Object>)data.get('view');
            if (view != null && view.containsKey('state')) {
                Map<String, Object> viewState = (Map<String, Object>)view.get('state');
                if (viewState != null && viewState.containsKey('values')) {
                    state = (Map<String, Object>)viewState.get('values');
                }
            }
        }
        if (state == null && data.containsKey('state')) {
            Map<String, Object> stateObj = (Map<String, Object>)data.get('state');
            if (stateObj != null && stateObj.containsKey('values')) {
                state = (Map<String, Object>)stateObj.get('values');
            }
        }
        if (state == null) {
            throw new AuraHandledException('Could not find form state in Slack payload.');
        }

        // Extract values from blocks
        String offeringName = extractBlockValue(state, 'offering_name_block', 'offering_name_action');
        String programType = extractBlockValue(state, 'program_type_block', 'program_type_action');
        String enablementTool = extractBlockValue(state, 'enablement_tool_block', 'enablement_tool_action');
        String startDate = extractBlockValue(state, 'start_date_block', 'start_date_action');
        String endDate = extractBlockValue(state, 'end_date_block', 'end_date_action');
        String notes = extractBlockValue(state, 'notes_block', 'notes_action');

        apm_nomination__c nomination = new apm_nomination__c();
        nomination.Asset_Name_c__c = offeringName;
        nomination.Program_Type__c = programType;
        nomination.Asset_Type_c__c = enablementTool;
        if (startDate != null && startDate != '') nomination.Start_Date__c = Date.valueOf(startDate);
        if (endDate != null && endDate != '') nomination.End_Date__c = Date.valueOf(endDate);
        nomination.Comments_c__c = notes;
        nomination.Date_Nominated_c__c = Date.today();

        // Idempotency check: prevent duplicate inserts for same key fields on the same day
        List<apm_nomination__c> existing = [
            SELECT Id FROM apm_nomination__c
            WHERE Asset_Name_c__c = :offeringName
            AND Asset_Type_c__c = :enablementTool
            AND Date_Nominated_c__c = :Date.today()
            LIMIT 1
        ];

        if (existing.isEmpty()) {
            insert nomination;
            return nomination.Id;
        } else {
            return existing[0].Id;
        }
    }

    @HttpPost
    global static String handleSlackSubmission() {
        RestRequest req = RestContext.request;
        String payload = '';

        // Try to get payload from requestBody (for raw JSON)
        if (req.requestBody != null && req.requestBody.size() > 0) {
            payload = req.requestBody.toString();
            System.debug('Raw payload from requestBody: ' + payload);
            if (payload != null && payload.startsWith('payload=')) {
                payload = EncodingUtil.urlDecode(payload.substring(8), 'UTF-8');
            }
        }

        // If still empty, try to get from params (for x-www-form-urlencoded)
        if (String.isBlank(payload) && req.params != null && req.params.containsKey('payload')) {
            payload = req.params.get('payload');
            System.debug('Payload from params: ' + payload);
        }

        if (String.isBlank(payload)) {
            throw new AuraHandledException('No payload received from Slack.');
        }

        Id recordId = processSlackNominationForm(payload);
        return JSON.serialize(new Map<String, Object>{
            'ok' => true,
            'id' => recordId
        });
    }

    // Helper to extract value from Slack block input
    private static String extractBlockValue(Map<String, Object> state, String blockId, String actionId) {
        if (state == null || !state.containsKey(blockId)) return null;
        Map<String, Object> block = (Map<String, Object>)state.get(blockId);
        if (block == null || !block.containsKey(actionId)) return null;
        Map<String, Object> action = (Map<String, Object>)block.get(actionId);
        if (action == null) return null;

        // Handle different input types
        if (action.containsKey('selected_option')) {
            Map<String, Object> selected = (Map<String, Object>)action.get('selected_option');
            if (selected != null && selected.containsKey('text')) {
                Map<String, Object> textObj = (Map<String, Object>)selected.get('text');
                return (String)textObj.get('text');
            }
            if (selected != null && selected.containsKey('value')) {
                return (String)selected.get('value');
            }
        }
        if (action.containsKey('value')) {
            return (String)action.get('value');
        }
        if (action.containsKey('selected_date')) {
            return (String)action.get('selected_date');
        }
        return null;
    }
}