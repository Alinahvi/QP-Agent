public with sharing class UploadLearnersByCSV {

    @AuraEnabled
    public static String processEmails(List<String> emails, String childObj, String parentId, Integer pageSize){
        ResponseData rd = new ResponseData();
        
        try {
            // processEmailPayload payload = (processEmailPayload)JSON.deserialize(jsonString, processEmailclass);

            Set<String> newEmails = new Set<String>(emails);

            List<Learner_Profile__c> newLPs = new List<Learner_Profile__c>();
            List<Learner_Profile__c> duplicateLPs = new List<Learner_Profile__c>();
            List<Map<String, Object>> notFound = new List<Map<String, Object>>();

            String childQuery = '';

            if(childObj == 'Audience_Members__r'){
                childQuery = ',(' +
                                    'SELECT Id' +
                                    ' FROM Audience_Members__r' +
                                    ' WHERE Audience__c = \'' + String.escapeSingleQuotes(parentId) + '\'' +
                             ')';
            } else if(childObj == 'Assignments__r') {
                childQuery = ',(' +
                                    'SELECT Id' +
                                    ' FROM Assignments__r' +
                                    ' WHERE Session__c = \'' + String.escapeSingleQuotes(parentId) + '\'' +
                            ')';
            }

            String soqlQuery = 'SELECT Id, Name, User__c, User__r.Name, Primary_Email__c' + childQuery +
                               ' FROM Learner_Profile__c' +
                               ' WHERE Primary_Email__c =: newEmails' +
                               ' AND Primary_Email__c != null' +
                               ' AND Status__c = \'Active\'' +
                               ' WITH USER_MODE' +
                               ' ORDER BY Name ASC' +
                               ' LIMIT ' + pageSize;

            List<Learner_Profile__c> lps = Database.query(soqlQuery);

            for(Learner_Profile__c lp : lps) {
                if(String.isEmpty(childObj) || lp.getSObjects(childObj) == null || lp.getSObjects(childObj).isEmpty()){
                    newLPs.add(lp);
                } else {
                    duplicateLPs.add(lp);
                }

                newEmails.remove(lp.Primary_Email__c);
            }

            for(String email : newEmails) {
                notFound.add(new Map<String, Object>{'Primary_Email__c' => email});
            }

            rd.put('newLPs', newLPs);
            rd.put('duplicateLPs', duplicateLPs);
            rd.put('notFound', notFound);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd.getJsonString();
    }

    public class processEmailPayload {
        List<String> emails;
        String childObj;
        String parentId;
        Integer pageSize;
        String lastProcessedId;
    }
}