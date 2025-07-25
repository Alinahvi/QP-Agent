/**
 * @isTest
 * @description This test class covers the FRAGENTChecklistAssetHandler class,
 * ensuring that checklist assets can be created, retrieved, and searched correctly.
 */
@isTest
private class FRAGENTChecklistAssetHandler_Test {

    @testSetup
    static void setupData() {
        User uCrud = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCrud, FRAGENTGeneralService.PERM_LABEL_CRUD, 'crud');
        
        System.runAs(uCrud) {
            FRAGENTTestDataFactory.createChecklists(1, true);
            FRAGENTTestDataFactory.createAssets(1, true);
        }
    }

    private static User getUser(String alias) {
        return [SELECT Id FROM User WHERE Alias = :alias ORDER BY CreatedDate DESC LIMIT 1];
    }
    
    @isTest
    static void testHandler_Create() {
        System.runAs(getUser('crud')) {
            FRAGENTChecklistAssetHandler.Request req = new FRAGENTChecklistAssetHandler.Request();
            req.action = 'Create';
            req.checklistId = [SELECT Id FROM Checklist__c LIMIT 1].Id;
            req.assetId = [SELECT Id FROM Asset__c LIMIT 1].Id;
            
            Test.startTest();
            List<FRAGENTChecklistAssetHandler.Response> resList = FRAGENTChecklistAssetHandler.manageChecklistAssets(new List<FRAGENTChecklistAssetHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Create action');
            System.assertEquals(1, resList[0].records.size(), 'Should create one record');
        }
    }

    @isTest
    static void testHandler_Read() {
        Id recordId;
        System.runAs(getUser('crud')) {
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Asset__c asset = [SELECT Id FROM Asset__c LIMIT 1];
            Checklist_Asset__c rec = new Checklist_Asset__c(Checklist__c = chk.Id, Asset__c = asset.Id);
            insert rec;
            recordId = rec.Id;
        }

        System.runAs(getUser('crud')) {
            FRAGENTChecklistAssetHandler.Request req = new FRAGENTChecklistAssetHandler.Request();
            req.action = 'Read';
            req.checklistAssetId = recordId;
            
            Test.startTest();
            List<FRAGENTChecklistAssetHandler.Response> resList = FRAGENTChecklistAssetHandler.manageChecklistAssets(new List<FRAGENTChecklistAssetHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Read action');
            System.assertEquals(1, resList[0].records.size());
        }
    }

    @isTest
    static void testHandler_Update() {
        Id recordId;
        System.runAs(getUser('crud')) {
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Asset__c asset = [SELECT Id FROM Asset__c LIMIT 1];
            Checklist_Asset__c rec = new Checklist_Asset__c(Checklist__c = chk.Id, Asset__c = asset.Id);
            insert rec;
            recordId = rec.Id;
        }
        
        System.runAs(getUser('crud')) {
            FRAGENTChecklistAssetHandler.Request req = new FRAGENTChecklistAssetHandler.Request();
            req.action = 'Update';
            req.checklistAssetId = recordId;
            req.description = 'Updated Description';
            
            Test.startTest();
            List<FRAGENTChecklistAssetHandler.Response> resList = FRAGENTChecklistAssetHandler.manageChecklistAssets(new List<FRAGENTChecklistAssetHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Update action');
            System.assertEquals('Updated Description', resList[0].records[0].Description__c);
        }
    }

    @isTest
    static void testHandler_Delete() {
        System.runAs(getUser('crud')) {
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Asset__c asset = [SELECT Id FROM Asset__c LIMIT 1];
            Checklist_Asset__c rec = new Checklist_Asset__c(Checklist__c = chk.Id, Asset__c = asset.Id);
            insert rec;

            FRAGENTChecklistAssetHandler.Request req = new FRAGENTChecklistAssetHandler.Request();
            req.action = 'Delete';
            req.checklistAssetId = rec.Id;

            Test.startTest();
            List<FRAGENTChecklistAssetHandler.Response> resList = FRAGENTChecklistAssetHandler.manageChecklistAssets(new List<FRAGENTChecklistAssetHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Delete action');
            System.assertEquals(0, [SELECT count() FROM Checklist_Asset__c WHERE Id = :rec.Id]);
        }
    }

    @isTest
    static void testHandler_Search() {
         System.runAs(getUser('crud')) {
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Asset__c asset = [SELECT Id FROM Asset__c LIMIT 1];
            insert new Checklist_Asset__c(Checklist__c = chk.Id, Asset__c = asset.Id);

            FRAGENTChecklistAssetHandler.Request req = new FRAGENTChecklistAssetHandler.Request();
            req.action = 'Search';
            req.checklistId = chk.Id;

            Test.startTest();
            List<FRAGENTChecklistAssetHandler.Response> resList = FRAGENTChecklistAssetHandler.manageChecklistAssets(new List<FRAGENTChecklistAssetHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Search action');
            System.assertEquals(1, resList[0].totalRecordCount);
        }
    }
    
    @isTest
    static void testHandler_NoActionSpecified() {
        System.runAs(getUser('crud')) {
            FRAGENTChecklistAssetHandler.Request req = new FRAGENTChecklistAssetHandler.Request();
            req.action = '';
            
            List<FRAGENTChecklistAssetHandler.Response> resList = FRAGENTChecklistAssetHandler.manageChecklistAssets(new List<FRAGENTChecklistAssetHandler.Request>{req});
            
            System.assert(!resList[0].success, 'Should fail when no action is specified');
            System.assert(resList[0].message.contains('Action parameter is required'));
        }
    }
}