/**
 * Controller Class for Enablement inline Editable List for the Work sObject
 * Developer: N. B. O'Meally
 */
public with sharing class EnablementEditableListWork {
    
    public class EnablementException extends Exception {}
    private static Map<Id, agf__ADM_Work__c> mapWork = new Map<Id, agf__ADM_Work__c>();

    @TestVisible
    class WorkObjectWrapper {
        Id id;
        String name;
        Id epic;
        String epicName;
        String subject;
        String status;
        Id assignee;
        Date startDate;
        Date dueDate;
        String details;
        Decimal storyPoints;
        Decimal hours;
        String productTag;
        String sprint;
        Id scheduledBuild;        
        Decimal priority; // Backlog Rank
        Id engineer;        
        Id project;
        String projectName;
        String epicDetail;
        String workDetail;
        String projectDetail;

        public WorkObjectWrapper(agf__ADM_Work__c w) {
            String urlBase = System.Url.getSalesforceBaseUrl().toExternalForm();

            this.id = w.Id; 
            this.name = w.Name; 
            this.epic = w.agf__Epic__c; 
            this.epicName = w.agf__Epic__c != null ? w.agf__Epic__r.Name : null; 
            this.subject = w.agf__Subject__c; 
            this.status = w.agf__Status__c; 
            this.assignee = w.agf__Assignee__c != null ? w.agf__Assignee__c : null;             
            this.startDate = w.Start_Date__c;             
            this.dueDate = w.Due_Date__c != null 
                ? Date.newInstance(w.Due_Date__c.year(), w.Due_Date__c.month(), w.Due_Date__c.day()) 
                : null; 
            this.details = w.agf__Details__c; 
            this.storyPoints = w.agf__Story_Points__c; 
            this.hours = w.Hours__c; 
            this.productTag = w.agf__Product_Tag__c;
            this.sprint = w.agf__Sprint__c; 
            this.scheduledBuild = w.agf__Scheduled_Build__c; 
            this.priority = w.agf__Priority_Rank__c; // backlog Rank
            this.engineer = w.agf__QA_Engineer__c;             
            this.project = w.Project__c;
            this.projectName = w.Project__c != null ? w.Project__r.Name : null;

            this.epicDetail = w.agf__Epic__c != null ? urlBase + '/lightning/r/agf__ADM_Epic__c/' + w.agf__Epic__c +'/view' : '';
            this.workDetail = w.Id != null ? urlBase + '/lightning/r/agf__ADM_Work__c/' + w.Id +'/view' : '';    
            this.projectDetail = w.Project__c != null ? urlBase + '/lightning/r/agf__PPM_Project__c/' + w.Project__c +'/view' : '';
        }
    }

    /***
     * @param recordId -- could sometimes be blank when calling from the home page
     * @param userId -- the current user id
     * @param objectName -- sometimes blank when calling from the home page
     */
    @AuraEnabled
    public static String getListViewData(Id recordId, Id userId, String objectName) {        
        String objLabel;
        if (objectName != null) {
            objLabel = objectName.indexOf('Project') > -1 ? 'Project' : 'Epic';
        }         
        List<WorkObjectWrapper> workData = getWork(recordId, userId, objLabel);
        return JSON.serialize(workData);        
    }

    private static List<WorkObjectWrapper> getWork(Id recordId, Id userId, String objLabel) {
        List<WorkObjectWrapper> wow = new List<WorkObjectWrapper>();        
        try {
            String query = 'SELECT Id, Name, agf__Epic__c, agf__Subject__c, agf__Status__c, agf__Product_Tag__c, ' +
                'agf__Assignee__c, Start_Date__c, Due_Date__c, agf__Details__c, agf__Story_Points__c, Hours__c, agf__Scrum_Team__c, ' +
                'agf__Sprint__c, agf__Scheduled_Build__c, agf__Priority_Rank__c, agf__QA_Engineer__c, Project__c, Project__r.Name, ' +
                'agf__Epic__r.Name, agf__Assignee__r.Name ' +
                'FROM agf__ADM_Work__c WHERE ';
                if (recordId != null) {
                    query += (objLabel == 'Project' ? 'Project__c' : 'agf__Epic__c') + ' = \'' + recordId + '\'' + 
                        ' AND (NOT agf__Status__c IN (\'Never\', \'Duplicate\'))'+
                        ' AND (NOT Project__r.agf__Project_Health__c IN (\'Canceled\')) AND (NOT agf__Epic__r.agf__Health__c IN (\'Canceled\'))';
                } else {
                    query += 'agf__Assignee__c = \'' + userId + '\' AND (NOT agf__Status__c IN (\'Never\', \'Duplicate\', \'Closed\'))' +
                    ' AND (NOT Project__r.agf__Project_Health__c IN (\'Canceled\')) AND (NOT agf__Epic__r.agf__Health__c IN (\'Canceled\'))';
                }
                    
                query += ' WITH SECURITY_ENFORCED ORDER BY Start_Date__c';            

            for (agf__ADM_Work__c w : Database.query(query)) {
                wow.add(new WorkObjectWrapper(w));
            }
        } catch (System.QueryException qe) {
            System.debug(qe.getMessage());
            throw new EnablementException('Error retrieving data list: ' + qe.getMessage());
        }        
        return wow;
    }

    @AuraEnabled
    public static Boolean saveChanges(String jsonData) {
        Map<String, String> objMap = new Map<String, String>();
        List<agf__ADM_Work__c> work = new List<agf__ADM_Work__c>();
        Boolean returnValue = false;        

        try {
            //System.debug('JSON DESERIAL...: ' + jsonData);
            List<Object> result = (List<Object>)JSON.deserializeUntyped(jsonData); 
            for(Object obj : result) {                
                Map<String,Object> map1 = (Map<String,Object>)obj; 
                for(String key : map1.keySet()) { 
                    objMap.put(key, (String)map1.get(key));
                }
                agf__ADM_Work__c workRecord = saveWork(objMap);
                objMap.clear();            
            }
            Database.UpsertResult[] results = Database.upsert(mapWork.values(), false);
            returnValue = true;
            mapWork.clear();
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());        
        } catch(Exception e) {
            String err = 'An exception occurred while saving updates for Work data: ' + e.getMessage();
            System.debug(err);
            //throw new EnablementException(err);
        }
        return returnValue;
    }

    private static agf__ADM_Work__c saveWork(Map<String, String> objMap) {
        Map<String, List<String>> fldMap = mapFields();
        agf__ADM_Work__c rec;
        for (String key : objMap.keySet()) {
            List<String> mapType = fldMap.get(key);
            // review this to make it more efficient -- not called for each iteration.
            rec = mapWork.get(objMap.get('id')) != null ? mapWork.get(objMap.get('id')) : new agf__ADM_Work__c();
            if ( mapType != null) {
                switch on mapType[1] {
                    when 'Date' {
                        List<String> dt = objMap.get(key).split('-');
                        rec.put(fldMap.get(key)[0], date.newinstance(
                            Integer.valueOf(dt[0]), 
                            Integer.valueOf(dt[1]), 
                            Integer.valueOf(dt[2]))
                        );
                    }
                    when 'Id' {
                        String checkVal = objMap.get(key); //change to string to check for null
                        if (checkVal == '') {  //null check, if null we WANT to add a null ID, but cannot input as type ID
                            rec.put(fldMap.get(key)[0], '');
                        } else {
                            rec.put(fldMap.get(key)[0], Id.valueOf(objMap.get(key)));
                        }
                    }
                    when 'Decimal' {
                        rec.put(fldMap.get(key)[0], Decimal.valueOf(objMap.get(key)));
                    }
                    when else {
                        rec.put(fldMap.get(key)[0], objMap.get(key));
                    }                
                }
                mapWork.put(objMap.get('id'), rec);
            }
        }
                
        return rec;
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> lookUp(String searchTerm, String objectName, String filters, String recordId, String fields) {

        Integer limitNum = 20;
        String finalQuery = 'SELECT ' + fields + ' FROM ' + objectName;

        if(String.isBlank(recordId)){
            if(String.isNotBlank(searchTerm)){
                finalQuery += ' WHERE Name Like  \'%' + searchTerm + '%\' ';
            }
            
            if(String.isNotBlank(filters)){
                finalQuery += String.isNotBlank(searchTerm) ? ' AND ' : ' WHERE ';
                finalQuery += filters;
            }
        }else{
            finalQuery += ' WHERE Id =  \'' + recordId + '\'';
        }

        finalQuery+= ' LIMIT ' + limitNum;
        List<sObject> lookUpList = database.query(finalQuery);
        return lookUpList;  
    }

    private static Map<String, List<String>> mapFields() {
        Map<String, List<String>> fldMap = new Map<String, List<String>>{
            'id' => new List<String>{'Id','Id'},
            'dueDate' => new List<String>{'Due_Date__c', 'Date'},
            'startDate' => new List<String>{'Start_Date__c', 'Date'},
            'subject' => new List<String>{'agf__Subject__c','String'},
            'status' => new List<String>{'agf__Status__c','String'},
            'assignee' => new List<String>{'agf__Assignee__c','Id'},
            'details' => new List<String>{'agf__Details__c','String'}, // description
            'storyPoints' => new List<String>{'agf__Story_Points__c', 'Decimal'},
            'hours' => new List<String>{'Hours__c', 'Decimal'},
            'productTag' => new List<String>{'agf__Product_Tag__c', 'String'},
            'sprint' => new List<String>{'agf__Sprint__c', 'String'},
            'scheduledBuild' => new List<String>{'agf__Scheduled_Build__c', 'Id'},
            'priority' => new List<String>{'agf__Priority_Rank__c', 'Decimal'}, // backlog Rank
            'engineer' => new List<String>{'agf__QA_Engineer__c', 'Id'}
        };

        return fldMap;
    }

}