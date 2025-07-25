// Apex controller for ticket creation/updating
public with sharing class TicketController {
    public static final String DEFAULT_PROJECT_ID = 'a5E2E000000EaCIUA0';
    public static final Integer SOQL_LIMIT = 500;

    @AuraEnabled(cacheable=true)
    public static List<agf__PPM_Project__c> getProjects() {
        if (!Schema.sObjectType.agf__PPM_Project__c.isAccessible()) return new List<agf__PPM_Project__c>();
        return [SELECT Id, Name FROM agf__PPM_Project__c LIMIT :SOQL_LIMIT];
    }

    @AuraEnabled(cacheable=true)
    public static List<agf__ADM_Epic__c> getEpics(String projectId) {
        if (!Schema.sObjectType.agf__ADM_Epic__c.isAccessible()) return new List<agf__ADM_Epic__c>();
        if (String.isBlank(projectId)) projectId = DEFAULT_PROJECT_ID;
        return [SELECT Id, Name FROM agf__ADM_Epic__c WHERE agf__Project__c = :projectId LIMIT :SOQL_LIMIT];
    }

    @AuraEnabled(cacheable=true)
    public static List<agf__ADM_Work__c> getWorks(String epicId) {
        if (!Schema.sObjectType.agf__ADM_Work__c.isAccessible()) return new List<agf__ADM_Work__c>();
        if (String.isBlank(epicId)) return new List<agf__ADM_Work__c>();
        return [SELECT Id, Name FROM agf__ADM_Work__c WHERE agf__Epic__c = :epicId LIMIT :SOQL_LIMIT];
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getProductTags() {
        List<Map<String, String>> tags = new List<Map<String, String>>();
        for (AggregateResult ar : [
            SELECT agf__Product_Tag__c tagId, agf__Product_Tag_Name__c tagName
            FROM agf__ADM_Work__c
            WHERE agf__Product_Tag__c != null AND agf__Product_Tag_Name__c != null
            GROUP BY agf__Product_Tag__c, agf__Product_Tag_Name__c
            ORDER BY agf__Product_Tag_Name__c
        ]) {
            tags.add(new Map<String, String>{
                'id' => (String)ar.get('tagId'),
                'name' => (String)ar.get('tagName')
            });
        }
        return tags;
    }

    public class TicketInput {
        @InvocableVariable(label='Project ID' description='ID of the project')
        public String projectId;
        @InvocableVariable(label='Epic ID or NEW' description='ID of the epic or "NEW" to create a new epic')
        public String epicIdOrNewLabel;
        @InvocableVariable(label='Work ID or NEW' description='ID of the work item or "NEW" to create a new work item')
        public String workIdOrNewLabel;
        @InvocableVariable(label='Description' description='Description of the ticket')
        public String description;
        @InvocableVariable(label='Assignee ID' description='ID of the assignee (optional)')
        public String assigneeId;
        @InvocableVariable(label='Product Tag ID' description='ID of the product tag (optional)')
        public String productTagId;
    }

    @InvocableMethod(label='Create or Update Work Ticket' description='Creates or updates a Work ticket under a Project/Epic/Work hierarchy using IDs.')
    public static List<String> createOrUpdateWorkTicket(List<TicketInput> inputs) {
        List<String> results = new List<String>();
        for (TicketInput input : inputs) {
            String result = saveTicket(
                input.projectId, 
                input.epicIdOrNewLabel, 
                input.workIdOrNewLabel, 
                input.description, 
                input.assigneeId, 
                input.productTagId
            );
            results.add(result);
        }
        return results;
    }

    @AuraEnabled
    public static String saveTicket(String projectId, String epicIdOrNewLabel, String workIdOrNewLabel, String description, String assigneeId, String productTagId) {
        if (String.isBlank(projectId)) projectId = DEFAULT_PROJECT_ID;
        if (String.isBlank(productTagId)) productTagId = 'a4SHu000005tUhlMAE';
        agf__ADM_Epic__c epic;
        agf__ADM_Work__c work;
        // Create new Epic if needed
        if (epicIdOrNewLabel == 'NEW') {
            epic = new agf__ADM_Epic__c(agf__Project__c=projectId);
            if (Schema.sObjectType.agf__ADM_Epic__c.fields.agf__Description__c.isCreateable()) epic.agf__Description__c = description;
            insert epic;
        } else {
            if (String.isBlank(epicIdOrNewLabel)) {
                return 'ERROR: Epic Id is required or use "NEW" to create a new Epic.';
            }
            List<agf__ADM_Epic__c> epics = [SELECT Id FROM agf__ADM_Epic__c WHERE Id = :epicIdOrNewLabel LIMIT 1];
            if (epics.isEmpty()) {
                return 'ERROR: No Epic found for the provided Id: ' + epicIdOrNewLabel;
            }
            epic = epics[0];
        }
        // Create or update Work
        if (workIdOrNewLabel == 'NEW') {
            work = new agf__ADM_Work__c(
                agf__Epic__c=epic.Id,
                agf__Status__c='Open',
                agf__Scrum_Team__c='a4f2E0000006bQHQAY',
                agf__Product_Tag__c=productTagId,
                agf__Subject__c='Default Subject'
            );
            if (Schema.sObjectType.agf__ADM_Work__c.fields.agf__Description__c.isCreateable()) work.agf__Description__c = description;
            if (!String.isBlank(assigneeId) && Schema.sObjectType.agf__ADM_Work__c.fields.agf__Assignee__c.isCreateable()) work.agf__Assignee__c = assigneeId;
            insert work;
            // Query for Name after insert
            work = [SELECT Id, Name FROM agf__ADM_Work__c WHERE Id = :work.Id LIMIT 1];
        } else {
            work = [SELECT Id, agf__Description__c, agf__Assignee__c, Name FROM agf__ADM_Work__c WHERE Id = :workIdOrNewLabel LIMIT 1];
            if (Schema.sObjectType.agf__ADM_Work__c.fields.agf__Description__c.isUpdateable()) work.agf__Description__c = description;
            if (!String.isBlank(assigneeId) && Schema.sObjectType.agf__ADM_Work__c.fields.agf__Assignee__c.isUpdateable()) work.agf__Assignee__c = assigneeId;
            update work;
            // Query for Name after update (in case it changed)
            work = [SELECT Id, Name FROM agf__ADM_Work__c WHERE Id = :work.Id LIMIT 1];
        }
        String url = System.Url.getOrgDomainUrl().toExternalForm() + '/lightning/r/agf__ADM_Work__c/' + work.Id + '/view';
        return 'Ticket ' + work.Name + ': ' + url;
    }

    // Removed TicketRequest class and createOrUpdateWorkByName method

    @AuraEnabled(cacheable=true)
    public static List<String> getProjectNames() {
        List<String> names = new List<String>();
        for (agf__PPM_Project__c p : [SELECT Name FROM agf__PPM_Project__c ORDER BY Name]) {
            names.add(p.Name);
        }
        return names;
    }
}