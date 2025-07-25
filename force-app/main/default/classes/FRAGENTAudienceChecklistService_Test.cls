@isTest
private class FRAGENTAudienceChecklistService_Test {

    @testSetup
    static void setupData() {
        User uCrud = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCrud, FRAGENTGeneralService.PERM_LABEL_CRUD, 'crud');
        
        User uCru = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCru, FRAGENTGeneralService.PERM_LABEL_CRU, 'cru');

        System.runAs(uCrud) {
            FRAGENTTestDataFactory.createAudiences(1, true);
            FRAGENTTestDataFactory.createChecklists(1, true);
        }
    }

    private static User getUser(String alias) {
        return [SELECT Id FROM User WHERE Alias = :alias ORDER BY CreatedDate DESC LIMIT 1];
    }
    
    // =================================================================================
    // ASSIGN (CREATE) Method Tests
    // =================================================================================
    @isTest
    static void testCreate_Succeeds() {
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            List<Audience_Checklist__c> inputs = new List<Audience_Checklist__c>{
                new Audience_Checklist__c(Audience__c = aud.Id, Checklist__c = chk.Id)
            };
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTAudienceChecklistService.create(inputs);
            Test.stopTest();

            System.assert(res.success, 'Expected success on valid input');
            System.assertEquals(1, res.records.size(), 'Exactly one record should be created');
            Audience_Checklist__c created = (Audience_Checklist__c)res.records[0];
            System.assertNotEquals(null, created.Audience__r.Name, 'Audience name should be returned');
            System.assertNotEquals(null, created.Checklist__r.Name, 'Checklist name should be returned');
        }
    }
    
    @isTest
    static void testCreate_NoCrud_Fails() {
        System.runAs(getUser('cru')) {
            List<Audience_Checklist__c> inputs = new List<Audience_Checklist__c>{
                new Audience_Checklist__c()
            };
            
            FRAGENTGeneralService.Result res = FRAGENTAudienceChecklistService.create(inputs);

            System.assert(!res.success, 'CRU user should not be able to assign');
            System.assert(res.errors[0].contains('Insufficient permissions'));
        }
    }
    
    // =================================================================================
    // REMOVE Method Tests
    // =================================================================================
    @isTest
    static void testRemove_Succeeds() {
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Audience_Checklist__c rec = new Audience_Checklist__c(Audience__c = aud.Id, Checklist__c = chk.Id);
            insert rec;
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTAudienceChecklistService.remove(new List<Id>{rec.Id});
            Test.stopTest();
            
            System.assert(res.success, 'Remove should succeed');
            System.assertEquals(0, [SELECT count() FROM Audience_Checklist__c WHERE Id = :rec.Id]);
        }
    }
    
    // =================================================================================
    // SEARCH Method Tests
    // =================================================================================
    @isTest
    static void testSearch_Succeeds() {
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            insert new Audience_Checklist__c(Audience__c = aud.Id, Checklist__c = chk.Id);
        }

        System.runAs(getUser('cru')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            FRAGENTAudienceChecklistService.SearchResult res = FRAGENTAudienceChecklistService.search(aud.Id, null, null, null, null, null, null, 10, 0);
            
            System.assert(res.success, 'Search should succeed for CRU user');
            System.assertEquals(1, res.records.size());
            System.assertEquals(1, res.totalCount);
            Audience_Checklist__c result = (Audience_Checklist__c)res.records[0];
            System.assertNotEquals(null, result.Audience__r.Name, 'Audience name should be returned');
            System.assertNotEquals(null, result.Checklist__r.Name, 'Checklist name should be returned');
        }
    }
}