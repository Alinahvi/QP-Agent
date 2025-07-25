@isTest
private class FRAGENTAudienceChecklistHandler_Test {

    @testSetup
    static void setupData() {
        User uCrud = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCrud, FRAGENTGeneralService.PERM_LABEL_CRUD, 'crud');
        
        System.runAs(uCrud) {
            FRAGENTTestDataFactory.createAudiences(1, true);
            FRAGENTTestDataFactory.createChecklists(1, true);
        }
    }

    private static User getUser(String alias) {
        return [SELECT Id FROM User WHERE Alias = :alias ORDER BY CreatedDate DESC LIMIT 1];
    }
    
    @isTest
    static void testHandler_Create() {
        System.runAs(getUser('crud')) {
            FRAGENTAudienceChecklistHandler.Request req = new FRAGENTAudienceChecklistHandler.Request();
            req.action = 'Create';
            req.checklistId = [SELECT Id FROM Checklist__c LIMIT 1].Id;
            req.audienceId = [SELECT Id FROM Audience__c LIMIT 1].Id;
            
            Test.startTest();
            List<FRAGENTAudienceChecklistHandler.Response> resList = FRAGENTAudienceChecklistHandler.manageAudienceChecklists(new List<FRAGENTAudienceChecklistHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Create action');
            System.assertEquals(1, resList[0].records.size(), 'Should create one record');
        }
    }

    @isTest
    static void testHandler_Read() {
        Id recordId;
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Audience_Checklist__c rec = new Audience_Checklist__c(Audience__c = aud.Id, Checklist__c = chk.Id);
            insert rec;
            recordId = rec.Id;
        }

        System.runAs(getUser('crud')) {
            FRAGENTAudienceChecklistHandler.Request req = new FRAGENTAudienceChecklistHandler.Request();
            req.action = 'Read';
            req.audienceChecklistId = recordId;
            
            Test.startTest();
            List<FRAGENTAudienceChecklistHandler.Response> resList = FRAGENTAudienceChecklistHandler.manageAudienceChecklists(new List<FRAGENTAudienceChecklistHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Read action');
            System.assertEquals(1, resList[0].records.size());
        }
    }

    @isTest
    static void testHandler_Delete() {
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            Audience_Checklist__c rec = new Audience_Checklist__c(Audience__c = aud.Id, Checklist__c = chk.Id);
            insert rec;

            FRAGENTAudienceChecklistHandler.Request req = new FRAGENTAudienceChecklistHandler.Request();
            req.action = 'Delete';
            req.audienceChecklistId = rec.Id;

            Test.startTest();
            List<FRAGENTAudienceChecklistHandler.Response> resList = FRAGENTAudienceChecklistHandler.manageAudienceChecklists(new List<FRAGENTAudienceChecklistHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Delete action');
            System.assertEquals(0, [SELECT count() FROM Audience_Checklist__c WHERE Id = :rec.Id]);
        }
    }

    @isTest
    static void testHandler_Search() {
         System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Checklist__c chk = [SELECT Id FROM Checklist__c LIMIT 1];
            insert new Audience_Checklist__c(Audience__c = aud.Id, Checklist__c = chk.Id);

            FRAGENTAudienceChecklistHandler.Request req = new FRAGENTAudienceChecklistHandler.Request();
            req.action = 'Search';
            req.audienceId = aud.Id;

            Test.startTest();
            List<FRAGENTAudienceChecklistHandler.Response> resList = FRAGENTAudienceChecklistHandler.manageAudienceChecklists(new List<FRAGENTAudienceChecklistHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Search action');
            System.assertEquals(1, resList[0].totalRecordCount);
        }
    }
    
    @isTest
    static void testHandler_NoActionSpecified() {
        System.runAs(getUser('crud')) {
            FRAGENTAudienceChecklistHandler.Request req = new FRAGENTAudienceChecklistHandler.Request();
            req.action = '';
            
            List<FRAGENTAudienceChecklistHandler.Response> resList = FRAGENTAudienceChecklistHandler.manageAudienceChecklists(new List<FRAGENTAudienceChecklistHandler.Request>{req});
            
            System.assert(!resList[0].success, 'Should fail when no action is specified');
            System.assert(resList[0].message.contains('Action parameter is required'));
        }
    }
}