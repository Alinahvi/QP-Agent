@isTest
private class FRAGENTChecklistAssetService_Test {

    @testSetup
    static void setupData() {
        User uCrud = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCrud, FRAGENTGeneralService.PERM_LABEL_CRUD, 'crud');
        
        User uCru = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCru, FRAGENTGeneralService.PERM_LABEL_CRU, 'cru');

        System.runAs(uCrud) {
            FRAGENTTestDataFactory.createChecklists(1, true);
            FRAGENTTestDataFactory.createAssets(1, true);
        }
    }

    private static User getUser(String alias) {
        return [SELECT Id FROM User WHERE Alias = :alias ORDER BY CreatedDate DESC LIMIT 1];
    }
    
    // =================================================================================
    // CREATE Method Tests
    // =================================================================================
    @isTest
    static void testCreate_Succeeds() {
        System.runAs(getUser('crud')) {
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Asset__c asset = [SELECT Id FROM Asset__c LIMIT 1];
            List<Checklist_Asset__c> inputs = new List<Checklist_Asset__c>{
                new Checklist_Asset__c(Checklist__c = chk.Id, Asset__c = asset.Id)
            };
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTChecklistAssetService.create(inputs);
            Test.stopTest();

            System.assert(res.success, 'Expected success on valid input');
            System.assertEquals(1, res.records.size(), 'Exactly one record should be created');
            Checklist_Asset__c created = (Checklist_Asset__c)res.records[0];
            System.assertNotEquals(null, created.Checklist__r.Name, 'Checklist name should be returned');
            System.assertNotEquals(null, created.Asset__r.Name, 'Asset name should be returned');
        }
    }
    
    // =================================================================================
    // UPDATE Method Tests
    // =================================================================================
    @isTest
    static void testUpdate_Succeeds() {
        Id recordId;
        System.runAs(getUser('crud')) {
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Asset__c asset = [SELECT Id FROM Asset__c LIMIT 1];
            Checklist_Asset__c rec = new Checklist_Asset__c(Checklist__c = chk.Id, Asset__c = asset.Id);
            insert rec;
            recordId = rec.Id;
        }

        System.runAs(getUser('crud')) {
            Checklist_Asset__c toUpdate = new Checklist_Asset__c(Id = recordId, Description__c = 'Updated Description');
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTChecklistAssetService.updateRecords(new List<Checklist_Asset__c>{toUpdate});
            Test.stopTest();
            System.assert(res.success, 'Update should succeed for CRUD user');
            System.assertEquals('Updated Description', ((Checklist_Asset__c)res.records[0]).Description__c);
            Checklist_Asset__c updated = (Checklist_Asset__c)res.records[0];
            System.assertNotEquals(null, updated.Checklist__r.Name, 'Checklist name should be returned');
            System.assertNotEquals(null, updated.Asset__r.Name, 'Asset name should be returned');
        }
    }

    // =================================================================================
    // REMOVE Method Tests
    // =================================================================================
    @isTest
    static void testRemove_Succeeds() {
        System.runAs(getUser('crud')) {
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Asset__c asset = [SELECT Id FROM Asset__c LIMIT 1];
            Checklist_Asset__c rec = new Checklist_Asset__c(Checklist__c = chk.Id, Asset__c = asset.Id);
            insert rec;
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTChecklistAssetService.remove(new List<Id>{rec.Id});
            Test.stopTest();
            
            System.assert(res.success, 'Remove should succeed');
            System.assertEquals(0, [SELECT count() FROM Checklist_Asset__c WHERE Id = :rec.Id]);
        }
    }
    
    // =================================================================================
    // SEARCH and GET Method Tests
    // =================================================================================
    @isTest
    static void testSearch_Succeeds() {
        System.runAs(getUser('crud')) {
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Asset__c asset = [SELECT Id FROM Asset__c LIMIT 1];
            insert new Checklist_Asset__c(Checklist__c = chk.Id, Asset__c = asset.Id, Description__c = 'Searchable');
        }

        System.runAs(getUser('cru')) {
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            FRAGENTChecklistAssetService.SearchResult res = FRAGENTChecklistAssetService.search(chk.Id, 'Searchable', null, null, null, null, 10, 0);
            
            System.assert(res.success, 'Search should succeed for CRU user');
            System.assertEquals(1, res.records.size());
            System.assertEquals(1, res.totalCount);
            Checklist_Asset__c result = (Checklist_Asset__c)res.records[0];
            System.assertNotEquals(null, result.Checklist__r.Name, 'Checklist name should be returned');
            System.assertNotEquals(null, result.Asset__r.Name, 'Asset name should be returned');
        }
    }

    @isTest
    static void testGetById_Succeeds() {
        Id recordId;
        System.runAs(getUser('crud')) {
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Asset__c asset = [SELECT Id FROM Asset__c LIMIT 1];
            Checklist_Asset__c rec = new Checklist_Asset__c(Checklist__c = chk.Id, Asset__c = asset.Id);
            insert rec;
            recordId = rec.Id;
        }

        System.runAs(getUser('cru')) {
            FRAGENTGeneralService.Result res = FRAGENTChecklistAssetService.getById(recordId);
            System.assert(res.success, 'getById should succeed for CRU user');
            System.assertEquals(1, res.records.size());
            Checklist_Asset__c fetched = (Checklist_Asset__c)res.records[0];
            System.assertNotEquals(null, fetched.Checklist__r.Name, 'Checklist name should be returned');
            System.assertNotEquals(null, fetched.Asset__r.Name, 'Asset name should be returned');
        }
    }
}