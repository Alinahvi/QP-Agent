public with sharing class EnablementEditableWork {
    
    public class EnablementException extends Exception {}

    @AuraEnabled
    public static String getRecordTypeName(Id recordId) {
        System.debug('Get Record Type Name: ' + recordId);
        String objLabel = recordId.getSObjectType().getDescribe().getLabel();

        String query = 'SELECT Id, RecordType.Id, RecordType.Name FROM agf__ADM_Work__c WHERE ';
        query += (objLabel == 'Project' ? 'Project__c' : 'agf__Epic__c') + ' = \'' + recordId + '\' LIMIT 1';
        System.debug('THE RECORD TYPE QUERY STRING: ' + query);

        agf__ADM_Work__c work = Database.query(query);
        System.debug('the record type is: ' + work);
        return work.RecordType.Name;
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

            this.epicDetail = urlBase + '/lightning/r/agf__ADM_Epic__c/' + w.agf__Epic__c +'/view';
            this.workDetail = urlBase + '/lightning/r/agf__ADM_Work__c/' + w.agf__Related_Work__c +'/view';    
            this.projectDetail = urlBase + '/lightning/r/agf__PPM_Project__c/' + w.Project__c +'/view';
        }
    }

    @AuraEnabled
    public static String getListViewData(Id recordId) {
        System.debug('what is the value: ' + recordId);
        String objLabel = recordId.getSObjectType().getDescribe().getLabel();
        System.debug(' the lable name is: ' + objLabel);
        return getWork(recordId, objLabel);
    }

    private static string getWork(Id recordId, String objLabel) {
        List<WorkObjectWrapper> wow = new List<WorkObjectWrapper>();
        try {
            String query = 'SELECT Id, Name, agf__Epic__c, agf__Related_Work__c, agf__Subject__c, agf__Status__c, ' +
                'agf__Assignee__c, Start_Date__c, agf__Due_Date__c, agf__Details__c, agf__Story_Points__c, Hours__c, agf__Scrum_Team__c, ' +
                'agf__Sprint__c, agf__Scheduled_Build__c, agf__Scheduled_Build__r.Name, agf__Priority_Rank__c, agf__QA_Engineer__c, Project__c, ' +
                'agf__Epic__r.Name, agf__Related_Work__r.Name, agf__Assignee__r.Name, agf__QA_Engineer__r.Name, Project__r.Name ' +
                'FROM agf__ADM_Work__c WHERE '; 
                query += (objLabel == 'Project' ? 'Project__c' : 'agf__Epic__c') + ' = \'' 
                    + recordId + '\' WITH SECURITY_ENFORCED ORDER BY Name';

            System.debug('The Query: ' + query);

            for (agf__ADM_Work__c w : Database.query(query)) {                
                wow.add(new WorkObjectWrapper(w));
            }
        } catch (System.QueryException qe) {
            System.debug(qe.getMessage());
        }

        return JSON.serialize(wow);
    }

    @AuraEnabled
    public static Integer saveUpdatedRecords(String updatedRecords ) {
        Integer recordsUpdated;
        String objectLabel;

        try {            
            List<WorkObjectWrapper> deserializedRecords = 
                (List<WorkObjectWrapper>)JSON.deserialize(updatedRecords, List<WorkObjectWrapper>.class);
            Id recordId = deserializedRecords[0].id;

            saveWork(deserializedRecords);

        } catch(Exception e) {
            String err = 'An exception occurred while saving updates for Work data: ' + e.getMessage() + 
                ' -- Line Number: ' + e.getLineNumber();
            System.debug(err);
            throw new EnablementException(err);
        } 

        return recordsUpdated;
    }

    private static Integer saveWork(List<WorkObjectWrapper> recordList) {        
        Integer recordCount = recordList.size();
        Integer goodCounter = 0;        

        List<agf__ADM_Work__c> work = new List<agf__ADM_Work__c>();

        for (WorkObjectWrapper w : recordList) {
            work.add(
                new agf__ADM_Work__c(
                    Id = w.Id,
                    Start_Date__c = DateTime.newInstance(w.startDateUTC).date(), 
                    agf__Due_Date__c =  DateTime.newInstance(w.dueDateUTC).date()                    
                )
            );
        }        

        Database.UpsertResult[] results = Database.upsert(work, false);
        for(Database.upsertResult result : results){
            goodCounter += result.isSuccess() ? 1 : 0;              
        }

        return goodCounter;
    }

}