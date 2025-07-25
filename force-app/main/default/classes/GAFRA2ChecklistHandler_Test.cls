@isTest
private class GAFRA2ChecklistHandler_Test {

    @isTest
    static void testCreateChecklist_Success() {
        List<GAFRA2ChecklistHandler.Request> requests = new List<GAFRA2ChecklistHandler.Request>();
        GAFRA2ChecklistHandler.Request req = new GAFRA2ChecklistHandler.Request();
        req.actionType = GAFRA2Constants.ACTION_TYPE_CREATE;
        req.checklistName = 'Test Checklist';
        requests.add(req);

        Test.startTest();
        List<GAFRA2ChecklistHandler.Response> responses = GAFRA2ChecklistHandler.manageChecklist(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(true, responses[0].success);
        System.assertEquals(1, responses[0].checklistRecords.size());
        System.assertEquals('Test Checklist', responses[0].checklistRecords[0].Name);
    }
    
    @isTest
    static void testModifyChecklist_Success() {
        List<Checklist__c> testChecklists = GAFRA2TestFactory.createChecklists(1);
        
        List<GAFRA2ChecklistHandler.Request> requests = new List<GAFRA2ChecklistHandler.Request>();
        GAFRA2ChecklistHandler.Request req = new GAFRA2ChecklistHandler.Request();
        req.actionType = GAFRA2Constants.ACTION_TYPE_MODIFY;
        req.checklistId = testChecklists[0].Id;
        req.checklistName = 'Modified Test Checklist';
        requests.add(req);

        Test.startTest();
        List<GAFRA2ChecklistHandler.Response> responses = GAFRA2ChecklistHandler.manageChecklist(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(true, responses[0].success);
        System.assertEquals(1, responses[0].checklistRecords.size());
        System.assertEquals('Modified Test Checklist', responses[0].checklistRecords[0].Name);
    }

    @isTest
    static void testRetrieveChecklist_Success() {
        List<Checklist__c> testChecklists = GAFRA2TestFactory.createChecklists(1);

        List<GAFRA2ChecklistHandler.Request> requests = new List<GAFRA2ChecklistHandler.Request>();
        GAFRA2ChecklistHandler.Request req = new GAFRA2ChecklistHandler.Request();
        req.actionType = GAFRA2Constants.ACTION_TYPE_RETRIEVE;
        req.checklistId = testChecklists[0].Id;
        requests.add(req);

        Test.startTest();
        List<GAFRA2ChecklistHandler.Response> responses = GAFRA2ChecklistHandler.manageChecklist(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(true, responses[0].success);
        System.assertEquals(1, responses[0].checklistRecords.size());
        System.assertEquals(testChecklists[0].Id, responses[0].checklistRecords[0].Id);
    }
    
    @isTest
    static void testSearchChecklist_byName_Success() {
        GAFRA2TestFactory.createChecklists(5);
        
        List<GAFRA2ChecklistHandler.Request> requests = new List<GAFRA2ChecklistHandler.Request>();
        GAFRA2ChecklistHandler.Request req = new GAFRA2ChecklistHandler.Request();
        req.actionType = GAFRA2Constants.ACTION_TYPE_SEARCH;
        req.checklistName = 'Test Checklist 2';
        requests.add(req);

        Test.startTest();
        List<GAFRA2ChecklistHandler.Response> responses = GAFRA2ChecklistHandler.manageChecklist(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(true, responses[0].success);
        System.assertEquals(1, responses[0].checklistRecords.size());
        System.assertEquals('Test Checklist 2', responses[0].checklistRecords[0].Name);
    }
    
    @isTest
    static void testCreateChecklist_Bulk_Success() {
        List<GAFRA2ChecklistHandler.Request> requests = new List<GAFRA2ChecklistHandler.Request>();
        for(Integer i=0; i<3; i++){
            GAFRA2ChecklistHandler.Request req = new GAFRA2ChecklistHandler.Request();
            req.actionType = GAFRA2Constants.ACTION_TYPE_CREATE;
            req.checklistName = 'Bulk Checklist ' + i;
            requests.add(req);
        }

        Test.startTest();
        List<GAFRA2ChecklistHandler.Response> responses = GAFRA2ChecklistHandler.manageChecklist(requests);
        Test.stopTest();

        System.assertEquals(3, responses.size());
        for(GAFRA2ChecklistHandler.Response res : responses){
            System.assertEquals(true, res.success);
            System.assertEquals(1, res.checklistRecords.size());
        }
    }
    
    @isTest
    static void testCreateChecklist_MissingName_Error() {
        List<GAFRA2ChecklistHandler.Request> requests = new List<GAFRA2ChecklistHandler.Request>();
        GAFRA2ChecklistHandler.Request req = new GAFRA2ChecklistHandler.Request();
        req.actionType = GAFRA2Constants.ACTION_TYPE_CREATE;
        req.checklistName = null;
        requests.add(req);

        Test.startTest();
        List<GAFRA2ChecklistHandler.Response> responses = GAFRA2ChecklistHandler.manageChecklist(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size());
        System.assertEquals(false, responses[0].success);
        System.assertEquals('Error: Checklist Name is required for Create.', responses[0].message);
    }
}