public with sharing class UploadSessionRolesByCsv {

    @AuraEnabled
    public static ResponseData processEmails(String jsonString){
        ResponseData rd = new ResponseData();
       
        try {
            SessionRolesPayload payload = (SessionRolesPayload) JSON.deserialize(jsonString, SessionRolesPayload.class);

            Map<String, String> rolesByEmail = new Map<String, String>();
            Integer numHosts = 0;
            Boolean hostsInvalid = false;

            for (CsvData csvData : payload.csvData) {
                rolesByEmail.put(csvData.email, csvData.role);

                if (csvData.role == 'Host') {
                    numHosts++;
                }
            }

            hostsInvalid = numHosts > 1;

            Set<String> newEmails = new Set<String>(rolesByEmail.keySet());

            List<Map<String, Object>> newLPs = new List<Map<String, Object>>();
            List<Map<String, Object>> existingLPs = new List<Map<String, Object>>();
            List<Map<String, Object>> invalidLps = new List<Map<String, Object>>();

            String sessionType = [SELECT Session_Type__c FROM Session__c WHERE Id = :payload.sessionId WITH USER_MODE LIMIT 1].Session_Type__c;

            List<Learner_Profile__c> lps = [SELECT Id, Name, User__c, User__r.Name, Primary_Email__c, User__r.SmallPhotoUrl,
                                                ( 
                                                    SELECT Id, Role__c
                                                    FROM Event_Guests__r
                                                    WHERE Session__c =: payload.sessionId
                                                )
                                            FROM Learner_Profile__c
                                            WHERE Primary_Email__c =: newEmails
                                            AND Status__c = 'Active'
                                            WITH USER_MODE
                                            ORDER BY Name ASC];


            for (Learner_Profile__c lp : lps) {
                String currentRole = rolesByEmail.get(lp.Primary_Email__c);

                if (hostsInvalid && currentRole == 'Host') {
                    invalidLps.add(new Map<String, Object>{
                        'Primary_Email__c' => lp.Primary_Email__c, 
                        'Error' => 'Only One Host is Allowed'
                    });

                    newEmails.remove(lp.Primary_Email__c);

                    continue;
                } else if (String.isEmpty(currentRole)) {
                    invalidLps.add(new Map<String, Object>{
                        'Primary_Email__c' => lp.Primary_Email__c, 
                        'Error' => 'Role Not Specified'
                    });

                    newEmails.remove(lp.Primary_Email__c);

                    continue;
                }

                Map<String, Object> lpMap = new Map<String, Object>(lp.getPopulatedFieldsAsMap());
                lpMap.put('Role__c', currentRole);

                if (lp.Event_Guests__r.isEmpty()) {
                    newLPs.add(lpMap);
                } else {
                    Session_Guest__c sg = lp.Event_Guests__r[0];
                    String modified = currentRole != sg.Role__c ? 'Role Changed' : 'No Changes';

                    lpMap.put('modified', modified);
                    lpMap.put('sessionGuestId', sg.Id);
                    existingLPs.add(lpMap);
                }

                newEmails.remove(lp.Primary_Email__c);
            }

            // Learners Not Found
            for (String email : newEmails) {
                invalidLps.add(new Map<String, Object>{'Primary_Email__c' => email, 'Error' => 'Learner Not Found'});
            }
        
            rd.put('newLPs', newLPs);
            rd.put('existingLPs', existingLPs);
            rd.put('invalidLps', invalidLps);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public class SessionRolesPayload {
        public List<CsvData> csvData { get; set; }
        public String sessionId { get; set; }
        public String assetId { get; set; }
        public Integer pageSize { get; set; }
    }

    public class CsvData {
        public String email { get; set; }
        public String role { get; set; }
    }
}