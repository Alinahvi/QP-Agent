public with sharing class FilterModal {
    
    public static Id eventRecordTypeId {
        get {
            return Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        }
    }

    @AuraEnabled
    public static ResponseData filteredContentByTag(String filterStr, String filterType, String minDate, String eventId, boolean hasTagFilters) {
        ResponseData rd = new ResponseData();

        Map<String, Object> tagsByName = (Map<String, Object>)JSON.deserializeUntyped(filterStr);
        List<String> typeList = new List<String>();
        List<String> selectedDate = new List<String>(); 
        List<String> tags = new List<String>(); 
            
        if(filterType == 'session') {
            typeList.add('Session__c');
            for(Object obj : (List<Object>)tagsByName.get('DateRange')) {
                if(obj != null) {
                    selectedDate.add(String.valueOf(obj));
                }                
            }
        } else {
            for(Object obj : (List<Object>)tagsByName.get('ContentType')) {
                typeList.add(String.valueOf(obj) == 'Events' ? 'Asset__c' : String.valueOf(obj));                
            }           
        }
        Boolean hasRecommendation = (filterType == 'catalog' && typeList.contains('Recommendation__c')) ? true : false;
        if(hasRecommendation) {
            List<String> temp = new List<String>();
            if(typeList.isEmpty()) {
                temp.addAll(new List<String>{'Asset__c', 'Course__c', 'Curriculum__c'});
            } else if(typeList.contains('Recommendation__c') && typeList.size() == 1) {
                temp.addAll(new List<String>{'Asset__c', 'Course__c', 'Curriculum__c'});
            } else {
                for(String str : typeList) {
                    if(str != 'Recommendation__c') {
                        temp.add(str == 'Events' ? 'Asset__c' : str);
                    }
                }
            }
            typeList = temp;
        } 

        Map<String, List<String>> sessionFiltersByName = sessionFiltersByName(tagsByName);
        Map<String, Set<String>> contentIdsByType = new Map<String, Set<String>> {
            'Asset__c' => new Set<String>(),
            'Course__c' => new Set<String>(),
            'Curriculum__c' => new Set<String>(),
            'Session__c' => new Set<String>(),
            'Recommendation__c' => new Set<String>()
        };
        
        try{
            // String query = 'SELECT Id, Session__c, Asset__r.Status__c, Course__r.Status__c, Curriculum__r.Status__c, ';
            String query = 'SELECT Id, Session__c, Asset__r.Event_Type__c, Asset__r.Status__c, Course__r.Status__c, Curriculum__r.Status__c, ';
            query += 'Role__r.Name, Product__r.Name, Language__c, Industry__r.Name, Proficiency_Level__c FROM Content_Tag__c WHERE ';
            if(filterType == 'session') {
                query += 'Session__c != NULL AND Session__r.Status__c = \'Active\' AND Session__r.Asset__c = :eventId AND Session__r.Start_Date__c >= TODAY';
            } else if(filterType == 'catalog') {
                query += 'Session__c = NULL';
                String subQuery = '';
                String statusQuery = '';
                for(String val : typeList){
                    subQuery += val + ' != NULL OR ';
                    statusQuery += val.replace('__c', '__r') + '.Status__c = \'Active\'' + ' OR ';
                }
                if(String.isNotEmpty(subQuery)){
                    subQuery = subQuery.removeEnd(' OR ');
                    query += ' AND ('+subQuery+')';
                    statusQuery = statusQuery.removeEnd(' OR ');
                    query += ' AND ('+statusQuery+')';
                }
                String tagQuery = tagQueryString(tagsByName, tags);
                if(String.isNotEmpty(tagQuery)) {
                    tagQuery = tagQuery.removeEnd(' OR ');
                    query += ' AND (' + tagQuery + ')';
                }
            }
            
            Map<String, Map<String, List<String>>> learningsBytype = new Map<String, Map<String, List<String>>> {
                'Asset__c' => new Map<String, List<String>>(),
                'Course__c' => new Map<String, List<String>>(),
                'Curriculum__c' => new Map<String, List<String>>(),
                'Session__c' => new Map<String, List<String>>()
            };             

            for(Content_Tag__c tag : Database.query(query, System.AccessLevel.USER_MODE)) {
                if(tag.Asset__r != null && typeList.contains('Asset__c') && tag.Asset__r.Event_Type__c != 'Recurring') {
                    tagsByLearningId(tag, tag.Asset__r.Id,  learningsBytype.get('Asset__c'));
                }
                if(tag.Course__r != null && typeList.contains('Course__c')) {
                    tagsByLearningId(tag, tag.Course__r.Id,  learningsBytype.get('Course__c'));
                }
                
                if(tag.Curriculum__r != null && typeList.contains('Curriculum__c')) {
                    tagsByLearningId(tag, tag.Curriculum__r.Id,  learningsBytype.get('Curriculum__c'));
                }
                
                if(filterType == 'session' && tag.Session__c != null && typeList.contains('Session__c')) {
                    tagsByLearningId(tag, tag.Session__c,  learningsBytype.get('Session__c'));				
                }
            }
            tags.sort();

            for(String str : learningsBytype.keySet()) {
                Map<String, List<String>> temp = learningsBytype.get(str);
                for(String key : temp.keySet()) {
                    List<String> values = new List<String>(temp.get(key));
                    if(values.size() == tags.size()) {
                        values.sort();
                        if(values.toString() == tags.toString()) {
                            contentIdsByType.get(str).add(key);
                        }
                    }                    
                }
            }
            
            if(filterType == 'session') {
                if(!sessionFiltersByName.isEmpty() || selectedDate.size() == 2) {
                    contentIdsByType = filterSession(contentIdsByType, selectedDate, sessionFiltersByName, eventId);
                }
            }            
            
            if(hasRecommendation) {
                contentIdsByType = filterByRecommendedLearning(contentIdsByType, typeList, hasTagFilters);
            }
            
            rd.put('ok', true);
            rd.put('message', 'filterd by content');
            rd.put('contentIdsByType', contentIdsByType);
        } catch(Exception e) {
            rd.addError(e.getMessage());
        }
        return rd;
    }

    public static Map<String, Set<String>> filterByRecommendedLearning(Map<String, Set<String>> contentIdsByType, List<String> typeList, Boolean hasTagFilters) {
        String lpId = [SELECT Id FROM Learner_Profile__c WHERE User__c = :UserInfo.getUserId() WITH USER_MODE LIMIT 1][0].Id;
        String query = 'Select Id, Asset__c, Course__c, Curriculum__c, Asset__r.recordTypeId from Recommended_Learning__c where Learner_Profile__c = :lpId';
        query += ' AND Status__c = \'Active\'';
        String subQuery = '';
        Set<String> assetIds = contentIdsByType.get('Asset__c');
        Set<String> courseIds = contentIdsByType.get('Course__c');
        Set<String> curriculumIds = contentIdsByType.get('Curriculum__c');
        Boolean eventsOnly = false;

        Map<String, Set<String>> contentByType = new Map<String, Set<String>>{
            'Asset__c' => new Set<String>(),
            'Course__c' => new Set<String>(),
            'Curriculum__c' => new Set<String>(),
            'Recommendation__c' => new Set<String>()
        };

        if(hasTagFilters) {
            subQuery += 'Asset__c in :assetIds OR Course__c in :courseIds OR Curriculum__c in :curriculumIds';                    
        } else {
            for(String str : typeList) {
                subQuery += str + ' != NULL OR ';                            
            }            
        }        
        if(String.isNotEmpty(subQuery)) {
            subQuery = subQuery.removeEnd(' OR ');
            query += ' AND ('+subQuery+')';
        } 
        if(typeList.size() < 3 && typeList.contains('Asset__c')) {
            eventsOnly = true;
        }
        for(Recommended_Learning__c rl : Database.query(query, System.AccessLevel.USER_MODE)) {
            if(rl.Asset__c != null && eventsOnly) {
                if(rl.Asset__r.recordTypeId == eventRecordTypeId) { contentByType.get('Recommendation__c').add(rl.Id); }
            } else if(rl.Asset__c != null && !eventsOnly) {
                contentByType.get('Recommendation__c').add(rl.Id);
            } else if(rl.Course__c != null) {
                contentByType.get('Recommendation__c').add(rl.Id);
            } else if(rl.Curriculum__c != null) {
                contentByType.get('Recommendation__c').add(rl.Id);
            }
        }
        return contentByType;
    } 

    public static Map<String, Set<String>> filterSession(Map<String, Set<String>> contentIdsByType, List<String> selectedDate, Map<String, List<String>> sessionFiltersByName, String eventId) {
        Set<String> sessionIds = contentIdsByType.get('Session__c');
        Map<String, Set<String>> contentByType = new Map<String, Set<String>>{
            'Asset__c' => new Set<String>(),
            'Course__c' => new Set<String>(),
            'Curriculum__c' => new Set<String>(),
            'Session__c' => new Set<String>()
        };
        Date startDate;
        Date endDate;
        if(selectedDate.size() == 2) {
            startDate = date.valueOf(selectedDate[0]);
            endDate = date.valueOf(selectedDate[1]);
        }
        
        List<String> sType = sessionFiltersByName.get('Type');
        List<String> region = sessionFiltersByName.get('Region');
        List<String> location = sessionFiltersByName.get('Location');
            
        String query = 'select Id, Start_Time_Converted__c, End_Time_Converted__c  from Session__c where Asset__c = :eventId and Status__c = \'Active\''; 
        // if(startDate != null && endDate != null) {
        //     query += ' and Start_Date__c >= :startDate and Start_Date__c <= :endDate';
        // } else {
        //     query += ' and Start_Date__c >= TODAY';
        // }
        if(sType != null && !sType.isEmpty()) {
            query += ' and Session_Type__c in :sType';
        }
        if(region != null && !region.isEmpty()) {
            query += ' and Region__c in :region';
        }
        if(location != null && !location.isEmpty()) {
            // query += ' and ( Office_Location__r.City__c in :location or Location__City__s in :location)';
            query += ' and Location__City__s in :location'; 
        }
        
        if(!sessionIds.isEmpty()) {
            query += ' and Id in :sessionIds';
        }
        query += ' order by Start_Date__c ASC';
        for(Session__c session : Database.query(query, System.AccessLevel.USER_MODE)) {
            DateTime sdt = session.Start_Time_Converted__c;
            DateTime edt = session.End_Time_Converted__c;
            Date startTemp = Date.newinstance(sdt.year(), sdt.month(), sdt.day());
            Date endTemp = Date.newinstance(edt.year(), edt.month(), edt.day());
            
            if(!sessionIds.isEmpty() && sessionIds.contains(session.Id)) {
                // filter by date-range using converted datetime field
                if(startDate != null && startTemp >= startDate && endTemp <= endDate) {
                    contentByType.get('Session__c').add(session.Id);                    
                } else if(startDate == null) {
                    contentByType.get('Session__c').add(session.Id);        
                }
            } else if(sessionIds.isEmpty()) {
                // filter by date-range using converted datetime field
                if(startDate != null && startTemp >= startDate && endTemp <= endDate) {
                    contentByType.get('Session__c').add(session.Id);
                } else if(startDate == null) {
                    contentByType.get('Session__c').add(session.Id);
                }
            }            
        }
        return contentByType;        
    }

    // return value - 'Val_1','val_2', 'val_3'
    public static String commaSeperatedString(List<Object> strList) {
        String value = '';
        if(strList == NULL || strList.isEmpty()) {
            return null;
        }
        for(Object str : strList) {
            value += '\''+(String)str+'\''+',';	
        }
        value = value.removeEnd(',');
        return value;
    }

    public static void tagsByLearningId(Content_Tag__c tag, String learningId, Map<String, List<String>> tagsBylearningId) {
        if(String.isNotEmpty(tag.Role__r.Name)) {
            if(!tagsBylearningId.containsKey(learningId)) {
                tagsBylearningId.put(learningId, new List<String>{'Role'});
            } else {
                if(!tagsBylearningId.get(learningId).contains('Role')) { tagsBylearningId.get(learningId).add('Role'); }
            }            					
        } else if(String.isNotEmpty(tag.Product__r.Name)) {
            if(!tagsBylearningId.containsKey(learningId)) {
                tagsBylearningId.put(learningId, new List<String>{'Product'});
            } else {
                if(!tagsBylearningId.get(learningId).contains('Product')) { tagsBylearningId.get(learningId).add('Product'); }
            }             
        } else if(String.isNotEmpty(tag.Industry__r.Name)) {
            if(!tagsBylearningId.containsKey(learningId)) {
                tagsBylearningId.put(learningId, new List<String>{'Industry'});
            } else {
                if(!tagsBylearningId.get(learningId).contains('Industry')) { tagsBylearningId.get(learningId).add('Industry'); }
            }             
        } else if(String.isNotEmpty(tag.language__c)) {
            if(!tagsBylearningId.containsKey(learningId)) {
                tagsBylearningId.put(learningId, new List<String>{'Language'});
            } else {
                if(!tagsBylearningId.get(learningId).contains('Language')) { tagsBylearningId.get(learningId).add('Language'); }
            }             
        } else if(String.isNotEmpty(tag.Proficiency_Level__c)) {
            if(!tagsBylearningId.containsKey(learningId)) {
                tagsBylearningId.put(learningId, new List<String>{'Proficiency Level'});
            } else {
                if(!tagsBylearningId.get(learningId).contains('Proficiency Level')) { tagsBylearningId.get(learningId).add('Proficiency Level'); }
            }            
        }            
    }

    public static String tagQueryString(Map<String, Object> tagsByName, List<String> tags) {
        String tagQuery = '';
        if((List<Object>)tagsByName.get('Language') != null && !((List<Object>)tagsByName.get('Language')).isEmpty()) {
            tagQuery += '(Language__c IN ('+commaSeperatedString((List<Object>)tagsByName.get('Language')) + ')) OR ';
            if(!tags.contains('Language')) { tags.add('Language'); }                    
        }
        if((List<Object>)tagsByName.get('Role') != null && !((List<Object>)tagsByName.get('Role')).isEmpty()) {
            tagQuery += '(Role__r.Name IN ('+commaSeperatedString((List<Object>)tagsByName.get('Role')) + ')) OR ';
            if(!tags.contains('Role')) { tags.add('Role'); }
        }
        if((List<Object>)tagsByName.get('Product') != null && !((List<Object>)tagsByName.get('Product')).isEmpty()) {
            tagQuery += '(Product__r.Name IN ('+commaSeperatedString((List<Object>)tagsByName.get('Product')) + ')) OR ';
            if(!tags.contains('Product')) { tags.add('Product'); }
        }
        if((List<Object>)tagsByName.get('Industry') != null && !((List<Object>)tagsByName.get('Industry')).isEmpty()) {
            tagQuery += '(Industry__r.Name IN ('+commaSeperatedString((List<Object>)tagsByName.get('Industry')) + ')) OR ';
            if(!tags.contains('Industry')) { tags.add('Industry'); }
        }
        if((List<Object>)tagsByName.get('Proficiency Level') != null && !((List<Object>)tagsByName.get('Proficiency Level')).isEmpty()) {
            tagQuery += '(Proficiency_Level__c IN ('+commaSeperatedString((List<Object>)tagsByName.get('Proficiency Level')) + ')) OR ';
            if(!tags.contains('Proficiency Level')) { tags.add('Proficiency Level'); }
        }
        return tagQuery;
    }

    public static Map<String, List<String>> sessionFiltersByName(Map<String, Object> tagsByName) {
        Map<String, List<String>> sessionFiltersByName = new Map<String, List<String>>();

        if((List<Object>)tagsByName.get('Type') != null && !((List<Object>)tagsByName.get('Type')).isEmpty()) {
            sessionFiltersByName.put('Type', (List<String>) JSON.deserialize(JSON.serialize((List<Object>)tagsByName.get('Type')), List<String>.class));
        }
        if((List<Object>)tagsByName.get('Location') != null && !((List<Object>)tagsByName.get('Location')).isEmpty()) {
            sessionFiltersByName.put('Location', (List<String>) JSON.deserialize(JSON.serialize((List<Object>)tagsByName.get('Location')), List<String>.class));
        }
        if((List<Object>)tagsByName.get('Region') != null && !((List<Object>)tagsByName.get('Region')).isEmpty()) {
            sessionFiltersByName.put('Region', (List<String>) JSON.deserialize(JSON.serialize((List<Object>)tagsByName.get('Region')), List<String>.class));
        }

        return sessionFiltersByName;
    }

}