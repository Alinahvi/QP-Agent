public with sharing class EnablementEditableListviewController {

    public class EnablementException extends Exception {}
    private enum Picklist {PROGRAM, PROJECT, EPIC}
    private static List<String> supportedObjectNames = new List<String>{'agf__PPM_Program__c', 'agf__PPM_Project__c', 'agf__ADM_Epic__c'};
    private static List<String> picklistFields = new List<String>{'agf__Program_Health__c', 'agf__Project_Health__c', 'agf__Health__c'};

    @AuraEnabled
    public static string getListViewData(Id recordId){
        String objectLabel = getsObjectLabel(recordId);
        try {
            switch on objectLabel {
                when 'Project' {
                    return getEpics(recordId);
                }
                when 'Program' {
                    return getProjects(recordId);
                }
                when else {
                    //throw new EnablementException('The specified sObject (objectLabel) is not currently supported');
                    return '';//testing is calling this not sure why yet.
                }
            }
        } catch (Exception e) {
            System.debug('The Label Is: ' + objectLabel);
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getProjects(Id programId) {
        List<WrapperObject> projects = new List<WrapperObject>();
    
        try {                                    
            String query = 'SELECT Id, Name, agf__Program__c, agf__Program__r.Name, agf__Project_Health__c, Percent_Complete__c, ' +
                ' agf__Planned_Start_Date__c, agf__Planned_End_Date__c, agf__Delivery_Scrum_Team__r.Name, agf__Project_Manager__c, ' +
                ' agf__Project_Manager__r.Name, agf__Product_Owner_Project_Object__c, agf__Product_Owner_Project_Object__r.Name, ' +
                ' Project_Progress_Bar__c, Project_Health_Icon__c ' +
                ' FROM agf__PPM_Project__c WHERE agf__Program__c = \'' + String.escapeSingleQuotes(programId) + 
                '\' WITH SECURITY_ENFORCED ORDER BY agf__Planned_Start_Date__c';

            List<agf__PPM_Project__c> projectsQuery = Database.query(query);
            //System.Formula.recalculateFormulas(projectsQuery);
            for (agf__PPM_Project__c p : projectsQuery) {
                WrapperObject w = new WrapperObject( p, 'Project' );
                projects.add(w);
            }

        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }

        System.debug('UPDATED FORMULA FIELD: ' + projects);
        return JSON.serialize(projects); 
    }

    private static String getEpics(Id recordId) {
        List<WrapperObject> epics = new List<WrapperObject>();
    
        try {                                    
            String query = 'SELECT Id, Name, agf__Project__c, agf__Project__r.Name, agf__Health__c, Percent_Complete__c, ' +
                ' agf__Start_Date__c, agf__End_Date__c, agf__Team__c, agf__Priority__c, Target_Audience__c, OU_Benefit__c, ' +
                ' Target_Geo_Region__c, Length_of_Learning__c, agf__Team__r.Name, Epic_Health_Color__c, Epic_Progress_Bar__c ' +
                ' FROM agf__ADM_Epic__c ' +
                ' WHERE agf__Project__c = \'' + String.escapeSingleQuotes(recordId) + 
                '\' WITH SECURITY_ENFORCED ORDER BY agf__Start_Date__c'; 
            
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
                    this.recordDetail = urlBase + '/lightning/r/agf__ADM_Epic__c/' + p.Id +'/view';    
                    this.projectDetail = urlBase + '/lightning/r/agf__PPM_Project__c/' + p.agf__Project__c +'/view';
                                        
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
                    this.recordDetail = urlBase + '/lightning/r/agf__PPM_Project__c/' + p.Id +'/view';
                    this.progressBar = p.Project_Progress_Bar__c;
                    this.healthIcon = p.Project_Health_Icon__c;
                }
            }
        }
    }

    @AuraEnabled
    public static Integer saveUpdatedRecords(String updatedRecords ) {
        Integer recordsUpdated;
        String objectLabel;

        try {            
            List<WrapperObject> deserializedRecords = 
                (List<WrapperObject>)JSON.deserialize(updatedRecords, List<WrapperObject>.class);
            Id recordId = deserializedRecords[0].id;

            objectLabel = recordId.getSObjectType().getDescribe().getLabel();
            if (objectLabel == 'Project') {
                recordsUpdated = saveProjects(deserializedRecords);
            } else if (objectLabel == 'Epic') {
                recordsUpdated = saveEpics(deserializedRecords);
            }

        } catch(Exception e) {
            String err = 'An exception occurred while saving updates for ' + objectLabel + ': ' + e.getMessage() + 
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
            }        
        }
        return savedRecords;
    }

    @AuraEnabled
    public static string getsObjectLabel(Id recordId){
        return recordId.getSObjectType().getDescribe().getLabel();
    }
}