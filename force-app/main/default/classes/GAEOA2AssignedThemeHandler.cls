/**
 * @description Handles CRUD operations for Assigned Theme records (Assigned_Theme__c).
 * This object serves as a junction to link a Theme to various other records within the system.
 */
public with sharing class GAEOA2AssignedThemeHandler {
    private static final String SOBJECT_TYPE = 'Assigned_Theme__c';
    private static final String SOBJECT_TYPE_LABEL = 'Assigned Theme';

    public class Request {
        @InvocableVariable(label='Action' description='The action to perform (Create, Modify).' required=true)
        public String action;

        @InvocableVariable(label='Assigned Themes' description='A list of Assigned Theme records to process.' required=true)
        public List<AssignedThemeWrapper> assignedThemes;
    }

    public class AssignedThemeWrapper {
        @InvocableVariable(label='Assigned Theme ID' description='The ID of the record for modifications.')
        public String Id;
        @InvocableVariable(label='Deliverable ID' description='The ID of the related Deliverable.')
        public String deliverableId;
        @InvocableVariable(label='Epic ID' description='The ID of the related Epic.')
        public String epicId;
        @InvocableVariable(label='Intake ID' description='The ID of the related Intake.')
        public String intakeId;
        @InvocableVariable(label='Program ID' description='The ID of the related Program.')
        public String programId;
        @InvocableVariable(label='Program Menu ID' description='The ID of the related Program Menu.')
        public String programMenuId;
        @InvocableVariable(label='Project ID' description='The ID of the related Project.')
        public String projectId;
        @InvocableVariable(label='Theme ID' description='The ID of the related Theme.')
        public String themeId;
        @InvocableVariable(label='Work ID' description='The ID of the related Work.')
        public String workId;
    }

    public class Response {
        @InvocableVariable(label='Success' description='Indicates whether the operation was successful.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='Provides a summary of the operation results.')
        public String message = '';
        @InvocableVariable(label='Assigned Themes' description='A list of the processed Assigned Theme records.')
        public List<Assigned_Theme__c> assignedThemes = new List<Assigned_Theme__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Assigned Themes' description='Handles Create and Modify for Assigned Theme records.')
    public static List<Response> manageAssignedThemes(List<Request> requests) {
        List<Assigned_Theme__c> recordsToCreate = new List<Assigned_Theme__c>();
        List<Assigned_Theme__c> recordsToUpdate = new List<Assigned_Theme__c>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            if (req.assignedThemes == null || req.assignedThemes.isEmpty()) {
                res.message = 'Error: Assigned Theme data is missing.';
                continue;
            }

            for (AssignedThemeWrapper wrap : req.assignedThemes) {
                if ('Create'.equalsIgnoreCase(req.action)) {
                    recordsToCreate.add(fromWrapper(wrap));
                } else if ('Modify'.equalsIgnoreCase(req.action)) {
                    if (String.isBlank(wrap.Id)) {
                        res.message = 'Error: Assigned Theme ID is required for modification.';
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
    
    private static void handleSaveResults(Map<Integer, Response> responseMap, List<Request> requests, List<Assigned_Theme__c> records, Database.SaveResult[] saveResults, String action) {
        Integer recordIndexOffset = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            if (!action.equalsIgnoreCase(req.action) || req.assignedThemes == null) continue;

            Response res = responseMap.get(i);
            if (res.message.startsWith('Error:')) continue;

            Boolean allSuccess = true;
            List<String> errorMessages = new List<String>();

            for(Integer j = 0; j < req.assignedThemes.size(); j++){
                Integer currentIndex = recordIndexOffset + j;
                if(currentIndex < saveResults.size()){
                    Database.SaveResult sr = saveResults[currentIndex];
                    if (sr.isSuccess()) {
                        res.assignedThemes.add(records[currentIndex]);
                    } else {
                        allSuccess = false;
                        errorMessages.add(sr.getErrors()[0].getMessage());
                    }
                }
            }

            res.success = allSuccess;
            if(allSuccess){
                 res.message = 'All ' + req.assignedThemes.size() + ' record(s) ' + action.toLowerCase() + 'd successfully.';
            } else {
                 res.message = 'Errors during ' + action + ': ' + String.join(errorMessages, '; ');
            }
            
            recordIndexOffset += req.assignedThemes.size();
        }
    }

    private static Assigned_Theme__c fromWrapper(AssignedThemeWrapper wrap) {
        Assigned_Theme__c at = new Assigned_Theme__c();
        if (String.isNotBlank(wrap.Id)) {
            at.Id = wrap.Id;
        }
        at.Deliverable__c = wrap.deliverableId;
        at.Epic__c = wrap.epicId;
        at.Intake__c = wrap.intakeId;
        at.Program__c = wrap.programId;
        at.Program_Menu__c = wrap.programMenuId;
        at.Project__c = wrap.projectId;
        at.Theme__c = wrap.themeId;
        at.Work__c = wrap.workId;
        return at;
    }
}