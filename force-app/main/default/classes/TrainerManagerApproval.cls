public with sharing class TrainerManagerApproval {

    @AuraEnabled(cacheable=true)
    public static ResponseData getData(){
        ResponseData rd = new ResponseData();
        
        try {
            String userId = UserInfo.getUserId();

            List<User> subordinates = [SELECT Id FROM User WHERE ManagerId = :userId AND IsActive = true];
            List<Learner_Profile__c> lps = [SELECT Id, Name,
                                            (
                                                SELECT Id, Session__c, Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.Asset__c,
                                                       Session__r.Session_Type__c, Session__r.Office_Location__r.City__c, Role__c, Session_Role_Status__c,
                                                       Session__r.Asset__r.Name, Session__r.Location__c, From_Scheduler__c
                                                FROM Event_Guests__r
                                                WHERE Session__r.Start_Date__c >= TODAY
                                                AND From_Scheduler__c = true
                                                ORDER BY Session__r.Start_Time_Converted__c, Session__c ASC
                                            )
                                            FROM Learner_Profile__c
                                            WHERE User__c = :subordinates
                                            ORDER BY Name ASC];

            List<Map<String, Object>> fromattedSubordinates = new List<Map<String, Object>>();

            for(Learner_Profile__c lp : lps){
                if(lp.Event_Guests__r.isEmpty()){
                    continue;
                }

                fromattedSubordinates.add(formatSubordinate(lp));
            }

            rd.put('subordinates', fromattedSubordinates);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static Map<String, Object> formatSubordinate(Learner_Profile__c lp){
        Map<String, Object> formattedLp = lp.getPopulatedFieldsAsMap().clone();
        Map<String, List<Object>> sessionGuestsByAssetId = new Map<String, List<Object>>();
        List<Map<String, Object>> events = new List<Map<String, Object>>();

        formattedLp.put('id', lp.Name);
        formattedLp.put('name', lp.Name);
        formattedLp.put('url', '/' + lp.Id);

        for(Session_Guest__c sg : lp.Event_Guests__r){
            TrainerApproval.formattedSessionGuest formattedSessionGuest = new TrainerApproval.formattedSessionGuest(sg, true);
            

            if(sessionGuestsByAssetId.containsKey(sg.Session__r.Asset__c)){
                sessionGuestsByAssetId.get(sg.Session__r.Asset__c).add(formattedSessionGuest);
            } else {
                List<Object> sessionGuests = new List<Object>{formattedSessionGuest};
                Map<String, Object> event = new Map<String, Object>{
                    'id' => UUID.randomUUID().toString(),
                    'assetId' => sg.Session__r.Asset__c,
                    'name' => sg.Session__r.Asset__r.Name,
                    'url' => '/' + sg.Session__r.Asset__c,
                    '_children' => sessionGuests
                };

                events.add(event);
                sessionGuestsByAssetId.put(sg.Session__r.Asset__c, sessionGuests);
            }
        }

        System.debug('*************** ' + sessionGuestsByAssetId);
        
        formattedLp.put('_children', events);

        return formattedLp;
    }
}