@isTest
private class FRAGENTChecklistService_Test {

    @testSetup
    static void setupData() {
        User uCrud = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCrud, FRAGENTGeneralService.PERM_LABEL_CRUD, 'crud');
        
        User uCru = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCru, FRAGENTGeneralService.PERM_LABEL_CRU, 'cru');

        System.runAs(uCrud) {
            FRAGENTTestDataFactory.createChecklists(1, true);
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
            List<Checklist__c> inputs = new List<Checklist__c>{
                new Checklist__c(Name = 'New Test Checklist')
            };
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTChecklistService.create(inputs);
            Test.stopTest();
            
            System.assert(res.success, 'Expected success on valid input');
            System.assertEquals(1, res.records.size(), 'Exactly one record should be created');
        }
    }
    
    // =================================================================================
    // REMOVE Method Tests
    // =================================================================================
    @isTest
    static void testRemove_Succeeds() {
        System.runAs(getUser('crud')) {
            List<Checklist__c> recs = [SELECT Id FROM Checklist__c WHERE Name = 'New Test Checklist For Deletion' LIMIT 1];
            Checklist__c rec;
            if (recs.isEmpty()) {
                rec = new Checklist__c(Name = 'New Test Checklist For Deletion');
                insert rec;
            } else {
                rec = recs[0];
            }
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTChecklistService.remove(new List<Id>{rec.Id});
            Test.stopTest();
            
            System.assert(res.success, 'Remove should succeed');
            System.assertEquals(0, [SELECT count() FROM Checklist__c WHERE Id = :rec.Id]);
        }
    }
    
    @isTest
    static void testRemove_NoCrud_Fails() {
        System.runAs(getUser('cru')) {
            Id fakeId = FRAGENTTestDataFactory.generateFakeId(Checklist__c.SObjectType);
            
            FRAGENTGeneralService.Result res = FRAGENTChecklistService.remove(new List<Id>{fakeId});

            System.assert(!res.success);
            System.assert(res.errors[0].contains('Insufficient permissions'));
        }
    }
    
    // =================================================================================
    // UPDATE Method Tests
    // =================================================================================
    @isTest
    static void testUpdate_Succeeds() {
        Id recordId;
        System.runAs(getUser('crud')) {
            recordId = [SELECT Id FROM Checklist__c LIMIT 1].Id;
        }

        System.runAs(getUser('crud')) {
            Checklist__c toUpdate = new Checklist__c(Id = recordId, Name = 'Updated Name');
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTChecklistService.updateRecords(new List<Checklist__c>{toUpdate});
            Test.stopTest();
            System.assert(res.success, 'Update should succeed for CRUD user');
            System.assertEquals('Updated Name', ((Checklist__c)res.records[0]).Name);
        }
    }

    // =================================================================================
    // SEARCH and GET Method Tests
    // =================================================================================
    @isTest
    static void testSearch_Succeeds() {
        System.runAs(getUser('cru')) {
            FRAGENTChecklistService.SearchResult res = FRAGENTChecklistService.search('Test', 'CreatedDate', 'TODAY', null, null, 10, 0);
            System.assert(res.success, 'Search should succeed for CRU user');
            System.assertEquals(1, res.records.size());
            System.assertEquals(1, res.totalCount);
        }
    }

    @isTest
    static void testGetById_Succeeds() {
        System.runAs(getUser('cru')) {
            Id recordId = [SELECT Id FROM Checklist__c LIMIT 1].Id;
            FRAGENTGeneralService.Result res = FRAGENTChecklistService.getById(recordId);
            System.assert(res.success, 'getById should succeed for CRU user');
            System.assertEquals(1, res.records.size());
        }
    }
}