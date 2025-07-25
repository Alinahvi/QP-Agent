public with sharing class ThCompletionBatchHelper {
    public static List<String> learnersWithErrors = new List<String>();
    public static List<Learner_Profile__c> learnersWithoutErrors = new List<Learner_Profile__c>();
    public static List<Assignment__c> assignmentsToUpdate = new List<Assignment__c>();
    public static List<Integration_Error__c> errorList = new List<Integration_Error__c>();

    public static void checkThCompletion(List<Learner_Profile__c> scope, String accessToken) {
        Boolean isBatch = true;
        // for(Learner_Profile__c lp : scope) {
        for(Learner_Profile__c lp : [SELECT Id, Name, User__r.Email, User__r.Org62_User_ID__c, Org62_User_ID__c, Last_Trailhead_Sync__c, 
                                        (
                                            SELECT Id, Completion_Date__c, Asset__r.Trailhead_Module_Id__c, Completed__c
                                            FROM Assignments__r
                                            WHERE Completed__c = false
                                            AND Inactive__c = false
                                            AND Asset__r.RecordType.DeveloperName = 'Trailhead_Module'
                                            AND CreatedDate != today
                                            ORDER BY lastModifiedDate DESC 
                                            LIMIT 1500                                           
                                        )
                                    FROM Learner_Profile__c
                                    WHERE Id IN: scope]) {
            try {
                thHelper(lp, isBatch, accessToken);
                if(Limits.getCallouts() == (Limits.getLimitCallouts()-1)) {
                    break;
                }
            } catch(Exception e) {
                Integration_Error__c errorObj = new Integration_Error__c(
                    Http_Response_Body__c = 'Assignee User Id: ' + lp.Id + ' because ' + e.getMessage() + ' at line ' + e.getLineNumber(),
                    Type__c = 'TH-SYNC'
                    );
                errorList.add(errorObj);
            }
        }

        if(!learnersWithoutErrors.isEmpty()) {
            try {
                update as user learnersWithoutErrors;
            } catch(Exception e) {
                Integration_Error__c errorObj = new Integration_Error__c(
                    Http_Response_Body__c = 'Error: While updating LP: because ' + e.getMessage() + ' at line ' + e.getLineNumber(),
                    Type__c = 'TH-SYNC'
                );
                errorList.add(errorObj);
            }
        }

        if(!assignmentsToUpdate.isEmpty()) {
            try {
                update as user assignmentsToUpdate;
            } catch(Exception e) {
                Integration_Error__c errorObj = new Integration_Error__c(
                    Http_Response_Body__c = 'Error: While updating Assignments: because ' + e.getMessage() + ' at line ' + e.getLineNumber(),
                    Type__c = 'TH-SYNC'
                );
                errorList.add(errorObj);
            }
        }

        if(errorList.isEmpty()) {
            try {
                insert as user errorList;
            } catch(Exception e) {
                Integration_Error__c errorObj = new Integration_Error__c(
                    Http_Response_Body__c = 'Error: While updating Error List: because ' + e.getMessage() + ' at line ' + e.getLineNumber(),
                    Type__c = 'TH-SYNC'
                );
                insert errorObj;
            }
        }
    }

    public static ResponseData refreshThCompletion(List<Learner_Profile__c> scope) {
        ResponseData rd = new ResponseData();
        Boolean isBatch = false;
        try{
            for(Learner_Profile__c lp : scope) {
                thHelper(lp, isBatch);
            }
            if(!assignmentsToUpdate.isEmpty()) {
                update as user assignmentsToUpdate;
            }           
            if(!learnersWithErrors.isEmpty()) {
                rd.addError(String.format(System.Label.th_sync_failed, new List<Object>{(learnersWithErrors.size() > 1 ? 's' : ''), String.join(learnersWithErrors, ', ')}));
            } else {
                update as user learnersWithoutErrors;
                rd.put('isSynced', true);
                rd.put('syncMsg', 'Successfully updated Trailheads');
            }

            if(!errorList.isEmpty()) {
                insert as user errorList;                
            }

        } catch(Exception e) {
            rd.addError('Cannot sync because ' + e.getMessage().uncapitalize());
            System.debug('Error :: '+e.getMessage() + ' at line ' + e.getLineNumber());
        }
        return rd;
    }

    public static void thHelper(Learner_Profile__c lp, Boolean isBatch) {
        thHelper(lp, isBatch, null);
    }

    public static void thHelper(Learner_Profile__c lp, Boolean isBatch, String accessToken) {
        Map<String, String> headers = new Map<String, String>();
        Map<String, Object> body = new Map<String, Object>();
        body.put('sfids',  new List<String>{(String)lp.User__r.Org62_User_ID__c});
              
        if(String.isEmpty(accessToken)) {
            accessToken = Utilities.getAccessTokenFromRefresh();
        }
        // String accessToken = Utilities.getAccessTokenFromRefresh();
        /* if(String.isEmpty(accessToken)) {
            Integration_Error__c errorObj = new Integration_Error__c(
                Error_Message__c = 'Failed to update Trailhead completion for User ' + lp.Id,
                Http_Response_Body__c = System.Label.th_accesstoken_error
            );
            errorList.add(errorObj);
            return;
        } */
        headers.put('Authorization', 'Bearer ' + accessToken);
        headers.put('X-Api-Key', Constants.TRAILHEAD_API_KEY);
        HttpResponse res = Utilities.makeCallout(Constants.TRAILHEAD_API_USER_SEARCH, 'POST', JSON.serialize(body), headers);
        if(res.getStatusCode() == 200) {
            system.debug('RES body  -------- '+res.getBody());
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(parsedRes.containsKey('errorCode')) {
                if(!isBatch) {
                    learnersWithErrors.add(lp.Id);
                } else {
                    Integration_Error__c errorObj = new Integration_Error__c(
                        Error_Message__c = (String)parsedRes.get('message') + ' Assignee User Id: ' + lp.Id,
                        Http_Response_Body__c = res.getBody()
                    );
                    errorList.add(errorObj);
                }
            } else {
                learnersWithoutErrors.add(new Learner_Profile__c(Id = lp.Id, Last_Trailhead_Sync__c = DateTime.now()));
                List<Object> data = (List<Object>)parsedRes.get('data');
                Map<String, Object> user = (Map<String, Object>)data.get(0);
                List<Object> modules = (List<Object>)user.get('modules');
                Map<String, Map<String, Object>> thDataByTHId = new Map<String, Map<String, Object>>();
                // Set<String> moduleIds = new Set<String>();

                for(Object module : modules) {
                    Map<String, Object> moduleMap = (Map<String, Object>)module;
                    String status = ((String)moduleMap.get('status')).toLowerCase();
                    if(status == 'completed') {
                        String thId = String.valueOf(moduleMap.get('api_name'));
                        thDataByTHId.put(thId, moduleMap);
                        // moduleIds.add(thId);
                    }
                }
                for(Assignment__c assignment : lp.Assignments__r) {
                    Map<String, Object> thData = thDataByTHId.get(assignment.Asset__r.Trailhead_Module_Id__c);
                    if(thData != null) {
                        String status = ((String)thData.get('status')).toLowerCase();
                        Boolean isCompleted = status == 'completed';
                        if(isCompleted && !assignment.Completed__c) {
                            assignmentsToUpdate.add(new Assignment__c(
                                Id = assignment.Id,
                                Completion_Date__c = Date.today(),
                                Completed__c = true
                            ));                        
                        }
                    }                    
                }
            }
        } else {
            system.debug('ERROR body  -------- '+res.getBody());
            Integration_Error__c errorObj = new Integration_Error__c(
                Error_Message__c = 'Failed to update Trailhead completion for User ' + lp.Id,
                Http_Response_Body__c = res.getBody(),
                Type__c = 'TH-SYNC'
            );
            errorList.add(errorObj);
        }
    }

}