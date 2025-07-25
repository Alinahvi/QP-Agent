public with sharing class ContentTagging {

    private static final Set<String> CHILD_RECORD_FIELDS = new Set<String>{
        'Enablement_Learning_Program__c', 'Growth_Factor_L1__c', 'Growth_Factor_L2__c', 
        'Role__c', 'Skill__c', 'Vertical__c', 'Product__c', 'Product_L2__c', 'Industry__c', 'Industry_L2__c', 'Role__c', 'Segment__c', 'Skill__c', 'Vertical__c'
    };

    private static String lookupQueryFields {
        get {
            return String.join(new List<String>(CHILD_RECORD_FIELDS), ',');
        }
    }

    private static List<String> typesWithChildren = new List<String>{'industry', 'product'};

    // private static final Set<String> PICKLIST_FIELDS = new Set<String>{
    //     'Language__c', 'Primary_Category__c'
    // };

    // private static String picklistQueryFields {
    //     get {
    //         return String.join(new List<String>(PICKLIST_FIELDS), ',');
    //     }
    // }

    @AuraEnabled
    public static ResponseData initData(String recordId){
        ResponseData rd = new ResponseData();
        
        try {
            //getExistingTags(recordId);
            getTaggingOptions(recordId, rd);
            getExistingTags(recordId, rd);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static void getExistingTags(Id recordId, ResponseData rd) {
        try {
            List<Map<String, Object>> formattedExistingTags = new List<Map<String, Object>>();
            List<Content_Tag__c> existingTags = [SELECT Id, Display_Value__c, Enablement_Learning_Program__c, Enablement_Learning_Program__r.Name, Growth_Factor_L1__c, Growth_Factor_L1__r.Name, Growth_Factor_L2__c, Growth_Factor_L2__r.Name,
                                                        Industry_L2__c, Industry_L2__r.Name, Industry__c, Industry__r.Name, Language__c, Primary_Category__c, Product_L2__c, Product_L2__r.Name, 
                                                        Product__c, Product__r.Name, Role__c, Role__r.Name, Segment__c, Segment__r.Name, Skill__c, Skill__r.Name, Vertical__c, Vertical__r.Name, Proficiency_Level__c
                                                 FROM Content_Tag__c
                                                 WHERE Asset__c = :recordId 
                                                 OR Course__c = :recordId
                                                 OR Curriculum__c = :recordId
                                                 OR Session__c = :recordId
                                                 WITH USER_MODE];
            
            for (Content_Tag__c contentTag : existingTags) {
                Map<String, Object> contentTagMap = contentTag.getPopulatedFieldsAsMap().clone();
                
                if(contentTag.Language__c != null){
                    contentTagMap.put('label', contentTag.Language__c);
                } else {
                    contentTagMap.put('label', contentTag.Display_Value__c);
                }

                contentTagMap.put('key', contentTag.Id);

                formattedExistingTags.add(contentTagMap);
            }

            rd.put('selectedContentTags', formattedExistingTags);
        } catch (Exception e) {
            rd.addError(e);
        }
    }

    public static void getTaggingOptions(Id recordId, ResponseData rd){
        try {
            List<Role__c> roles = [SELECT Id, Name FROM Role__c WITH USER_MODE ORDER BY Name ASC];
            List<Map<String, Object>> growthFactors = new List<Map<String, Object>>();
            Map<String, Map<String, Object>> growthFactorByName = new Map<String, Map<String, Object>>();
            //GFS don't have a direct heirarchy, so we need to build it manually via the junction Role GFs
            for(Growth_Factor_L2__c gfl2 : [SELECT Id, Name, Role_Growth_Factor__r.Growth_Factor_L1__r.Name 
                                            FROM Growth_Factor_L2__c 
                                            ORDER BY Role_Growth_Factor__r.Growth_Factor_L1__r.Name, Name ASC]){

                if(!growthFactorByName.containsKey(gfl2.Role_Growth_Factor__r.Growth_Factor_L1__r.Name)){
                    Map<String, Object> gfl1 = new Map<String, Object>{
                        'Name' => gfl2.Role_Growth_Factor__r.Growth_Factor_L1__r.Name,
                        'Id' => gfl2.Role_Growth_Factor__r.Growth_Factor_L1__c,
                        'Growth_Factors_L2__r' => new List<Object>()
                    };

                    growthFactorByName.put(gfl2.Role_Growth_Factor__r.Growth_Factor_L1__r.Name, gfl1);

                    growthFactors.add(gfl1);
                }

                Map<String, Object> gfl1 = growthFactorByName.get(gfl2.Role_Growth_Factor__r.Growth_Factor_L1__r.Name);
                ((List<Object>)gfl1.get('Growth_Factors_L2__r')).add(gfl2);
            }

            List<Industry__c> industries = [SELECT Id, Name,  
                                                   (SELECT Id, Name FROM Industries_L2__r ORDER BY Name ASC)
                                            FROM Industry__c WITH USER_MODE ORDER BY Name ASC];
            List<Vertical__c> verticals = [SELECT Id, Name FROM Vertical__c WITH USER_MODE ORDER BY Name ASC];
            List<Segment__c> segments = [SELECT Id, Name FROM Segment__c WITH USER_MODE ORDER BY Name ASC];
            List<Enablement_Learning_Program__c> enablementPrograms = [SELECT Id, Name 
                                                                       FROM Enablement_Learning_Program__c 
                                                                       WHERE Active__c = true WITH USER_MODE ORDER BY Name ASC];
            List<Product__c> products = [SELECT Id, Name,  
                                                (SELECT Id, Name FROM Products_L2__r WHERE External_Id__c != null ORDER BY Name ASC)
                                         FROM Product__c WHERE External_Id__c != null WITH USER_MODE ORDER BY Name ASC];
            List<Skill__c> skills = [SELECT Id, Name FROM Skill__c WITH USER_MODE ORDER BY Name ASC];

            rd.put('roles', roles);
            rd.put('growthFactors', growthFactors);
            rd.put('industries', industries);
            rd.put('verticals', verticals);
            rd.put('segments', segments);
            rd.put('enablementPrograms', enablementPrograms);
            rd.put('products', products);
            rd.put('skills', skills);
        } catch (Exception e) {
            rd.addError(e);
        }
    }

    @AuraEnabled
    public static ResponseData handleContentTagSave(String jsonString){
        ResponseData rd = new ResponseData();
        
        try {
            savePayload payload = (savePayload)JSON.deserialize(jsonString, savePayload.class);

            delete [SELECT Id FROM Content_Tag__c WHERE Id IN :payload.contentTagsIdsToDelete];

            // String parentLookupField = payload.recordId.getSObjectType().getDescribe().getName();

            // for(Content_Tag__c tag : payload.contentTags){
            //     tag.put(parentLookupField, payload.recordId);
            // }

            upsert payload.contentTags;

            getExistingTags(payload.recordId, rd);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public class savePayload {
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public List<Content_Tag__c> contentTags;
        @AuraEnabled
        public List<String> contentTagsIdsToDelete;
    }

    // @AuraEnabled
    // public static ResponseData objNameByRecordId(Id recordId) {
    //     ResponseData rd = new ResponseData();
    //     try{
    //         rd.put('objName', recordId.getSObjectType() + '');
    //     }catch(Exception e){
    //         rd.addError(e);
    //     }        
    //     return rd;
    // }

    @AuraEnabled
    public static ResponseData allowedEditor(Id recordId, String objApiName) {
        ResponseData rd = new ResponseData();
        String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        try{
            String query = 'SELECT Id, Allowed_Editor__c FROM '+
                           objApiName +
                           ' WHERE Id = :recordId';//  +
                           // ' WITH USER_MODE';
            if(objApiName == 'Asset__c') {
                query += ' AND RecordTypeId != :eventRecordTypeId';
            }
            query += ' WITH USER_MODE';
            List<sObject> sObjList = Database.query(query);
            if(!sObjList.isEmpty()) {
                rd.put('allowedEditor', (Boolean)sObjList[0].get('Allowed_Editor__c'));
            } else {
                rd.put('allowedEditor', true);
            }            
        }catch(Exception e){
            rd.addError(e);
        }        
        return rd;
    }
}