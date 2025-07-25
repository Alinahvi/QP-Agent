@isTest
private class FRAGENTAudienceMemberService_Test {

    @testSetup
    static void setupData() {
        User uCrud = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCrud, FRAGENTGeneralService.PERM_LABEL_CRUD, 'crud');
        
        User uCru = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCru, FRAGENTGeneralService.PERM_LABEL_CRU, 'cru');

        System.runAs(uCrud) {
            FRAGENTTestDataFactory.createAudiences(1, true);
        }
        FRAGENTTestDataFactory.createLearnerProfiles(1, true);
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
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Learner_Profile__c learner = [SELECT Id, User__c FROM Learner_Profile__c LIMIT 1];
            FRAGENTTestDataFactory.createPermissionSet('ACT Learner');
            FRAGENTTestDataFactory.assignPermissionSet(new User(Id = learner.User__c), 'ACT Learner');
            List<Audience_Member__c> inputs = new List<Audience_Member__c>{
                new Audience_Member__c(Audience__c = aud.Id, Learner_Profile__c = learner.Id)
            };
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTAudienceMemberService.create(inputs);
            Test.stopTest();

            System.assert(res.success, 'Expected success on valid input');
            System.assertEquals(1, res.records.size(), 'Exactly one record should be created');
            Audience_Member__c created = [SELECT Manually_Added__c FROM Audience_Member__c WHERE Id = :res.records[0].Id];
            System.assertEquals(true, created.Manually_Added__c, 'Record should be marked as Manually Added');
        }
    }
    
    @isTest
    static void testCreate_NoCrud_Fails() {
        System.runAs(getUser('cru')) {
            List<Audience_Member__c> inputs = new List<Audience_Member__c>{
                new Audience_Member__c()
            };
            
            FRAGENTGeneralService.Result res = FRAGENTAudienceMemberService.create(inputs);

            System.assert(!res.success, 'CRU user should not be able to create');
            System.assert(res.errors[0].contains('Insufficient permissions'));
        }
    }

    @isTest
    static void testCreate_InvalidData_FailsGracefully() {
        System.runAs(getUser('crud')) {
            List<Audience_Member__c> inputs = new List<Audience_Member__c>{
                new Audience_Member__c() // Missing required fields
            };
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTAudienceMemberService.create(inputs);
            Test.stopTest();
            
            System.assert(!res.success, 'Should report failure on DML errors');
            System.assert(res.errors.size() > 0, 'Errors should be captured');
        }
    }

    @isTest
    static void testCreate_Fails_WhenAssignmentsExist() {
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Asset__c asset = FRAGENTTestDataFactory.createAssets(1, true)[0];
            insert new Assigned_Learning__c(Audience__c = aud.Id, Asset__c = asset.Id);

            Learner_Profile__c learner = [SELECT Id, User__c FROM Learner_Profile__c LIMIT 1];
            FRAGENTTestDataFactory.createPermissionSet('ACT Learner');
            FRAGENTTestDataFactory.assignPermissionSet(new User(Id = learner.User__c), 'ACT Learner');
            List<Audience_Member__c> inputs = new List<Audience_Member__c>{
                new Audience_Member__c(Audience__c = aud.Id, Learner_Profile__c = learner.Id)
            };

            FRAGENTGeneralService.Result res = FRAGENTAudienceMemberService.create(inputs);

            System.assert(!res.success, 'Create should fail when assignments exist');
            System.assert(res.errors[0].contains('assigned learning'));
        }
    }

    @isTest
    static void testCreate_Fails_WhenLearnerMissingPermission() {
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Learner_Profile__c learner = [SELECT Id FROM Learner_Profile__c LIMIT 1];
            FRAGENTTestDataFactory.createPermissionSet('ACT Learner');
            // Intentionally do NOT assign the permission to learner's user
            List<Audience_Member__c> inputs = new List<Audience_Member__c>{
                new Audience_Member__c(Audience__c = aud.Id, Learner_Profile__c = learner.Id)
            };

            FRAGENTGeneralService.Result res = FRAGENTAudienceMemberService.create(inputs);

            System.assert(!res.success, 'Create should fail when learner lacks permission');
            System.assert(res.errors[0].contains('ACT Learner'));
        }
    }
    
    // =================================================================================
    // REMOVE Method Tests
    // =================================================================================
    @isTest
    static void testRemove_Succeeds() {
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Learner_Profile__c learner = [SELECT Id FROM Learner_Profile__c LIMIT 1];
            Audience_Member__c rec = new Audience_Member__c(Audience__c = aud.Id, Learner_Profile__c = learner.Id);
            insert rec;
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTAudienceMemberService.remove(new List<Id>{rec.Id});
            Test.stopTest();
            
            System.assert(res.success, 'Remove should succeed');
            System.assertEquals(0, [SELECT count() FROM Audience_Member__c WHERE Id = :rec.Id]);
        }
    }
    
    @isTest
    static void testRemove_NoCrud_Fails() {
        System.runAs(getUser('cru')) {
            Id fakeId = FRAGENTTestDataFactory.generateFakeId(Audience_Member__c.SObjectType);

            FRAGENTGeneralService.Result res = FRAGENTAudienceMemberService.remove(new List<Id>{fakeId});

            System.assert(!res.success);
            System.assert(res.errors[0].contains('Insufficient permissions'));
        }
    }

    @isTest
    static void testRemove_Fails_WhenAssignmentsExist() {
        System.runAs(getUser('crud')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            Asset__c asset = FRAGENTTestDataFactory.createAssets(1, true)[0];
            Assigned_Learning__c assignRec = new Assigned_Learning__c(Audience__c = aud.Id, Asset__c = asset.Id);
            insert assignRec;

            Learner_Profile__c learner = [SELECT Id FROM Learner_Profile__c LIMIT 1];
            Audience_Member__c member = new Audience_Member__c(Audience__c = aud.Id, Learner_Profile__c = learner.Id);
            insert member;

            FRAGENTGeneralService.Result res = FRAGENTAudienceMemberService.remove(new List<Id>{member.Id});

            System.assert(!res.success, 'Remove should fail when assignments exist');
            System.assert(res.errors[0].contains('assigned learning'));
            System.assertEquals(1, [SELECT count() FROM Audience_Member__c WHERE Id = :member.Id]);
        }
    }
    
    // =================================================================================
    // SEARCH Method Tests
    // =================================================================================
    @isTest
    static void testSearch_Succeeds() {
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
            FRAGENTTestDataFactory.createAudienceMembers(aud, learners, true);
        }

        System.runAs(getUser('cru')) {
            Audience__c aud = [SELECT Id FROM Audience__c LIMIT 1];
            FRAGENTAudienceMemberService.SearchResult res = FRAGENTAudienceMemberService.search(aud.Id, null, null, null, null, null, null, 10, 0);

            System.assert(res.success, 'Search should succeed for CRU user');
            System.assertEquals(2, res.records.size());
            System.assertEquals(2, res.totalCount);
            System.assertEquals(1, res.divisionCounts.get('AMER'));
            System.assertEquals(1, res.divisionCounts.get('EMEA'));
            System.assertEquals(1, res.aeTypeCounts.get('Core'));
            System.assertEquals(1, res.aeTypeCounts.get('Digital'));
            System.assertEquals(1, res.roleLevel4Counts.get('Prime AE'));
            System.assertEquals(1, res.roleLevel4Counts.get('Exec Admin'));
            System.assertNotEquals(null, ((Audience_Member__c)res.records[0]).Learner_Profile__r.Name, 'Learner name should be returned');
        }
    }
}