@isTest
public with sharing class TicketControllerTest {
    static final String DEFAULT_PROJECT_ID = 'a5E2E000000EaCIUA0';

    @testSetup
    static void setup() {
        // Create a Project
        agf__PPM_Project__c project = new agf__PPM_Project__c(Name = 'Test Project');
        insert project;
        // Create an Epic
        agf__ADM_Epic__c epic = new agf__ADM_Epic__c(Name = 'Test Epic', agf__Project__c = project.Id);
        insert epic;
        // Create a Work (do not set Name if auto-numbered)
        agf__ADM_Work__c work = new agf__ADM_Work__c(agf__Epic__c = epic.Id, agf__Status__c = 'Open');
        insert work;
    }

    @isTest
    static void testGetProjects() {
        List<agf__PPM_Project__c> projects = TicketController.getProjects();
        System.assert(!projects.isEmpty(), 'Should return at least one project');
    }

    @isTest
    static void testGetEpics() {
        agf__PPM_Project__c project = [SELECT Id FROM agf__PPM_Project__c LIMIT 1];
        List<agf__ADM_Epic__c> epics = TicketController.getEpics(project.Id);
        System.assert(!epics.isEmpty(), 'Should return at least one epic');
    }

    @isTest
    static void testGetWorks() {
        agf__ADM_Epic__c epic = [SELECT Id FROM agf__ADM_Epic__c LIMIT 1];
        List<agf__ADM_Work__c> works = TicketController.getWorks(epic.Id);
        System.assert(!works.isEmpty(), 'Should return at least one work');
    }

    @isTest
    static void testSaveTicket_NewEpicAndWork() {
        agf__PPM_Project__c project = [SELECT Id FROM agf__PPM_Project__c LIMIT 1];
        String url = TicketController.saveTicket(project.Id, 'NEW', 'NEW', 'Test Desc', null, null);
        System.assert(url != null && url.contains('/lightning/r/agf__ADM_Work__c/'), 'Should return a Work record URL');
    }

    @isTest
    static void testSaveTicket_UpdateWork() {
        agf__ADM_Epic__c epic = [SELECT Id FROM agf__ADM_Epic__c LIMIT 1];
        agf__ADM_Work__c work = [SELECT Id FROM agf__ADM_Work__c WHERE agf__Epic__c = :epic.Id LIMIT 1];
        String url = TicketController.saveTicket(epic.agf__Project__c, epic.Id, work.Id, 'Updated Desc', null, null);
        System.assert(url != null && url.contains(work.Id), 'Should return the updated Work record URL');
    }

    @isTest
    static void testSaveTicket_NewWorkUnderExistingEpic() {
        agf__ADM_Epic__c epic = [SELECT Id, agf__Project__c FROM agf__ADM_Epic__c LIMIT 1];
        String url = TicketController.saveTicket(epic.agf__Project__c, epic.Id, 'NEW', 'Another Desc', null, null);
        System.assert(url != null && url.contains('/lightning/r/agf__ADM_Work__c/'), 'Should return a Work record URL');
    }

    @isTest
    static void testSaveTicket_MissingProjectDefaults() {
        String url = TicketController.saveTicket(null, 'NEW', 'NEW', 'Default Project Desc', null, null);
        System.assert(url != null && url.contains('/lightning/r/agf__ADM_Work__c/'), 'Should return a Work record URL');
    }
}