/**
 * @isTest
 * @description This test class provides comprehensive coverage for the FRAGENTChecklistHandler class.
 * It verifies all core functionality, including creation, searching, and error handling.
 */
@isTest
private class FRAGENTChecklistHandler_Test {

    @testSetup
    static void setupData() {
        User uCrud = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCrud, FRAGENTGeneralService.PERM_LABEL_CRUD, 'crud');
        
        System.runAs(uCrud) {
            FRAGENTTestDataFactory.createChecklists(1, true);
        }
    }

    private static User getUser(String alias) {
        return [SELECT Id FROM User WHERE Alias = :alias ORDER BY CreatedDate DESC LIMIT 1];
    }
    
    @isTest
    static void testHandler_Create() {
        System.runAs(getUser('crud')) {
            FRAGENTChecklistHandler.Request req = new FRAGENTChecklistHandler.Request();
            req.action = 'Create';
            req.checklistName = 'New Test Checklist';
            
            Test.startTest();
            List<FRAGENTChecklistHandler.Response> resList = FRAGENTChecklistHandler.manageChecklists(new List<FRAGENTChecklistHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Create action');
            System.assertEquals(1, resList[0].records.size(), 'Should create one record');
        }
    }

    @isTest
    static void testHandler_Read() {
        Id recordId;
        System.runAs(getUser('crud')) {
            recordId = [SELECT Id FROM Checklist__c LIMIT 1].Id;
        }

        System.runAs(getUser('crud')) {
            FRAGENTChecklistHandler.Request req = new FRAGENTChecklistHandler.Request();
            req.action = 'Read';
            req.checklistId = recordId;
            
            Test.startTest();
            List<FRAGENTChecklistHandler.Response> resList = FRAGENTChecklistHandler.manageChecklists(new List<FRAGENTChecklistHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Read action');
            System.assertEquals(1, resList[0].records.size());
        }
    }

    @isTest
    static void testHandler_Update() {
        Id recordId;
        System.runAs(getUser('crud')) {
            recordId = [SELECT Id FROM Checklist__c LIMIT 1].Id;
        }
        
        System.runAs(getUser('crud')) {
            FRAGENTChecklistHandler.Request req = new FRAGENTChecklistHandler.Request();
            req.action = 'Update';
            req.checklistId = recordId;
            req.checklistName = 'Updated Name';
            
            Test.startTest();
            List<FRAGENTChecklistHandler.Response> resList = FRAGENTChecklistHandler.manageChecklists(new List<FRAGENTChecklistHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Update action');
            System.assertEquals('Updated Name', resList[0].records[0].Name);
        }
    }

    @isTest
    static void testHandler_Delete() {
        System.runAs(getUser('crud')) {
            Checklist__c rec = [SELECT Id FROM Checklist__c LIMIT 1];
            FRAGENTChecklistHandler.Request req = new FRAGENTChecklistHandler.Request();
            req.action = 'Delete';
            req.checklistId = rec.Id;

            Test.startTest();
            List<FRAGENTChecklistHandler.Response> resList = FRAGENTChecklistHandler.manageChecklists(new List<FRAGENTChecklistHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Delete action');
            System.assertEquals(0, [SELECT count() FROM Checklist__c WHERE Id = :rec.Id]);
        }
    }

    @isTest
    static void testHandler_Search() {
         System.runAs(getUser('crud')) {
            FRAGENTChecklistHandler.Request req = new FRAGENTChecklistHandler.Request();
            req.action = 'Search';
            req.searchTerm = 'Test';

            Test.startTest();
            List<FRAGENTChecklistHandler.Response> resList = FRAGENTChecklistHandler.manageChecklists(new List<FRAGENTChecklistHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Search action');
            System.assertEquals(1, resList[0].totalRecordCount);
        }
    }
    
    @isTest
    static void testHandler_NoActionSpecified() {
        System.runAs(getUser('crud')) {
            FRAGENTChecklistHandler.Request req = new FRAGENTChecklistHandler.Request();
            req.action = '';
            
            List<FRAGENTChecklistHandler.Response> resList = FRAGENTChecklistHandler.manageChecklists(new List<FRAGENTChecklistHandler.Request>{req});
            
            System.assert(!resList[0].success, 'Should fail when no action is specified');
            System.assert(resList[0].message.contains('Action parameter is required'));
        }
    }
}