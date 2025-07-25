public with sharing class EoaTagProductIndustry {
    
    @AuraEnabled
    public static ResponseData initData(String recordId) {
        ResponseData rd = new ResponseData();
        try {
            getTaggingOptions(rd);
            getExistingTags(recordId, rd);   
        } catch(Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static void getTaggingOptions(ResponseData rd) {
        try {
            List<Industry__c> industries = [SELECT Id, Name,  
                                                   (SELECT Id, Name FROM Industries_L2__r ORDER BY Name ASC)
                                            FROM Industry__c WITH USER_MODE ORDER BY Name ASC];
            List<Product__c> products = [SELECT Id, Name,  
                                            (SELECT Id, Name FROM Products_L2__r WHERE External_Id__c != null ORDER BY Name ASC)
                                        FROM Product__c
                                        WHERE External_Id__c != null
                                        WITH USER_MODE 
                                        ORDER BY Name ASC];
            
            rd.put('products', products);
            rd.put('industries', industries);
        } catch(Exception e){
            rd.addError(e);
        }
    }

    @AuraEnabled
    public static ResponseData handleContentTagSave(String recordId, List<Object> contentTags) {
        ResponseData rd = new ResponseData();
        try {
            String product1 = '';
            String product2 = '';
            String industry1 = '';
            String industry2 = '';
            for(Object obj : contentTags) {
                Map<Object, Object> objMap = (Map<Object, Object>)obj;                
                if(objMap.containsKey('Product__c')) {
                    product1 += (String)objMap.get('label');
                    product1 += ';';                    
                } else if(objMap.containsKey('Product_L2__c')) {
                    product2 += (String)objMap.get('label');
                    product2 += ';';                    
                } else if(objMap.containsKey('Industry__c')) {
                    industry1 += (String)objMap.get('label');
                    industry1 += ';';                    
                } else if(objMap.containsKey('Industry_L2__c')) {
                    industry2 += (String)objMap.get('label');
                    industry2 += ';';                    
                }
            }
            Enablement_Solutions__c es = new Enablement_Solutions__c(Id = recordId);
            es.Product_L1__c = String.isNotBlank(product1) ? product1.substringBeforeLast(';') : '';
            es.Product_L2__c = String.isNotBlank(product2) ? product2.substringBeforeLast(';') : '';
            es.Industry_L1__c = String.isNotBlank(industry1) ? industry1.substringBeforeLast(';') : '';
            es.Industry_L2__c = String.isNotBlank(industry2) ? industry2.substringBeforeLast(';') : '';

            update es;
            getExistingTags(recordId, rd);
        } catch(Exception e){
            System.debug('Exception --------- '+e.getMessage() +' ----- '+ e.getStackTraceString());
            rd.addError(e);
        }
        return rd;
    }

    public static void getExistingTags(Id recordId, ResponseData rd) { 
        List<Map<String, Object>> selectedTags = new List<Map<String, Object>>();
        // Boolean isSuccess = true;
        try {
            List<Enablement_Solutions__c> ed = [SELECT Id, Product_L1__c, Product_L2__c, Industry_L1__c, Industry_L2__c 
                                                FROM Enablement_Solutions__c 
                                                WHERE Id =: recordId];
            
            if(!ed.isEmpty()) {
                
                if(String.isNotBlank(ed[0].Product_L1__c)) {
                    Map<String, String> tagMap = productIdByName(ed[0].Product_L1__c.split(';'), 'Product__c');
                    if(!tagMap.isEmpty()) {
                        selectedTags.addAll(getTagElements(tagMap, 'Product__c'));
                    }
                }
                if(String.isNotBlank(ed[0].Product_L2__c)) {
                    Map<String, String> tagMap = productIdByName(ed[0].Product_L2__c.split(';'), 'Product_L2__c');
                    if(!tagMap.isEmpty()) {
                        selectedTags.addAll(getTagElements(tagMap, 'Product_L2__c'));
                    }
                }
                if(String.isNotBlank(ed[0].Industry_L1__c)) {
                    Map<String, String> tagMap = productIdByName(ed[0].Industry_L1__c.split(';'), 'Industry__c');
                    if(!tagMap.isEmpty()) {
                        selectedTags.addAll(getTagElements(tagMap, 'Industry__c'));
                    }
                }
                if(String.isNotBlank(ed[0].Industry_L2__c)) {
                    Map<String, String> tagMap = productIdByName(ed[0].Industry_L2__c.split(';'), 'Industry_L2__c');
                    if(!tagMap.isEmpty()) {
                        selectedTags.addAll(getTagElements(tagMap, 'Industry_L2__c'));
                    }
                }                
                rd.put('selectedContentTags', selectedTags);
            }            
        } catch(Exception e) {
            System.debug('Exception --------- '+e.getMessage() +' ----- '+ e.getStackTraceString());
            rd.addError(e);            
        }        
    }

    public static Map<String, String> productIdByName(List<String> labels, String objType) {
        Map<String, String> dataMap = new Map<String, String>();
        String query = 'SELECT Id, Name FROM '+objType + ' WHERE Name IN: labels';
        for(sObject sObj : Database.query(query)) {
            dataMap.put((String)sObj.get('Id'), (String)sObj.get('Name'));            
        }
        return dataMap;
    }

    public static List<Map<String, Object>> getTagElements(Map<String, String> tagIdByName, String tagField) {
        List<Map<String, Object>> tagList = new List<Map<String, Object>>();	
        for(String key : tagIdByName.keySet()) {
            Map<String, Object> tagMap = new Map<String, Object>();
            tagMap.put('label', tagIdByName.get(key));
            tagMap.put('Id', key);
            tagMap.put(tagField, key);
            tagMap.put(tagField.replace('__c', '__r'), new Map<String, Object>{
                'label' => tagIdByName.get(key),
                'Id' => key
            });
            tagList.add(tagMap);
        }
        return tagList;
    }     
}