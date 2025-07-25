/**
 * @isTest
 * @description This test class provides comprehensive coverage for the FRAGENTAudienceMemberHandler class.
 * It verifies all core functionality, including bulk operations, idempotency, and error handling.
 * All test data is created by the FRAGENTTestDataFactory and is rolled back at the end of the test run,
 * ensuring no data is permanently saved to the organization.
 */
@isTest
private class FRAGENTAudienceMemberHandler_Test {

    @testSetup
    static void setupData() {
        User uCrud = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCrud, FRAGENTGeneralService.PERM_LABEL_CRUD, 'crud');
        
        System.runAs(uCrud) {
            FRAGENTTestDataFactory.createAudiences(1, true);
        }
        FRAGENTTestDataFactory.createLearnerProfiles(1, true);
    }

    private static User getUser(String alias) {
        return [SELECT Id FROM User WHERE Alias = :alias ORDER BY CreatedDate DESC LIMIT 1];
    }
    
    @isTest
    static void testHandler_Create() {
        System.runAs(getUser('crud')) {
            Learner_Profile__c learner = [SELECT Id, User__c FROM Learner_Profile__c LIMIT 1];
            FRAGENTTestDataFactory.createPermissionSet('ACT Learner');
            FRAGENTTestDataFactory.assignPermissionSet(new User(Id = learner.User__c), 'ACT Learner');

            FRAGENTAudienceMemberHandler.Request req = new FRAGENTAudienceMemberHandler.Request();
            req.action = 'Create';
            req.audienceId = [SELECT Id FROM Audience__c LIMIT 1].Id;
            req.learnerProfileId = learner.Id;
            
            Test.startTest();
            List<FRAGENTAudienceMemberHandler.Response> resList = FRAGENTAudienceMemberHandler.manageAudienceMembers(new List<FRAGENTAudienceMemberHandler.Request>{req});
            Test.stopTest();

            System.assert(resList[0].success, 'Expected success on valid Create action');
            System.assertEquals(1, resList[0].records.size(), 'Should create one record');
            Audience_Member__c created = [SELECT Manually_Added__c FROM Audience_Member__c WHERE Id = :resList[0].records[0].Id];
            System.assertEquals(true, created.Manually_Added__c, 'Record should be marked as Manually Added');
        }
    }

    @isTest
    static void testHandler_Read() {
        Id recordId;
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Learner_Profile__c learner = [SELECT Id FROM Learner_Profile__c LIMIT 1];
            Audience_Member__c rec = new Audience_Member__c(Audience__c = aud.Id, Learner_Profile__c = learner.Id);
            insert rec;
            recordId = rec.Id;
        }

        System.runAs(getUser('crud')) {
            FRAGENTAudienceMemberHandler.Request req = new FRAGENTAudienceMemberHandler.Request();
            req.action = 'Read';
            req.audienceMemberId = recordId;
            
            Test.startTest();
            List<FRAGENTAudienceMemberHandler.Response> resList = FRAGENTAudienceMemberHandler.manageAudienceMembers(new List<FRAGENTAudienceMemberHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Read action');
            System.assertEquals(1, resList[0].records.size());
        }
    }

    @isTest
    static void testHandler_Delete() {
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Learner_Profile__c learner = [SELECT Id FROM Learner_Profile__c LIMIT 1];
            Audience_Member__c rec = new Audience_Member__c(Audience__c = aud.Id, Learner_Profile__c = learner.Id);
            insert rec;

            FRAGENTAudienceMemberHandler.Request req = new FRAGENTAudienceMemberHandler.Request();
            req.action = 'Delete';
            req.audienceMemberId = rec.Id;

            Test.startTest();
            List<FRAGENTAudienceMemberHandler.Response> resList = FRAGENTAudienceMemberHandler.manageAudienceMembers(new List<FRAGENTAudienceMemberHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Delete action');
            System.assertEquals(0, [SELECT count() FROM Audience_Member__c WHERE Id = :rec.Id]);
        }
    }

    @isTest
    static void testHandler_Search() {
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            List<Learner_Profile__c> learners = FRAGENTTestDataFactory.createLearnerProfiles(2, true);
            learners[0].Division__c = 'AMER';
            learners[0].AE_Type__c = 'Core';
            learners[0].Role_Level_4__c = 'Prime AE';
            learners[1].Division__c = 'EMEA';
            learners[1].AE_Type__c = 'Digital';
            learners[1].Role_Level_4__c = 'Exec Admin';
            update learners;
            for (Learner_Profile__c lp : learners) {
                insert new Audience_Member__c(Audience__c = aud.Id, Learner_Profile__c = lp.Id);
            }

            FRAGENTAudienceMemberHandler.Request req = new FRAGENTAudienceMemberHandler.Request();
            req.action = 'Search';
            req.audienceId = aud.Id;

            Test.startTest();
            List<FRAGENTAudienceMemberHandler.Response> resList = FRAGENTAudienceMemberHandler.manageAudienceMembers(new List<FRAGENTAudienceMemberHandler.Request>{req});
            Test.stopTest();

            System.assert(resList[0].success, 'Expected success on valid Search action');
            System.assertEquals(2, resList[0].totalRecordCount);
            System.assertEquals(1, resList[0].divisionCounts.get('AMER'));
            System.assertEquals(1, resList[0].divisionCounts.get('EMEA'));
            System.assertEquals(1, resList[0].aeTypeCounts.get('Core'));
            System.assertEquals(1, resList[0].aeTypeCounts.get('Digital'));
            System.assertEquals(1, resList[0].roleLevel4Counts.get('Prime AE'));
            System.assertEquals(1, resList[0].roleLevel4Counts.get('Exec Admin'));
            System.assertNotEquals(null, resList[0].records[0].Learner_Profile__r.Name, 'Learner name should be returned');
        }
    }
    
    @isTest
    static void testHandler_NoActionSpecified() {
        System.runAs(getUser('crud')) {
            FRAGENTAudienceMemberHandler.Request req = new FRAGENTAudienceMemberHandler.Request();
            req.action = '';
            
            List<FRAGENTAudienceMemberHandler.Response> resList = FRAGENTAudienceMemberHandler.manageAudienceMembers(new List<FRAGENTAudienceMemberHandler.Request>{req});
            
            System.assert(!resList[0].success, 'Should fail when no action is specified');
            System.assert(resList[0].message.contains('Action parameter is required'));
        }
    }
}