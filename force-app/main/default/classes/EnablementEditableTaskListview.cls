public with sharing class EnablementEditableTaskListview {
    
    public class EnablementException extends Exception {}
    private static String urlBase = System.Url.getSalesforceBaseUrl().toExternalForm();
    private static Map<Id, agf__ADM_Task__c> mapTasks = new Map<Id, agf__ADM_Task__c>();

    @AuraEnabled
    public static string getTaskData() {
        
        List<TaskWrapper> tasks = new List<TaskWrapper>();
        try {
            String query = 'SELECT Id, Name, agf__Assigned_To__c, agf__Work__c, agf__Work__r.agf__Subject__c, agf__Subject__c, agf__Status__c, agf__Starting_Hours__c, ' 
                + ' agf__Hours_Remaining__c, agf__Actual_Hours__c, agf__Comments__c, agf__Work__r.Name, agf__Due_By__c ' 
                + ' FROM agf__ADM_Task__c WHERE agf__Assigned_To__c = \'' + UserInfo.getUserId() + '\'' 
                + ' AND (NOT agf__Status__c IN (\'Completed\', \'Deferred\'))';
            
            for (agf__ADM_Task__c t : Database.query(query)) {                
                tasks.add(new TaskWrapper(t));
            }

            return JSON.serialize(tasks);
        } catch (Exception e) {
            System.debug('getTaskData exception occurred: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    class TaskWrapper {
        Id id;
        String name;
        Id assignee;
        Id work;
        String workName;
        String subject;
        String workSubject;
        String status;
        //Decimal startHours;
        //Decimal remainingHours;
        Date dueBy;
        Decimal actualHours;
        String comments;

        String taskDetail;
        String workDetail;            

        public taskWrapper(agf__ADM_Task__c tsk) {            
            this.id = tsk.Id;            
            this.name = tsk.Name;
            this.assignee = tsk.agf__Assigned_To__c;
            this.work = tsk.agf__Work__c;            
            this.subject = tsk.agf__Subject__c;
            this.status = tsk.agf__Status__c;
            //this.startHours = tsk.agf__Starting_Hours__c;
            //this.remainingHours = tsk.agf__Hours_Remaining__c;
            this.dueBy = tsk.agf__Due_By__c;
            this.actualHours = tsk.agf__Actual_Hours__c;
            this.comments = tsk.agf__Comments__c;
            this.workName = tsk.agf__Work__r.Name;
            this.workSubject = tsk.agf__Work__r.agf__Subject__c;

            this.taskDetail =  tsk.Id != null ? urlBase + '/lightning/r/agf__ADM_Task__c/' + tsk.Id +'/view' : null;
            this.workDetail = tsk.agf__Work__c != null ? urlBase + '/lightning/r/agf__ADM_Work__c/' + tsk.agf__Work__c +'/view' : null;   
        }
    }

    @AuraEnabled
    public static Boolean saveUpdates( String jsonData ) {
        Map<String, String> objMap = new Map<String, String>();
        List<agf__ADM_Task__c> tasks = new List<agf__ADM_Task__c>();
        Boolean returnValue = false;   

        try {            
            List<Object> result = (List<Object>)JSON.deserializeUntyped(jsonData); 
            for(Object obj : result) {                 
                Map<String,Object> map1 = (Map<String,Object>)obj; 

                for(String key : map1.keySet()) { 
                    objMap.put(key, (String)map1.get(key));
                }
                convertToTaskRecordObject(objMap); // add the entry to the mapTasks object for saving later
            }

            Database.UpsertResult[] results = Database.upsert(mapTasks.values(), false); 
            returnValue = true;
            mapTasks.clear();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return returnValue;
    }

    private static void convertToTaskRecordObject(Map<String, String> objMap) {
        Map<String, List<String>> fldMap = mapFields();
        agf__ADM_Task__c rec;

        for (String key : objMap.keySet()) {
            List<String> mapType = fldMap.get(key);

            // review this to make it more efficient -- not called for each iteration.
            rec = mapTasks.get(objMap.get('id')) != null ? mapTasks.get(objMap.get('id')) : new agf__ADM_Task__c();

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
                        rec.put(fldMap.get(key)[0], Id.valueOf(objMap.get(key)));
                    }
                    when 'Decimal' {
                        rec.put(fldMap.get(key)[0], Decimal.valueOf(objMap.get(key)));
                    }
                    when else {
                        rec.put(fldMap.get(key)[0], objMap.get(key));
                    }                
                }
                mapTasks.put(objMap.get('id'), rec);
            }
        }
    }

    private static Map<String, List<String>> mapFields() {
        Map<String, List<String>> fldMap = new Map<String, List<String>>{
            'id' => new List<String>{'Id','Id'},
            'assignee' => new List<String>{'agf__Assigned_To__c', 'Id'},
            'work' => new List<String>{'Start_Dagf__Work__cate__c', 'Id'},
            'subject' => new List<String>{'agf__Subject__c','String'},
            'status' => new List<String>{'agf__Status__c','String'},            
            'dueBy' => new List<String>{'agf__Due_By__c', 'Date'},            
            'actualHours' => new List<String>{'agf__Actual_Hours__c', 'Decimal'},
            'comments' => new List<String>{'agf__Comments__c', 'String'},
            'workName' => new List<String>{'agf__Work__r.Name', 'String'},
            'name' => new List<String>{'Name', 'String'}
        };

        return fldMap;
    }
}