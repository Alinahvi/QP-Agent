public with sharing class skillAssessmentListView {

    @AuraEnabled
    public static String initData(){ 
        ResponseData rd = new ResponseData();
        
        try {
            List<Learner_Profile__c> lps = [SELECT Id, People_Manager__c  
                                            FROM Learner_Profile__c
                                            WHERE User__c =: UserInfo.getUserId()
                                            AND Status__c = 'Active'
                                            WITH USER_MODE];
            
            if(lps.isEmpty()){
                rd.addError('No Learner Profile found');
            } else {
                Boolean isManager = lps.get(0).People_Manager__c;
    
                rd.put('isManager', isManager);
                rd.put('assessmentResponses', getResponses('open', isManager));
                rd.put('lpId', lps.get(0).Id);
            }
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd.getJsonString();
    }


    @AuraEnabled
    public static String getAssessmentResponses(String view, Boolean isManager){
        ResponseData rd = new ResponseData();
        
        try {
            rd.put('assessmentResponses', getResponses(view, isManager));
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd.getJsonString();
    }

    public static List<Assessment_Response__c> getResponses(String view, Boolean isManager){
        List<Assessment_Response__c> responses = new List<Assessment_Response__c>();

        String userId = UserInfo.getUserId();
        List<String> allowedStatuses = new List<String>();
        List<String> allowedChildResponseStatuses = new List<String>();
        Set<String> fields = new Set<String>{'Id', 'Assessment__c', 'Assessment__r.Name', 'Assessment__r.Description__c', 'CreatedDate', 'Due_Date__c', 
                                             'Is_Manager__c', 'Status__c', 'Assessment_Taker__r.Name', 'Manager_Response__r.Assessment_Taker__r.Name'};
        String soqlString = 'SELECT ' + String.join(new List<String>(fields), ', ') + 
                            ' FROM Assessment_Response__c';
        String whereClause = '';
        
        if(view == 'open'){ //not started/in progress responsese where the assessee is me and its not a manager response 
            allowedStatuses.add('Not Started');
            allowedStatuses.add('In Progress');

            whereClause += ' WHERE Assessment_Taker__r.User__c = :userId ' +
                            ' AND Status__c = :allowedStatuses' +
                            ' AND Cancelled__c = false';
        } else if (view == 'completed'){ //submitted/completed responsese where the assessee is me and its not a manager response.
            allowedStatuses.add('Completed');
            allowedStatuses.add('Submitted');

            whereClause = ' WHERE Assessment_Taker__r.User__c = :userId AND Status__c = :allowedStatuses';

            // if(!isManager){
            //     whereClause = ' WHERE Assessment_Taker__r.User__c = :userId';
            // } else {//if i'm a manager get the people i'm managing as well
            //     allowedChildResponseStatuses.add('Submitted');
            //     allowedChildResponseStatuses.add('Completed');

            //     whereClause = ' WHERE ((Assessment_Taker__r.User__c = :userId AND Status__c = :allowedStatuses) OR (Status__c = :allowedChildResponseStatuses AND Manager__r.User__c = :userId AND (Manager_Response__r.Status__c = \'Submitted\' OR Manager_Response__r.Status__c = \'Completed\')))';
            // }

            // whereClause += ' AND Is_Manager__c = false';
        } else { //not started/in progress responsese where the assessee is me and it is a manager response
            whereClause += ' WHERE Assessment_Taker__r.User__c = :userId ' +
                           ' AND Is_Manager__c = true';
        }

        soqlString += whereClause;
        soqlString += ' ORDER BY CreatedDate DESC';

        responses = Database.query(soqlString, AccessLevel.USER_MODE);
        return responses;
    }
}