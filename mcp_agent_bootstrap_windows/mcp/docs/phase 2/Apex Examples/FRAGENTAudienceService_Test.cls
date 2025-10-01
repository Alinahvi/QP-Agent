@isTest
private class FRAGENTAudienceService_Test {

    private static final String CRUD_LAST_NAME = 'FRAGENT_CRUD_USER';
    private static final String CRU_LAST_NAME = 'FRAGENT_CRU_USER';

    private static void seedActionPolicies() {
        AgentCore_Permissions.flushCache();
        AgentCore_Permissions.testSeedActionPolicy(AgentCore_ActionKeys.Audience.readKey(), new List<String>(), new List<String>(), null, null);
        AgentCore_Permissions.testSeedActionPolicy(AgentCore_ActionKeys.Audience.createKey(), new List<String>(), new List<String>(), null, null);
        AgentCore_Permissions.testSeedActionPolicy(AgentCore_ActionKeys.Audience.updateKey(), new List<String>(), new List<String>(), null, null);
        AgentCore_Permissions.testSeedActionPolicy(AgentCore_ActionKeys.Audience.deleteKey(), new List<String>(), new List<String>(), null, null);
    }

    private static User crudUser() {
        return [SELECT Id FROM User WHERE LastName = :CRUD_LAST_NAME ORDER BY CreatedDate DESC LIMIT 1];
    }

    private static User cruUser() {
        return [SELECT Id FROM User WHERE LastName = :CRU_LAST_NAME ORDER BY CreatedDate DESC LIMIT 1];
    }

    @testSetup
    static void setupData() {
        seedActionPolicies();
        User uCrud = AgentCore_TestFactory.Users.cohortCrud(null);
        uCrud.LastName = CRUD_LAST_NAME;
        update uCrud;

        User uCru = AgentCore_TestFactory.Users.cohortCru(null);
        uCru.LastName = CRU_LAST_NAME;
        update uCru;

        System.runAs(uCrud) {
            AgentCore_TestFactory.createAudiences(1, true);
        }
    }// =================================================================================
    // CREATE Method Tests
    // =================================================================================
    @isTest
    static void testCreate_Succeeds() {
        System.runAs(crudUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                List<Audience__c> inputs = new List<Audience__c>{
                    new Audience__c(Name = 'New Test Audience')
                };
                
                Test.startTest();
                AgentCore_Result res = FRAGENTAudienceService.createAudiences(inputs);
                Test.stopTest();

                System.assert(res.success, 'Expected success on valid input: ' + String.valueOf(res.message));
                System.assertEquals(1, res.records.size(), 'Exactly one record should be created');

                Audience__c created = [SELECT RecordType.DeveloperName, RecordType.Name FROM Audience__c WHERE Id = :res.records[0].Id];
                System.assertEquals('Cohort', created.RecordType.DeveloperName, 'Record Type developer name should be Cohort');
                System.assertEquals('Manual', created.RecordType.Name, 'Record Type label should be Manual');
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testCreate_Cru_Succeeds() {
        System.runAs(cruUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                List<Audience__c> inputs = new List<Audience__c>{
                    new Audience__c(Name = 'CRU Created Audience')
                };

                AgentCore_Result res = FRAGENTAudienceService.createAudiences(inputs);

                System.assert(res.success, 'CRU user should be able to create: ' + String.valueOf(res.message));
                System.assertEquals(1, res.records.size());
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testCreate_InvalidData_FailsGracefully() {
        System.runAs(crudUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                List<Audience__c> inputs = new List<Audience__c>{
                    new Audience__c() // No name, should fail validation
                };
                
                Test.startTest();
                AgentCore_Result res = FRAGENTAudienceService.createAudiences(inputs);
                Test.stopTest();
                
                System.assert(!res.success, 'Should report failure on DML errors');
                System.assert(res.errors.size() > 0, 'Errors should be captured');
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testCreate_DuplicateName_Fails() {
        System.runAs(crudUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                String audName = 'Duplicate Audience';
                AgentCore_Result firstRes = FRAGENTAudienceService.createAudiences(
                    new List<Audience__c>{ new Audience__c(Name = audName) }
                );
                System.assert(firstRes.success, 'Initial create should succeed');

                AgentCore_Result dupRes = FRAGENTAudienceService.createAudiences(
                    new List<Audience__c>{ new Audience__c(Name = audName) }
                );

                System.assert(!dupRes.success, 'Duplicate create should fail');
                System.assert(dupRes.errors[0].contains('duplicate name'),
                    'Error message should indicate duplicate name');
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }
    
    // =================================================================================
    // REMOVE Method Tests
    // =================================================================================
    @isTest
    static void testRemove_Succeeds() {
        System.runAs(crudUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Audience__c rec = [SELECT Id FROM Audience__c LIMIT 1];
                
                Test.startTest();
                AgentCore_Result res = FRAGENTAudienceService.deleteAudiences(new List<Id>{rec.Id});
                Test.stopTest();
                
                System.assert(res.success, 'Remove should succeed: ' + String.valueOf(res.message));
                System.assertEquals(0, [SELECT count() FROM Audience__c WHERE Id = :rec.Id]);
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    // =================================================================================
    // UPDATE Method Tests (Ticket: Audience Permission Testing)
    // =================================================================================
    @isTest
    static void testUpdate_Succeeds_WithU() {
        System.runAs(cruUser()) {
            Audience__c rec = AgentCore_TestFactory.createAudiences(1, true)[0];
            String newName = rec.Name + ' - Updated';
            rec.Name = newName;

            AgentCore_Result res = FRAGENTAudienceService.updateAudiences(new List<Audience__c>{ rec });
            System.assert(res.success, res.message);
            System.assertEquals(newName, [SELECT Name FROM Audience__c WHERE Id = :rec.Id].Name);
        }
    }

    @isTest
    static void testUpdate_Fails_NoU() {
        User retrieveOnly = AgentCore_TestFactory.Users.cohortRetrieve(null);
        System.runAs(retrieveOnly) {
            Audience__c rec = [SELECT Id, Name FROM Audience__c LIMIT 1];
            rec.Name = 'Should Not Update';
            AgentCore_Result res = FRAGENTAudienceService.updateAudiences(new List<Audience__c>{ rec });
            System.assertEquals(false, res.success, 'Update should be denied without U permission');
            System.assert(res.errors != null && !res.errors.isEmpty(), 'Expect error details');
            String msg = res.message != null ? res.message : (res.errors.isEmpty() ? '' : res.errors[0]);
            System.assert(msg.toLowerCase().contains('permission'));
        }
    }

    // =================================================================================
    // Action-Policy Gating (Retrieve) (Ticket: Audience Permission Testing)
    // =================================================================================
    @isTest
    static void testRequireAction_Retrieve_PolicyGate() {
        AgentCore_Permissions.flushCache();
        AgentCore_Permissions.testSeedPermissionNode('Cohort.RetrieveGate', null, 'CAN_RETRIEVE_AUDIENCE', 1);
        AgentCore_Permissions.testSeedActionPolicy(
            AgentCore_ActionKeys.Audience.readKey(),
            new List<String>{ 'Cohort.RetrieveGate' },
            new List<String>(),
            'Insufficient permissions', null
        );

        // Deny when custom permission is FALSE
        System.runAs(cruUser()) {
            AgentCore_Permissions.setTestPermission('CAN_RETRIEVE_AUDIENCE', false);
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(
                null, 'Test', null, null, null, null, null, 5
            );
            System.assertEquals(false, res.success);
        }

        // Allow when TRUE
        System.runAs(cruUser()) {
            AgentCore_Permissions.setTestPermission('CAN_RETRIEVE_AUDIENCE', true);
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(
                null, 'Test', null, null, null, null, null, 5
            );
            System.assertEquals(true, res.success, res.message);
        }
    }
    @isTest
    static void testRemove_NoCrud_Fails() {
        System.runAs(cruUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = false;
            Audience__c rec = [SELECT Id FROM Audience__c LIMIT 1];
            
            AgentCore_Result res;
            try {
                res = FRAGENTAudienceService.deleteAudiences(new List<Id>{rec.Id});
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }

            System.assert(!res.success);
            System.assert(res.errors[0].contains('Insufficient permissions'));
        }
    }
    
    // =================================================================================
    // SEARCH and GET Method Tests
    // =================================================================================
    @isTest
    static void testRetrieveSearch_Succeeds() {
        Audience__c existingAud;
        Audience__c secondAud;
        System.runAs(crudUser()) {
            existingAud = [SELECT Id, CreatedById, CreatedBy.Name, LastModifiedById, LastModifiedBy.Name FROM Audience__c LIMIT 1];
            secondAud = AgentCore_TestFactory.createAudiences(1, true)[0];
            secondAud = [SELECT Id, CreatedById, CreatedBy.Name, LastModifiedById, LastModifiedBy.Name FROM Audience__c WHERE Id = :secondAud.Id];
        }
        Map<Id, Audience__c> expectedAudMap = new Map<Id, Audience__c>{existingAud.Id => existingAud, secondAud.Id => secondAud};
        List<Learner_Profile__c> learners = AgentCore_TestFactory.createLearnerProfiles(3, true);
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
        AgentCore_TestFactory.createAudienceMembers(secondAud, learners, true);

        System.runAs(cruUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(null, 'Test', null, null, null, null, null, 10);
                System.assert(res.success, 'Retrieve should succeed for CRU user: ' + String.valueOf(res.message));
                System.assertEquals(2, res.records.size());
                for (Audience__c rec : (List<Audience__c>)res.records) {
                    Audience__c expected = expectedAudMap.get(rec.Id);
                    System.assertEquals(expected.CreatedById, rec.CreatedById);
                    System.assertEquals(expected.CreatedBy.Name, rec.CreatedBy.Name);
                    System.assertEquals(expected.LastModifiedById, rec.LastModifiedById);
                    System.assertEquals(expected.LastModifiedBy.Name, rec.LastModifiedBy.Name);
                }
                System.assertEquals(2, res.totalCount, 'Total count should reflect all matching audiences');
                System.assertEquals(2, res.audienceDetails.size());
                Boolean foundSecond = false;
                Boolean foundExisting = false;
                for (FRAGENTAudienceService.AudienceDetails ad : res.audienceDetails) {
                    if (ad.audienceId == existingAud.Id) {
                        System.assertEquals(0, ad.memberCount, 'Existing audience should have zero members');
                        foundExisting = true;
                    }
                    if (ad.audienceId == secondAud.Id) {
                        System.assertEquals(3, ad.memberCount, 'Second audience should reflect created members');
                        foundSecond = true;
                    }
                }
                System.assert(foundExisting, 'Existing audience should be present in audienceDetails');
                System.assert(foundSecond, 'Second audience should be present in audienceDetails');
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieveSearch_ReturnsMemberProfiles() {
        Audience__c aud;
        List<Learner_Profile__c> learners = AgentCore_TestFactory.createLearnerProfiles(2, true);
        System.runAs(crudUser()) {
            aud = AgentCore_TestFactory.createAudiences(1, true)[0];
            AgentCore_TestFactory.createAudienceMembers(aud, learners, true);
        }

        System.runAs(cruUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(
                    null, aud.Name, null, null, null, null, null, 5);
                System.assert(res.success, 'Retrieve should succeed: ' + String.valueOf(res.message));
                System.assertEquals(1, res.audienceDetails.size(), 'Should return the created audience');
                FRAGENTAudienceService.AudienceDetails details = res.audienceDetails[0];
                System.assertEquals(2, details.memberCount, 'Member count should reflect created members');
                System.assertEquals(2, details.members.size(), 'Members list should include summaries');

                Map<Id, Learner_Profile__c> learnerMap = new Map<Id, Learner_Profile__c>(learners);
                for (FRAGENTAudienceService.AudienceMemberSummary ms : details.members) {
                    Learner_Profile__c lp = learnerMap.get(ms.learnerProfileId);
                    System.assertNotEquals(null, lp, 'Learner profile should be present');
                    System.assertEquals(lp.Name, ms.learnerName, 'Learner name should match');
                    System.assertNotEquals(null, ms.createdDate, 'CreatedDate should be populated');
                    System.assertNotEquals(null, ms.lastModifiedDate, 'LastModifiedDate should be populated');
                }
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieveSearch_LimitMessage() {
        System.runAs(crudUser()) {
            AgentCore_TestFactory.createAudiences(12, true);
        }

        System.runAs(cruUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(null, 'Test', null, null, null, null, null, 10);
                System.assert(res.success, 'Retrieve should succeed when under the custom limit: ' + String.valueOf(res.message));
                System.assertEquals(10, res.records.size(), 'Should return only the first 10 records');
                System.assertEquals(13, res.totalCount, 'Total count should include all matching records');
                System.assertEquals('custom limit of 10 reached', res.message);
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieveSearch_DefaultLimit() {
        System.runAs(crudUser()) {
            AgentCore_TestFactory.createAudiences(60, true);
        }

        System.runAs(cruUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(null, 'Test', null, null, null, null, null, null);
                System.assert(res.success, 'Retrieve should succeed with default limit: ' + String.valueOf(res.message));
                System.assertEquals(50, res.records.size(), 'Should return only the first 50 records by default');
                System.assert(res.totalCount > 50, 'Total count should reflect all matching records');
                System.assertEquals('default limit of 50 reached', res.message);
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieveSearch_NoPermission_Fails() {
        User noPerm = AgentCore_TestFactory.createUsers(1, 'Standard User', true)[0];

        System.runAs(noPerm) {
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(
                null,
                'Test',
                null,
                null,
                null,
                null,
                null,
                5
            );
            System.assert(!res.success, 'User without audience permissions should fail retrieve');
            String message = res.message != null ? res.message : (res.errors != null && !res.errors.isEmpty() ? res.errors[0] : '');
            System.assert(message.contains('Insufficient permissions'), 'Message should mention missing permissions');
            System.assertEquals(true, res.permissionDenied, 'Should flag permissionDenied');
            System.assertEquals('PERMISSION_DENIED', res.code, 'Should set stable denial code');
        }
    }

    @isTest
    static void testRetrieveSearch_NameWithDate() {
        Audience__c aud;
        System.runAs(crudUser()) {
            aud = AgentCore_TestFactory.createAudiences(1, true)[0];
            aud.Name = 'Launch 01/01/2023';
            update aud;
        }

        System.runAs(cruUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(null, 'Launch 01/01/2023', null, null, null, null, null, 5);
                System.assert(res.success, 'Retrieve should succeed: ' + String.valueOf(res.message));
                System.assertEquals(1, res.records.size(), 'Should return the matching audience');
                System.assertEquals(aud.Id, res.records[0].Id, 'Returned record should match the created audience');
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieveSearch_FullNameWithDate_OnlyExactMatch() {
        Audience__c target;
        Audience__c other;
        System.runAs(crudUser()) {
            List<Audience__c> createdAudiences = AgentCore_TestFactory.createAudiencesByNames(
                new List<String>{ 'Demo Audience - 07/15/2025', 'Other Audience' },
                true
            );
            target = createdAudiences[0];
            other  = createdAudiences[1];
            DateTime created = DateTime.now().addDays(-1);
            Test.setCreatedDate(target.Id, created);
            Test.setCreatedDate(other.Id, created);
        }

        System.runAs(cruUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                FRAGENTAudienceService.AudienceResult res =
                    FRAGENTAudienceService.retrieveAudiences(
                        null,
                        'Demo Audience - 07/15/2025',
                        null, null, null, null, null, 5);
                Test.stopTest();
                System.assert(res.success, 'Retrieve should succeed: ' + String.valueOf(res.message));
                List<Audience__c> returned = (List<Audience__c>)res.records;
                System.assertEquals(1, returned.size(), 'Only the record with the full name should be returned');
                System.assertEquals(target.Id, returned[0].Id, 'Returned record should match the searched audience');
                System.assertNotEquals(other.Id, returned[0].Id, 'Audience with the same creation date but different name should not be returned');
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieve_FuzzyFallback() {
        Audience__c fuzzy;
        Audience__c other;
        System.runAs(crudUser()) {
            List<Audience__c> audiences = AgentCore_TestFactory.createAudiences(2, true);
            fuzzy = audiences[0];
            other = audiences[1];
            fuzzy.Name = 'Fuzzy Audience Example';
            other.Name = 'Completely Different';
            update audiences;
        }

        System.runAs(cruUser()) {
            Test.startTest();
            String searchName = AgentCore_TestFactory.generateTypoName('Fuzzy Audience Example');
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(null, searchName, null, null, null, null, null, 10);
            Test.stopTest();
            System.assert(res.success, 'Retrieve should succeed with fuzzy fallback: ' + String.valueOf(res.message));
            System.assertEquals(1, res.records.size(), 'Only closely matching audience should be returned');
            System.assertEquals(fuzzy.Id, res.records[0].Id);
        }
    }

    @isTest
    static void testRetrieve_SearchFullName_DirectMatch() {
        Audience__c aud;
        String special = AgentCore_TestFactory.generateSpecialCharName('Greg Manual test');
        System.runAs(crudUser()) {
            aud = AgentCore_TestFactory.createAudiences(1, true)[0];
            aud.Name = special;
            update aud;
        }

        System.runAs(cruUser()) {
            Test.startTest();
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(null, special, null, null, null, null, null, 10);
            Test.stopTest();
            System.assert(res.success, 'Retrieve should succeed with full name search: ' + String.valueOf(res.message));
            System.assertEquals(1, res.records.size(), 'Full name search should return one record');
            System.assertEquals(aud.Id, res.records[0].Id, 'Returned record should match the searched audience');
        }
    }

    @isTest
    static void testRetrieve_NameWithSlash() {
        Audience__c aud;
        String nameWithSlash = 'Special/Name';
        System.runAs(crudUser()) {
            aud = AgentCore_TestFactory.createAudiences(1, true)[0];
            aud.Name = nameWithSlash;
            update aud;
        }

        System.runAs(cruUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                FRAGENTAudienceService.AudienceResult res =
                    FRAGENTAudienceService.retrieveAudiences(null, nameWithSlash, null, null, null, null, null, 10);
                Test.stopTest();
                System.assert(res.success, 'Search should succeed for names containing special characters: ' + String.valueOf(res.message));
                System.assertEquals(1, res.records.size(), 'Exactly one record should be returned');
                System.assertEquals(aud.Id, res.records[0].Id, 'Returned record should match the inserted audience');
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieve_NameWithWildcards() {
        Audience__c aud;
        String specialName = 'Special %_Audience';
        System.runAs(crudUser()) {
            aud = AgentCore_TestFactory.createAudiencesByNames(new List<String>{ specialName }, true)[0];
        }

        System.runAs(cruUser()) {
            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                FRAGENTAudienceService.AudienceResult res =
                    FRAGENTAudienceService.retrieveAudiences(null, specialName, null, null, null, null, null, 10);
                Test.stopTest();
                System.assert(res.success, 'Search should handle names with wildcard characters: ' + String.valueOf(res.message));
                System.assertEquals(1, res.records.size(), 'Exactly one record should be returned');
                System.assertEquals(aud.Id, res.records[0].Id, 'Returned record should match the inserted audience');
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieve_FallbackWithWildcards() {
        Audience__c aud;
        String name = 'Spec%ial Audience';
        System.runAs(crudUser()) {
            aud = AgentCore_TestFactory.createAudiencesByNames(new List<String>{ name }, true)[0];
        }

        System.runAs(cruUser()) {
            String search = name + ' Extra';
            Test.startTest();
            FRAGENTAudienceService.AudienceResult res =
                FRAGENTAudienceService.retrieveAudiences(null, search, null, null, null, null, null, 10);
            Test.stopTest();
            System.assert(res.success, 'Token fallback search should handle wildcard characters: ' + String.valueOf(res.message));
            System.assertEquals(1, res.records.size(), 'Exactly one record should be returned');
            System.assertEquals(aud.Id, res.records[0].Id, 'Returned record should match the inserted audience');
        }
    }

    @isTest
    static void testRetrieve_FuzzyMultiTokenRanking() {
        Audience__c both;
        Audience__c gregOnly;
        Audience__c manualOnly;
        System.runAs(crudUser()) {
            List<Audience__c> audiences = AgentCore_TestFactory.createAudiences(3, true);
            both = audiences[0];
            gregOnly = audiences[1];
            manualOnly = audiences[2];
            both.Name = 'Greg\'s Manual test';
            gregOnly.Name = 'Greg example';
            manualOnly.Name = 'Manual sample';
            update audiences;
        }

        System.runAs(cruUser()) {
            Test.startTest();
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(null, 'Greg Manual Test', null, null, null, null, null, 10);
            Test.stopTest();
            System.assert(res.success, 'Retrieve should succeed with multiple fuzzy tokens: ' + String.valueOf(res.message));
            System.assertEquals(3, res.records.size(), 'All matching audiences should be returned');
            Audience__c first = (Audience__c)res.records[0];
            System.assertEquals(both.Id, first.Id, 'Record matching both tokens should rank first');
        }
    }

    @isTest
    static void testRetrieveSearch_FlsMissing_Fails() {
        AgentCore_Permissions.clearTestFls();
        AgentCore_Permissions.setTestFlsReadable('Audience__c', 'Name', false);

        System.runAs(cruUser()) {
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(
                null,
                'Test',
                null,
                null,
                null,
                null,
                null,
                5
            );
            System.assert(!res.success, 'Retrieve should fail when required field access is missing');
            String message = res.message != null ? res.message : (res.errors != null && !res.errors.isEmpty() ? res.errors[0] : '');
            System.assert(message.contains('Field not readable'), 'Error should mention field readability');
        }

        AgentCore_Permissions.clearTestFls();
    }

    @isTest
    static void testRetrieveSearch_MultiRowCountHandled() {
        System.runAs(crudUser()) {
            AgentCore_TestFactory.createAudiences(1, true);
        }
        System.runAs(cruUser()) {
            AgentCore_TestFactory.createAudiences(1, true);
        }

        System.runAs(cruUser()) {
            FRAGENTAudienceService.testCountQueryOverride = 'SELECT count(Id) cnt, CreatedById FROM Audience__c GROUP BY CreatedById';
            Test.startTest();
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(null, null, null, null, null, null, null, 10);
            Test.stopTest();
            FRAGENTAudienceService.testCountQueryOverride = null;

            System.assert(!res.success, 'Multi-row count should fail gracefully');
            System.assertEquals('Search query failed: multiple count rows returned', res.message);
        }
    }

    @isTest
    static void testRetrieveById_Succeeds() {
        AgentCore_TestFactory.AudienceGraph graph =
            AgentCore_TestFactory.createAudienceWithMembers(2, true);

        List<Learner_Profile__c> learners = graph.learners;
        learners[0].Division__c = 'AMER';
        learners[0].AE_Type__c = 'Core';
        learners[0].Role_Level_4__c = 'Prime AE';
        learners[1].Division__c = 'EMEA';
        learners[1].AE_Type__c = 'Core';
        learners[1].Role_Level_4__c = 'Exec Admin';
        update learners;

        System.runAs(cruUser()) {
            Audience__c aud = [SELECT Id, CreatedById, CreatedBy.Name, LastModifiedById, LastModifiedBy.Name FROM Audience__c WHERE Id = :graph.audience.Id];
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(aud.Id, null, null, null, null, null, null, null);
            System.assert(res.success, 'retrieveAudiences should succeed for CRU user: ' + String.valueOf(res.message));
            System.assertEquals(1, res.records.size());
            Audience__c rec = (Audience__c)res.records[0];
            System.assertEquals(aud.CreatedById, rec.CreatedById);
            System.assertEquals(aud.CreatedBy.Name, rec.CreatedBy.Name);
            System.assertEquals(aud.LastModifiedById, rec.LastModifiedById);
            System.assertEquals(aud.LastModifiedBy.Name, rec.LastModifiedBy.Name);
            System.assertEquals(1, res.audienceDetails.size(),
                'audienceDetails should contain the retrieved audience');
            System.assertEquals(aud.Id, res.audienceDetails[0].audienceId,
                'Retrieved audience should match audienceDetails entry');
            System.assertEquals(2, res.audienceDetails[0].memberCount,
                'audienceDetails should reflect related audience members');
            System.assertEquals(2, res.audienceDetails[0].members.size());
        }
    }

    @isTest
    static void testRetrieveSearch_FuzzyTokens() {
        Audience__c a1;
        Audience__c a2;
        Id audId;
        System.runAs(crudUser()) {
            List<Audience__c> audiences = AgentCore_TestFactory.createAudiences(2, true);
            a1 = audiences[0];
            a2 = audiences[1];
            a1.Name = 'Alpha Bravo';
            a2.Name = 'Alpha';
            update audiences;
            audId = a1.Id;
        }

        System.runAs(cruUser()) {
            FRAGENTAudienceService.AudienceResult res = FRAGENTAudienceService.retrieveAudiences(null, 'Alpha Bavo', null, null, null, null, null, 10);
            System.assert(res.success, 'Search should succeed: ' + String.valueOf(res.message));
            System.assert(res.records.size() > 0, 'At least one record should be returned');
            System.assertEquals(a1.Name, ((Audience__c)res.records[0]).Name, 'Record with most token matches should rank first');
        }
    }

    @isTest
    static void testRetrieveSearch_HighLoad_NoGovernorLimits() {
        System.runAs(crudUser()) {
            AgentCore_TestFactory.createAudiences(250, true);
        }

        System.runAs(cruUser()) {
            Test.startTest();
            FRAGENTAudienceService.AudienceResult res =
                FRAGENTAudienceService.retrieveAudiences(null, 'Tset Audinece', null, null, null, null, null, 100);
            Test.stopTest();

            System.assert(res.success, 'High-load search should succeed: ' + String.valueOf(res.message));
            System.assert(res.records.size() <= 100, 'Result set should respect record limit');
            System.assert(Limits.getQueries() < Limits.getLimitQueries(),
                'Search should not consume all query limits');
            System.assert(Limits.getCpuTime() < Limits.getLimitCpuTime(),
                'Search should not consume all CPU time');
        }
    }
}





