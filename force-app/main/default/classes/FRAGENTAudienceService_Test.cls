@isTest
private class FRAGENTAudienceService_Test {

    @testSetup
    static void setupData() {
        User uCrud = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCrud, FRAGENTGeneralService.PERM_LABEL_CRUD, 'crud');
        
        User uCru = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCru, FRAGENTGeneralService.PERM_LABEL_CRU, 'cru');

        System.runAs(uCrud) {
            FRAGENTTestDataFactory.createAudiences(1, true);
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
            List<Audience__c> inputs = new List<Audience__c>{
                new Audience__c(Name = 'New Test Audience')
            };
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTAudienceService.createAudiences(inputs);
            Test.stopTest();

            System.assert(res.success, 'Expected success on valid input');
            System.assertEquals(1, res.records.size(), 'Exactly one record should be created');

            Audience__c created = [SELECT RecordType.DeveloperName, RecordType.Name FROM Audience__c WHERE Id = :res.records[0].Id];
            System.assertEquals('Cohort', created.RecordType.DeveloperName, 'Record Type developer name should be Cohort');
            System.assertEquals('Manual', created.RecordType.Name, 'Record Type label should be Manual');
        }
    }
    
    @isTest
    static void testCreate_NoCrud_Fails() {
        System.runAs(getUser('cru')) {
            List<Audience__c> inputs = new List<Audience__c>{
                new Audience__c(Name = 'This should not be created')
            };
            
            FRAGENTGeneralService.Result res = FRAGENTAudienceService.createAudiences(inputs);

            System.assert(!res.success, 'CRU user should not be able to create');
            System.assert(res.errors[0].contains('Insufficient permissions'));
        }
    }

    @isTest
    static void testCreate_InvalidData_FailsGracefully() {
        System.runAs(getUser('crud')) {
            List<Audience__c> inputs = new List<Audience__c>{
                new Audience__c() // No name, should fail validation
            };
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTAudienceService.createAudiences(inputs);
            Test.stopTest();
            
            System.assert(!res.success, 'Should report failure on DML errors');
            System.assert(res.errors.size() > 0, 'Errors should be captured');
        }
    }
    
    // =================================================================================
    // REMOVE Method Tests
    // =================================================================================
    @isTest
    static void testRemove_Succeeds() {
        System.runAs(getUser('crud')) {
            Audience__c rec = [SELECT Id FROM Audience__c LIMIT 1];
            
            Test.startTest();
            FRAGENTGeneralService.Result res = FRAGENTAudienceService.deleteAudiences(new List<Id>{rec.Id});
            Test.stopTest();
            
            System.assert(res.success, 'Remove should succeed');
            System.assertEquals(0, [SELECT count() FROM Audience__c WHERE Id = :rec.Id]);
        }
    }
    
    @isTest
    static void testRemove_NoCrud_Fails() {
        System.runAs(getUser('cru')) {
            Audience__c rec = [SELECT Id FROM Audience__c LIMIT 1];
            
            FRAGENTGeneralService.Result res = FRAGENTAudienceService.deleteAudiences(new List<Id>{rec.Id});

            System.assert(!res.success);
            System.assert(res.errors[0].contains('Insufficient permissions'));
        }
    }
    
    // =================================================================================
    // SEARCH and GET Method Tests
    // =================================================================================
    @isTest
    static void testSearch_Succeeds() {
        Audience__c existingAud;
        Audience__c secondAud;
        System.runAs(getUser('crud')) {
            existingAud = [SELECT Id FROM Audience__c LIMIT 1];
            secondAud = FRAGENTTestDataFactory.createAudiences(1, true)[0];
        }
        List<Learner_Profile__c> learners = FRAGENTTestDataFactory.createLearnerProfiles(3, true);
        learners[0].Division__c = 'AMER';
        learners[0].AE_Type__c = 'Core';
        learners[0].Role_Level_4__c = 'Prime AE';
        learners[1].Division__c = 'AMER';
        learners[1].AE_Type__c = 'Core';
        learners[1].Role_Level_4__c = 'Prime AE';
        learners[2].Division__c = 'EMEA';
        learners[2].AE_Type__c = 'Digital';
        learners[2].Role_Level_4__c = 'Exec Admin';
        update learners;
        FRAGENTTestDataFactory.createAudienceMembers(secondAud, learners, true);

        System.runAs(getUser('cru')) {
            FRAGENTAudienceService.SearchResult res = FRAGENTAudienceService.search('Test', null, null, null, null, 10, 0);
            System.assert(res.success, 'Search should succeed for CRU user');
            System.assertEquals(2, res.records.size());
            System.assertEquals(0, res.memberCounts.get(existingAud.Id), 'Existing audience should have zero members');
            System.assertEquals(3, res.memberCounts.get(secondAud.Id), 'Second audience should reflect created members');
            System.assertEquals(2, res.divisionCounts.get(secondAud.Id).get('AMER'));
            System.assertEquals(1, res.divisionCounts.get(secondAud.Id).get('EMEA'));
            System.assertEquals(2, res.aeTypeCounts.get(secondAud.Id).get('Core'));
            System.assertEquals(1, res.aeTypeCounts.get(secondAud.Id).get('Digital'));
            System.assertEquals(2, res.roleLevel4Counts.get(secondAud.Id).get('Prime AE'));
            System.assertEquals(1, res.roleLevel4Counts.get(secondAud.Id).get('Exec Admin'));
        }
    }

    @isTest
    static void testGetById_Succeeds() {
        Audience__c aud;
        System.runAs(getUser('crud')) {
            aud = [SELECT Id FROM Audience__c LIMIT 1];
        }
        List<Learner_Profile__c> learners = FRAGENTTestDataFactory.createLearnerProfiles(2, true);
        learners[0].Division__c = 'AMER';
        learners[0].AE_Type__c = 'Core';
        learners[0].Role_Level_4__c = 'Prime AE';
        learners[1].Division__c = 'EMEA';
        learners[1].AE_Type__c = 'Core';
        learners[1].Role_Level_4__c = 'Exec Admin';
        update learners;

        FRAGENTTestDataFactory.createAudienceMembers(aud, learners, true);

        System.runAs(getUser('cru')) {
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.getAudienceById(aud.Id);
            System.assert(res.success, 'getAudienceById should succeed for CRU user');
            System.assertEquals(1, res.records.size());
            System.assertEquals(2, res.memberCount, 'Member count should reflect related audience members');
            System.assertEquals(1, res.divisionCounts.get('AMER'));
            System.assertEquals(1, res.divisionCounts.get('EMEA'));
            System.assertEquals(2, res.aeTypeCounts.get('Core'));
            System.assertEquals(1, res.roleLevel4Counts.get('Prime AE'));
            System.assertEquals(1, res.roleLevel4Counts.get('Exec Admin'));
        }
    }
}