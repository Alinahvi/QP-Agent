/**
 * @isTest
 * @description This test class provides comprehensive coverage for the FRAGENTAudienceHandler class.
 * It verifies all core functionality for creating, finding, and inactivating Audience records.
 */
@isTest
private class FRAGENTAudienceHandler_Test {

    @testSetup
    static void setupData() {
        User uCrud = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCrud, FRAGENTGeneralService.PERM_LABEL_CRUD, 'crud');
        
        System.runAs(uCrud) {
            FRAGENTTestDataFactory.createAudiences(1, true);
        }
    }

    private static User getUser(String alias) {
        return [SELECT Id FROM User WHERE Alias = :alias ORDER BY CreatedDate DESC LIMIT 1];
    }
    
    @isTest
    static void testHandler_Create() {
        System.runAs(getUser('crud')) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Create';
            req.audienceName = 'New Test Audience';
            
            Test.startTest();
            List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Create action');
            System.assertEquals(1, resList[0].audienceRecords.size(), 'Should create one record');
        }
    }

    @isTest
    static void testHandler_Delete() {
        System.runAs(getUser('crud')) {
            Audience__c rec = [SELECT Id FROM Audience__c LIMIT 1];
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Delete';
            req.audienceId = rec.Id;

            Test.startTest();
            List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Delete action');
            System.assertEquals(0, [SELECT count() FROM Audience__c WHERE Id = :rec.Id]);
        }
    }

    @isTest
    static void testHandler_Search() {
         System.runAs(getUser('crud')) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Search';
            req.searchTerm = 'Test';

            Test.startTest();
            List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
            Test.stopTest();

            System.assert(resList[0].success, 'Expected success on valid Search action');
            System.assertEquals(1, resList[0].totalRecordCount);
            Id audId = resList[0].audienceRecords[0].Id;
            System.assertEquals(0, resList[0].memberCounts.get(audId));
            System.assertEquals(0, resList[0].divisionCountsByAudience.get(audId).size());
        }
    }
    
    @isTest
    static void testHandler_NoActionSpecified() {
        System.runAs(getUser('crud')) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = '';
            
            List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
            
            System.assert(!resList[0].success, 'Should fail when no action is specified');
            System.assert(resList[0].message.contains('Action parameter is required'));
        }
    }

    @isTest
    static void testHandler_InvalidAction() {
        System.runAs(getUser('crud')) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'InvalidAction';
            
            List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
            
            System.assert(!resList[0].success, 'Should fail for an invalid action');
            System.assert(resList[0].message.contains('Invalid action'));
        }
    }
}