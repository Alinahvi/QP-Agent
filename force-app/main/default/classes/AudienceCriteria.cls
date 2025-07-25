public with sharing class AudienceCriteria {
    private static Map<String, Schema.SObjectField> lpFields;


    @AuraEnabled
    public static String getInitData(String recordId){
        ResponseData rd = new ResponseData();

        try {
            List<Map<String, Object>> formattedTcs = new List<Map<String, Object>>();            
            List<Target_Criteria__c> tcs = [SELECT Id, Audience__c, Boolean_Value__c, Date_Value__c, Display_Value__c, 
                                                   Field__c, Operator__c, Number_Value__c, Text_Value__c, Order__c,
                                                   Custom_Soql__c
                                            FROM Target_Criteria__c
                                            WHERE Audience__c =: recordId
                                            WITH USER_MODE
                                            ORDER BY Order__c ASC];
            System.debug('************* tcs ' + tcs);
            for(Target_Criteria__c tc :tcs){
                Map<String, Object> formattedTC = formatTC(tc);

                if(formattedTC != null){
                    formattedTcs.add(formattedTC);
                }
            }

            System.debug('************* formattedTcs ' + formattedTcs);

            Audience__c aud = [SELECT Id, Filter_Logic__c, Use_Custom_Filter__c, Rendering__c
                               FROM Audience__c
                               WHERE Id =: recordId
                               WITH USER_MODE];

            rd.put('audience', aud);
            rd.put('criterias', formattedTcs);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    public static Map<String, Object> formatTC(Target_Criteria__c tc){
        Map<String, Object> tcMap = tc.getPopulatedFieldsAsMap().clone();

        if(tc.Field__c == 'Custom'){
            return tcMap;
        }

        if(lpFields == null){
            lpFields = Learner_Profile__c.SObjectType.getDescribe().fields.getMap();
        }

        if(!lpFields.containsKey(tc.Field__c)){
            return null;
        }
        
        Schema.DescribeFieldResult describedField = lpFields.get(tc.Field__c).getDescribe();

        tcMap.put('type', (describedField.getType() + '').toLowerCase());
        tcMap.put('label', describedField.getLabel());

        return tcMap;
    }

    @AuraEnabled
    public static String saveCriterias(String jsonString){
        ResponseData rd = new ResponseData();

        try {
            Map<String, Object> parsedJSON = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            List<Object> criteriaMaps = (List<Object>)parsedJSON.get('criterias');
            List<Target_Criteria__c> tcs = new List<Target_Criteria__c>();

            for(Object criteriaObjMap : criteriaMaps){
                tcs.add((Target_Criteria__c)Utilities.getSobjectByMap(criteriaObjMap, 'Target_Criteria__c'));
            }

            upsert as user tcs;

            List<Map<String, Object>> formattedTCs = new List<Map<String, Object>>();

            for(Target_Criteria__c tc : tcs){
                Map<String, Object> formattedTC = formatTC(tc);

                if(formattedTC != null){
                    formattedTcs.add(formattedTC);
                }
            }

            rd.put('tcs', formattedTCs);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String saveAudience(String jsonString){
        ResponseData rd = new ResponseData();

        try {
            Map<String, Object> parsedJSON = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Map<String, Object> criteriaObjMap = (Map<String, Object>)parsedJSON.get('audience');
            Audience__c audience = (Audience__c)Utilities.getSobjectByMap(criteriaObjMap, 'Audience__c');

            upsert as user audience;

            rd.put('audience', audience);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String testCriterias(String recordId, String criteriaLogic, String customSoql){
        ResponseData rd = new ResponseData();

        try {
            String soqlQuery = 'SELECT COUNT() FROM Learner_Profile__c';
            //use the soql thats passed in as it hasn't been saved yet
            String whereClause = ' WHERE ' + (String.isNotEmpty(customSoql) ? customSoql : Utilities.getCriteriaWhereClause(recordId, criteriaLogic));

            soqlQuery += whereClause;
            soqlQuery += ' LIMIT 1';

            System.debug('***************** ' + soqlQuery);

            Integer total = Database.countQuery(soqlQuery, AccessLevel.USER_MODE);

            rd.put('total', total);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String deleteCriteria(String recordId){
         ResponseData rd = new ResponseData();

        try {
            delete as user new Target_Criteria__c(Id = recordId);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getSuggestedText(String searchTerm, String field){
        ResponseData rd = new ResponseData();
        
        try {
            String wildSearchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
            field = String.escapeSingleQuotes(field);
            String soqlString = 'SELECT count(Id), ' + field + ' suggestion' +
                                ' FROM Learner_Profile__c ' +
                                ' WHERE ' + field + ' LIKE :wildSearchTerm' +
                                ' WITH USER_MODE' +
                                ' GROUP BY ' + field +
                                ' ORDER BY ' + field + ' ASC' +
                                ' LIMIT 5';

            List<Map<String, Object>> formattedSuggestions = new List<Map<String, Object>>();
            List<AggregateResult> ars = Database.query(soqlString);

            for(Integer i = 0; i < ars.size(); i++){
                AggregateResult ar = ars.get(i);

                formattedSuggestions.add(new Map<String, Object>{
                    'key' => i,
                    'suggestion' => ar.get('suggestion')
                });
            }
            
            rd.put('suggestions', formattedSuggestions);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String resetAudience(String audienceId){
        ResponseData rd = new ResponseData();
        
        try {
            Audience__c aud = new Audience__c(
                Id = audienceId,
                Use_Custom_Filter__c = false,
                Filter_Logic__c = ''
            );

            update as user aud;
            delete as user [SELECT Id FROM Target_Criteria__c WHERE Audience__c =: audienceId];
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd.getJsonString();
    }

    @AuraEnabled
    public static ResponseData renderAudience(String audienceId){
        ResponseData rd = new ResponseData();
        
        try {
            Id batchId = Database.executeBatch(new AudienceMemberCreationBatch(false, new Map<String, String>(), audienceId), 1);
            update as user new Audience__c(Id = audienceId, Rendering__c = true);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData checkProcessStatus(String audienceId){
        ResponseData rd = new ResponseData();
        
        try {
            Audience__c aud = [SELECT Id, Rendering__c FROM Audience__c WHERE Id =: audienceId WITH USER_MODE];
            rd.put('processing', aud.Rendering__c);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }
}