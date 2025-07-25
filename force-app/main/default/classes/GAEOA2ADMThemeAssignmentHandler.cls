/**
 * @description Handles CRUD operations for Theme Assignment records (agf__ADM_Theme_Assignment__c).
 * This object creates a junction between a Theme and other objects like Project or Epic,
 * allowing for many-to-many relationships.
 */
public with sharing class GAEOA2ADMThemeAssignmentHandler {

    // Inner classes to define the structure of the request and response
    public class Request {
        @InvocableVariable(label='Action' description='The action to perform (Create, Modify).' required=true)
        public String action;

        @InvocableVariable(label='Theme Assignments' description='A list of Theme Assignment records to process.' required=true)
        public List<ThemeAssignmentWrapper> themeAssignments;
    }

    public class ThemeAssignmentWrapper {
        @InvocableVariable(label='Theme Assignment ID' description='The ID of the record for modifications.')
        public String Id;
        @InvocableVariable(label='Theme ID' description='The ID of the related Theme.')
        public String themeId;
        @InvocableVariable(label='Work ID' description='The ID of the related Work record.')
        public String workId;
        @InvocableVariable(label='Epic ID' description='The ID of the related Epic record.')
        public String epicId;
        @InvocableVariable(label='Intake ID' description='The ID of the related Intake record.')
        public String intakeId;
        @InvocableVariable(label='Project ID' description='The ID of the related Project record.')
        public String projectId;
    }

    public class Response {
        @InvocableVariable(label='Success' description='Indicates whether the operation was successful.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='Provides a summary of the operation results.')
        public String message = '';
        @InvocableVariable(label='Theme Assignments' description='A list of the processed Theme Assignment records.')
        public List<agf__ADM_Theme_Assignment__c> themeAssignments = new List<agf__ADM_Theme_Assignment__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Theme Assignments' description='Handles Create and Modify for Theme Assignment records.')
    public static List<Response> manageThemeAssignments(List<Request> requests) {
        List<agf__ADM_Theme_Assignment__c> recordsToCreate = new List<agf__ADM_Theme_Assignment__c>();
        List<agf__ADM_Theme_Assignment__c> recordsToUpdate = new List<agf__ADM_Theme_Assignment__c>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            if (req.themeAssignments == null || req.themeAssignments.isEmpty()) {
                res.message = 'Error: Theme Assignment data is missing.';
                continue;
            }

            for (ThemeAssignmentWrapper wrap : req.themeAssignments) {
                if ('Create'.equalsIgnoreCase(req.action)) {
                    recordsToCreate.add(fromWrapper(wrap));
                } else if ('Modify'.equalsIgnoreCase(req.action)) {
                    if (String.isBlank(wrap.Id)) {
                        res.message = 'Error: Theme Assignment ID is required for modification.';
                    } else {
                        recordsToUpdate.add(fromWrapper(wrap));
                    }
                } else {
                    res.message = 'Error: Invalid action specified: ' + req.action;
                }
            }
             if(res.message.startsWith('Error:')){
                recordsToUpdate.clear();
            }
        }

        if (!recordsToCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(recordsToCreate, false);
            handleSaveResults(responseMap, requests, recordsToCreate, createResults, 'Create');
        }
        if (!recordsToUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(recordsToUpdate, false);
            handleSaveResults(responseMap, requests, recordsToUpdate, updateResults, 'Modify');
        }

        return responseMap.values();
    }
    
    private static void handleSaveResults(Map<Integer, Response> responseMap, List<Request> requests, List<agf__ADM_Theme_Assignment__c> records, Database.SaveResult[] saveResults, String action) {
        Integer recordIndexOffset = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            if (!action.equalsIgnoreCase(req.action) || req.themeAssignments == null) continue;

            Response res = responseMap.get(i);
            if (res.message.startsWith('Error:')) continue;

            Boolean allSuccess = true;
            List<String> errorMessages = new List<String>();

            for(Integer j = 0; j < req.themeAssignments.size(); j++){
                Integer currentIndex = recordIndexOffset + j;
                if(currentIndex < saveResults.size()){
                    Database.SaveResult sr = saveResults[currentIndex];
                    if (sr.isSuccess()) {
                        res.themeAssignments.add(records[currentIndex]);
                    } else {
                        allSuccess = false;
                        errorMessages.add(sr.getErrors()[0].getMessage());
                    }
                }
            }

            res.success = allSuccess;
            if(allSuccess){
                 res.message = 'All ' + req.themeAssignments.size() + ' record(s) ' + action.toLowerCase() + 'd successfully.';
            } else {
                 res.message = 'Errors during ' + action + ': ' + String.join(errorMessages, '; ');
            }
            
            recordIndexOffset += req.themeAssignments.size();
        }
    }

    private static agf__ADM_Theme_Assignment__c fromWrapper(ThemeAssignmentWrapper wrap) {
        agf__ADM_Theme_Assignment__c ta = new agf__ADM_Theme_Assignment__c();
        if (String.isNotBlank(wrap.Id)) {
            ta.Id = wrap.Id;
        }
        ta.agf__Theme__c = wrap.themeId;
        ta.agf__Work__c = wrap.workId;
        ta.Epic__c = wrap.epicId;
        ta.Intake__c = wrap.intakeId;
        ta.Project__c = wrap.projectId;
        return ta;
    }
}