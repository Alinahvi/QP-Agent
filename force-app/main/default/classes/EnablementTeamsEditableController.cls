public with sharing class EnablementTeamsEditableController {

    private static Map<Id, agf__ADM_Work__c> mapWork = new Map<Id, agf__ADM_Work__c>();
    public class EnablementException extends Exception {}

    @AuraEnabled
    public static string getData(Id teamId, String objectName) {
        String returnValue = null;
        try {
            switch on objectName {
                when 'Work' {
                    returnValue = getWorkByTeam(teamId);
                }
                when 'Project' {
                    returnValue = getProjects(teamId);
                }
                when 'Epic' {
                    returnValue = getEpics(teamId);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnValue;
    }
    
    private static string getWorkByTeam(Id recordId ) {
        List<WorkObjectWrapper> wow = new List<WorkObjectWrapper>();
        try {
            String query = 'SELECT Id, Name, agf__Epic__c, agf__Related_Work__c, agf__Subject__c, agf__Status__c, ' +
                'agf__Assignee__c, Start_Date__c, agf__Due_Date__c, agf__Details__c, agf__Story_Points__c, Hours__c, agf__Scrum_Team__c, ' +
                'agf__Sprint__c, agf__Scheduled_Build__c, agf__Scheduled_Build__r.Name, agf__Priority_Rank__c, agf__QA_Engineer__c, Project__c, ' +
                'agf__Epic__r.Name, agf__Related_Work__r.Name, agf__Assignee__r.Name, agf__QA_Engineer__r.Name, Project__r.Name ' +
                'FROM agf__ADM_Work__c WHERE agf__Scrum_Team__c = \'' 
                    + recordId + '\' AND (NOT agf__Status__c in (\'Closed\', \'Never\')) WITH SECURITY_ENFORCED ORDER BY Name';

            System.debug('The Query: ' + query);

            for (agf__ADM_Work__c w : Database.query(query)) {
                wow.add(new WorkObjectWrapper(w));
            }
        } catch (System.QueryException qe) {
            System.debug(qe.getMessage());
        }

        System.debug(' the data: ' + wow);
        return JSON.serialize(wow);
    }

    private static String getProjects(Id scrumTeamId) {
        List<WrapperObject> projects = new List<WrapperObject>();
    
        try {                                    
            String query = 'SELECT Id, Name, agf__Program__c, agf__Program__r.Name, agf__Project_Health__c, Percent_Complete__c, ' +
                ' agf__Planned_Start_Date__c, agf__Planned_End_Date__c, agf__Delivery_Scrum_Team__r.Name, agf__Project_Manager__c, ' +
                ' agf__Project_Manager__r.Name, agf__Product_Owner_Project_Object__c, agf__Product_Owner_Project_Object__r.Name, ' +
                ' Project_Progress_Bar__c, Project_Health_Icon__c ' +
                ' FROM agf__PPM_Project__c WHERE agf__Delivery_Scrum_Team__c = \'' + String.escapeSingleQuotes(scrumTeamId) + 
                '\' WITH SECURITY_ENFORCED ORDER BY agf__Planned_Start_Date__c';

            List<agf__PPM_Project__c> projectsQuery = Database.query(query);            
            for (agf__PPM_Project__c p : projectsQuery) {
                WrapperObject w = new WrapperObject( p, 'Project' );
                projects.add(w);
            }

        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }
        
        return JSON.serialize(projects); 
    }

    private static String getEpics(Id scrumTeamId) {
        List<WrapperObject> epics = new List<WrapperObject>();
    
        try {                                    
            String query = 'SELECT Id, Name, agf__Project__c, agf__Project__r.Name, agf__Health__c, Percent_Complete__c, ' +
                ' agf__Start_Date__c, agf__End_Date__c, agf__Team__c, agf__Priority__c, Target_Audience__c, OU_Benefit__c, ' +
                ' Target_Geo_Region__c, Length_of_Learning__c, agf__Team__r.Name, Epic_Health_Color__c, Epic_Progress_Bar__c ' +
                ' FROM agf__ADM_Epic__c ' +
                ' WHERE agf__Team__c = \'' + String.escapeSingleQuotes(scrumTeamId) + 
                '\' WITH SECURITY_ENFORCED ORDER BY agf__Start_Date__c'; 
            
            System.debug('Epic Records: ' + query);

            List<agf__ADM_Epic__c> epicsQuery = Database.query(query);
            //System.Formula.recalculateFormulas(epicsQuery);
            for (agf__ADM_Epic__c e : epicsQuery) {
                WrapperObject w = new WrapperObject( e, 'Epic' );
                epics.add(w);
            }

        } catch(System.QueryException qe) {
            String error = 'Error getting Epic data: ' + qe.getMessage();
            System.debug(error);
            throw new AuraHandledException(error);
        }

        System.debug('Epic Records: ' + epics);
        return JSON.serialize(epics); 
    }

    @TestVisible
    class WrapperObject {
        Id id;
        String name;
        string parentId;
        string parentName;
        String health;
        Decimal completed;
        Date startDate;
        Date endDate;
        String team;
        Id managerId;
        String managerName;
        Id ownerId;
        String ownerName;
        String recordDetail;
        String projectDetail;
        String progressBar;
        String healthIcon;

        // epic related
        Decimal priority;
        String audience;
        String benefit;
        String geo;
        Decimal learningLength;        
        
        public WrapperObject( sObject obj, String objLabel ) {
            //String objLabel = obj.getSObjectType().getDescribe().getLabel();
            Decimal completed;
            String urlBase = System.Url.getSalesforceBaseUrl().toExternalForm();

            switch on objLabel {
                when 'Epic' {                    
                    agf__ADM_Epic__c p = (agf__ADM_Epic__c) obj;
                    completed = p.Percent_Complete__c != null ? p.Percent_Complete__c.setScale(0) : 0;
                    this.id = p.Id;
                    this.name = p.Name;
                    this.parentId = p.agf__Project__c;                    
                    this.parentName = p.agf__Project__r.Name;                    
                    this.health = p.agf__Health__c;
                    this.completed = completed;                    
                    this.startDate = p.agf__Start_Date__c;
                    this.endDate = p.agf__End_Date__c;                                                   
                    this.team = p.agf__Team__r.Name;
                    this.recordDetail = p.Id != null ? urlBase + '/lightning/r/agf__ADM_Epic__c/' + p.Id +'/view' : null;    
                    this.projectDetail = p.agf__Project__c != null 
                        ? urlBase + '/lightning/r/agf__PPM_Project__c/' + p.agf__Project__c +'/view' 
                        : null;
                                        
                    this.priority = p.agf__Priority__c;
                    this.audience = p.Target_Audience__c;
                    this.benefit = p.OU_Benefit__c;
                    this.geo = p.Target_Geo_Region__c;
                    this.learningLength = p.Length_of_Learning__c;
                    this.healthIcon = p.Epic_Health_Color__c;
                    this.progressBar = p.Epic_Progress_Bar__c;
                }                
                when 'Project' {
                    agf__PPM_Project__c p = (agf__PPM_Project__c) obj;
                    completed = p.Percent_Complete__c != null ? p.Percent_Complete__c.setScale(0) : 0;                    
                    this.id = p.Id;
                    this.name = p.Name;
                    this.parentId = p.agf__Program__c;
                    this.parentName = p.agf__Program__r.Name;
                    this.health = p.agf__Project_Health__c;
                    this.completed = completed;
                    this.startDate = p.agf__Planned_Start_Date__c;
                    this.endDate = p.agf__Planned_End_Date__c;

                    this.team = p.agf__Delivery_Scrum_Team__r.Name;
                    this.managerId = p.agf__Project_Manager__c;
                    this.managerName = p.agf__Project_Manager__r.Name;
                    this.ownerId = p.agf__Product_Owner_Project_Object__c;
                    this.ownerName = p.agf__Product_Owner_Project_Object__r.Name;                    
                    this.recordDetail = p.Id != null ? urlBase + '/lightning/r/agf__PPM_Project__c/' + p.Id +'/view' : null;
                    this.progressBar = p.Project_Progress_Bar__c;
                    this.healthIcon = p.Project_Health_Icon__c;
                }
            }
        }
    }

    @TestVisible
    class WorkObjectWrapper {
        Id id;
        String name;
        Id epic;
        String epicName;
        Id relatedWork;
        String relatedWorkName;
        String subject;
        String status;
        Id assignee;
        String assigneeName;
        Date startDate;
        Date dueDate;
        String details;
        Decimal storyPoints;
        Decimal hours;
        String team;
        String sprint;
        Id scheduledBuild;
        String scheduledBuildName;
        Decimal priority; // Backlog Rank
        Id engineer;
        String engineerName;
        Id project;
        String projectName;
        String epicDetail;
        String workDetail;
        String projectDetail;

        // date stuff 
        long startDateUTC;
        long dueDateUTC;

        public WorkObjectWrapper(agf__ADM_Work__c w) {
            String urlBase = System.Url.getSalesforceBaseUrl().toExternalForm();

            this.id = w.Id; 
            this.name = w.Name; 
            this.epic = w.agf__Epic__c; 
            this.epicName = w.agf__Epic__c != null ? w.agf__Epic__r.Name : null; 
            this.relatedWork = w.agf__Related_Work__c; 
            this.relatedWorkName = w.agf__Related_Work__c != null ? w.agf__Related_Work__r.Name : null;
            this.subject = w.agf__Subject__c; 
            this.status = w.agf__Status__c; 
            this.assignee = w.agf__Assignee__c; 
            this.assigneeName = w.agf__Assignee__c != null ? w.agf__Assignee__r.Name : null;  
            this.startDate = w.Start_Date__c;             
            this.dueDate = w.agf__Due_Date__c != null 
                ? Date.newInstance(w.agf__Due_Date__c.year(), w.agf__Due_Date__c.month(), w.agf__Due_Date__c.day()) 
                : null; 
            this.details = w.agf__Details__c; 
            this.storyPoints = w.agf__Story_Points__c; 
            this.hours = w.Hours__c; 
            this.team = w.agf__Scrum_Team__c;
            this.sprint = w.agf__Sprint__c; 
            this.scheduledBuild = w.agf__Scheduled_Build__c; 
            this.scheduledBuildName = w.agf__Scheduled_Build__c != null ? w.agf__Scheduled_Build__r.Name : null;
            this.priority = w.agf__Priority_Rank__c; // backlog Rank
            this.engineer = w.agf__QA_Engineer__c; 
            this.engineerName = w.agf__QA_Engineer__c != null ? w.agf__QA_Engineer__r.Name : null; 
            this.project = w.Project__c;
            this.projectName = w.Project__c != null ? w.Project__r.Name : null;

            Date st = w.Start_Date__c;
            this.startDateUTC = w.Start_Date__c != null 
                ? Datetime.newInstance(st.year(), st.month(), st.day(), 0, 0, 0).getTime()
                : null;            
            this.dueDateUTC = w.agf__Due_Date__c != null ? w.agf__Due_Date__c.getTime() : null;

            this.epicDetail = w.agf__Epic__c != null ? urlBase + '/lightning/r/agf__ADM_Epic__c/' + w.agf__Epic__c +'/view' : null;
            this.workDetail = w.Id != null ? urlBase + '/lightning/r/agf__ADM_Work__c/' + w.Id +'/view' : null;    
            this.projectDetail = w.Project__c != null ? urlBase + '/lightning/r/agf__PPM_Project__c/' + w.Project__c +'/view' : null;
        }
    }

    @AuraEnabled
    public static Integer SaveChanges(String jsonData, String objectName) {
        Integer recordsUpdated;

        try {                        
            if (objectName == 'Project') {
                recordsUpdated = saveProjects((List<WrapperObject>)JSON.deserialize(jsonData, List<WrapperObject>.class));
            } else if (objectName == 'Epic') {
                recordsUpdated = saveEpics((List<WrapperObject>)JSON.deserialize(jsonData, List<WrapperObject>.class));
            } else if (objectName == 'Work') {
                System.debug('saving work');
                recordsUpdated = saveWorks((List<Object>)JSON.deserializeUntyped(jsonData));
                mapWork.clear();
            }

        } catch(Exception e) {
            String err = 'An exception occurred while saving updates for ' + objectName + ': ' + e.getMessage() + 
                ' -- Line Number: ' + e.getLineNumber();
            System.debug(err);
            throw new EnablementException(err);
        } 

        return recordsUpdated;
    }

    private static Integer saveProjects(List<WrapperObject> recordList) {        
        Integer recordCount = recordList.size();           

        Map<Id, agf__PPM_Project__c> projects = new Map<Id, agf__PPM_Project__c>();

        for (WrapperObject w : recordList) {                                                
            agf__PPM_Project__c project = projects.get(w.id) != null 
                ? projects.get(w.id) : new agf__PPM_Project__c(Id = w.Id );

            if (w.health !=  null) {
                project.agf__Project_Health__c = w.health; 
            }

            if (w.startDate != null) {                
                project.agf__Planned_Start_Date__c = Date.newInstance(w.startDate.year(), w.startDate.month(), w.startDate.day());
            }

            if (w.endDate != null) {                
                project.agf__Planned_End_Date__c = Date.newInstance(w.endDate.year(), w.endDate.month(), w.endDate.day());                
            } 
                         
            projects.put(w.id, project);            
        }        

        Database.UpsertResult[] results = Database.upsert(projects.values(), false);        
        return processResults(results, projects);
    }

    private static Integer saveEpics(List<WrapperObject> recordList) {        
        Integer recordCount = recordList.size();         
        Map<Id, agf__ADM_Epic__c> epics = new Map<Id, agf__ADM_Epic__c>();

        for (WrapperObject w : recordList) {
            
            agf__ADM_Epic__c epic = new agf__ADM_Epic__c(Id = w.id);
            
            if (w.health != null) {
                epic.agf__Health__c = w.health;
            }

            if (w.startDate != null) {
                epic.agf__Start_Date__c = Date.newInstance(w.startDate.year(), w.startDate.month(), w.startDate.day());
            }
             
            if (w.endDate != null) {
                epic.agf__End_Date__c = Date.newInstance(w.endDate.year(), w.endDate.month(), w.endDate.day());
            }

            if (w.priority != null) {
                epic.agf__Priority__c = w.priority;
            }
            
            if (w.audience != null) {
                epic.Target_Audience__c = w.audience;
            }

            if (w.benefit != null) {
                epic.OU_Benefit__c = w.benefit;
            }

            if (w.geo != null) {
                epic.Target_Geo_Region__c = w.geo;
            }

            if (w.learningLength != null) {
                epic.Length_of_Learning__c = w.learningLength;
            }

            epics.put(w.id, epic);                        
        }
        
        Database.UpsertResult[] results = Database.upsert(epics.values(), false);
        return processResults(results, epics);                
    }

    private static Integer saveWorks(List<Object> result) {        
        Map<String, String> objMap = new Map<String, String>();        
        Boolean returnValue = false;        

        for(Object obj : result) {                 
            Map<String,Object> map1 = (Map<String,Object>)obj; 

            for(String key : map1.keySet()) { 
                objMap.put(key, (String)map1.get(key));
            }
            agf__ADM_Work__c workRecord = saveWork(objMap);                
        }

        System.debug('work to save: ' + mapWork.values());
        Database.UpsertResult[] results = Database.upsert(mapWork.values(), false); 
        return processResults(results, mapWork);                
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
                        rec.put(fldMap.get(key)[0], Id.valueOf(objMap.get(key)));
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

    private static Integer processResults(List<Database.UpsertResult> results, Map<Id, sObject> records) {
        Integer savedRecords = 0;
        String errorMessage;
        for(Integer i=0; i < results.size(); i++) {
            if (results.get(i).isSuccess()) {
                savedRecords += results.get(i).isSuccess() ? 1 : 0;        
            } else if (!results.get(i).isSuccess()){                
                Database.Error error = results.get(i).getErrors().get(0);
                errorMessage += error.getStatusCode() + '\n' + error.getMessage();
                errorMessage += '\n' + records.values().get(i);
                System.debug(errorMessage);
                throw new EnablementException(error.getMessage());
            }        
        }
        return savedRecords;
    }
}