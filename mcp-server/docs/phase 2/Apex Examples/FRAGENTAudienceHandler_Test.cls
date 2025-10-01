/**
 * @isTest
 * @description Template test class for handler classes.
 * Organizes tests by CRUD action with positive and negative scenarios and covers
 * edge conditions and error paths. Future handler tests should follow this
 * structure.
 */
@isTest
private class FRAGENTAudienceHandler_Test {

    private static final String CRUD_LAST_NAME = 'FRAGENT_AUDIENCE_HANDLER_USER';

    private static void seedActionPolicies() {
        AgentCore_Permissions.flushCache();
        AgentCore_Permissions.testSeedActionPolicy(AgentCore_ActionKeys.Audience.readKey(), new List<String>(), new List<String>(), null, null);
        AgentCore_Permissions.testSeedActionPolicy(AgentCore_ActionKeys.Audience.createKey(), new List<String>(), new List<String>(), null, null);
        AgentCore_Permissions.testSeedActionPolicy(AgentCore_ActionKeys.Audience.updateKey(), new List<String>(), new List<String>(), null, null);
        AgentCore_Permissions.testSeedActionPolicy(AgentCore_ActionKeys.Audience.deleteKey(), new List<String>(), new List<String>(), null, null);
    }

    @testSetup
    static void setupData() {
        seedActionPolicies();
        User uCrud = AgentCore_TestFactory.Users.cohortCrud(null);
        uCrud.LastName = CRUD_LAST_NAME;
        update uCrud;

        System.runAs(uCrud) {
            List<Audience__c> audiences = AgentCore_TestFactory.createAudiences(3, true);
            Audience__c hyphen = audiences[1];
            Audience__c special = audiences[2];
            hyphen.Name = 'Hyphen-Audience';
            special.Name = 'Audience 100%';
            update new List<Audience__c>{hyphen, special};
        }
    }

    private static User crudUser() {
        return [SELECT Id FROM User WHERE LastName = :CRUD_LAST_NAME ORDER BY CreatedDate DESC LIMIT 1];
    }

    // =================================================================================
    // CREATE Action Tests
    // =================================================================================
    @isTest
    static void testCreate_Succeeds() {
        System.runAs(crudUser()) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Create';
            req.audienceName = 'New Test Audience';

            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
                Test.stopTest();

                System.assert(resList[0].success, 'Expected success on valid Create action');
                System.assertEquals(1, resList[0].audienceDetails.records.size(), 'Should create one record');
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testCreate_MissingName_Fails() {
        System.runAs(crudUser()) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Create';
            req.audienceName = '';

            Test.startTest();
            List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
            Test.stopTest();

            System.assert(!resList[0].success, 'Create should fail when name is missing');
        }
    }

    // =================================================================================
    // UPDATE Action Tests
    // =================================================================================
    @isTest
    static void testUpdate_Succeeds() {
        System.runAs(crudUser()) {
            Audience__c rec = AgentCore_TestFactory.createAudiences(1, true)[0];
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Update';
            req.audienceId = rec.Id;
            req.audienceName = 'Updated Name';

            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
                Test.stopTest();

                System.assert(resList[0].success, 'Update should succeed');
                System.assertEquals('Updated Name', [SELECT Name FROM Audience__c WHERE Id = :rec.Id].Name);
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testUpdate_InvalidId_Fails() {
        System.runAs(crudUser()) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Update';
            req.audienceId = AgentCore_TestFactory.generateFakeId(Audience__c.SObjectType);
            req.audienceName = 'Name';

            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
                Test.stopTest();

                System.assert(!resList[0].success, 'Update should fail for invalid Id');
                System.assert(resList[0].audienceDetails.message.contains('Audience not found'));
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    // =================================================================================
    // RETRIEVE Action Tests
    // =================================================================================
    @isTest
    static void testRetrieve_ByCriteria_Succeeds() {
        System.runAs(crudUser()) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Retrieve';
            req.audienceName = 'Test';

            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
                Test.stopTest();

                System.assert(resList[0].success, 'Expected success on valid Retrieve action');
                System.assertEquals(1, resList[0].audienceDetails.totalRecordCount);
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieve_SearchWithHyphen_Succeeds() {
        System.runAs(crudUser()) {
            Audience__c hyphenAud = [SELECT Id, Name FROM Audience__c WHERE Name = 'Hyphen-Audience' LIMIT 1];
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Retrieve';
            req.audienceName = hyphenAud.Name;

            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
                Test.stopTest();

                System.assert(resList[0].success, 'Expected success on hyphenated search term');
                System.assertEquals(1, resList[0].audienceDetails.totalRecordCount);
                System.assertEquals(hyphenAud.Id, resList[0].audienceDetails.records[0].audienceId);
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieve_SearchWithSpecialCharacters_Succeeds() {
        System.runAs(crudUser()) {
            Audience__c specialAud = [SELECT Id, Name FROM Audience__c WHERE Name = 'Audience 100%' LIMIT 1];
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Retrieve';
            req.audienceName = specialAud.Name;

            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
                Test.stopTest();

                System.assert(resList[0].success, 'Expected success on search term with special character');
                System.assertEquals(1, resList[0].audienceDetails.totalRecordCount);
                System.assertEquals(specialAud.Id, resList[0].audienceDetails.records[0].audienceId);
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieve_ById_Succeeds() {
        List<Learner_Profile__c> learners = AgentCore_TestFactory.createLearnerProfiles(2, true);

        System.runAs(crudUser()) {
            Audience__c aud = AgentCore_TestFactory.createAudiences(1, true)[0];
            AgentCore_TestFactory.createAudienceMembers(aud, learners, true);

            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Retrieve';
            req.audienceId = aud.Id;

            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
                Test.stopTest();

                System.assert(resList[0].success, 'Expected success on valid Retrieve action');
                System.assertEquals(2, resList[0].audienceDetails.records[0].memberCount);
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testRetrieve_NoPermission_DeniedAtHandler() {
        // Standard user without Audience permissions
        User noPerm = AgentCore_TestFactory.createUsers(1, 'Standard User', true)[0];
        System.runAs(noPerm) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Retrieve';
            req.audienceName = 'Test';

            List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
            System.assertEquals(1, resList.size());
            System.assertEquals(false, resList[0].success);
            System.assert(resList[0].audienceDetails.message != null && resList[0].audienceDetails.message.toLowerCase().contains('permission'));
            System.assertEquals(true, resList[0].permissionDenied, 'Handler response should flag permissionDenied');
        }
    }

    @isTest
    static void testRetrieve_InvalidId_Fails() {
        System.runAs(crudUser()) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Retrieve';
            req.audienceId = AgentCore_TestFactory.generateFakeId(Audience__c.SObjectType);

            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
                Test.stopTest();

                System.assert(!resList[0].success, 'Retrieve should fail for invalid Id');
                System.assert(resList[0].audienceDetails.message.contains('Audience not found'));
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    // =================================================================================
    // DELETE Action Tests
    // =================================================================================
    @isTest
    static void testDelete_Succeeds() {
        System.runAs(crudUser()) {
            Audience__c rec = AgentCore_TestFactory.createAudiences(1, true)[0];
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Delete';
            req.audienceId = rec.Id;

            Boolean prevBypass = AgentCore_Permissions.TEST_BYPASS;
            AgentCore_Permissions.TEST_BYPASS = true;
            try {
                Test.startTest();
                List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
                Test.stopTest();

                System.assert(resList[0].success, 'Expected success on valid Delete action');
                System.assertEquals(0, [SELECT count() FROM Audience__c WHERE Id = :rec.Id]);
            } finally {
                AgentCore_Permissions.TEST_BYPASS = prevBypass;
            }
        }
    }

    @isTest
    static void testDelete_NoId_Fails() {
        System.runAs(crudUser()) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'Delete';

            Test.startTest();
            List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});
            Test.stopTest();

            System.assert(!resList[0].success, 'Delete should fail when no Id is provided');
            System.assert(resList[0].audienceDetails.message.contains('Audience ID is required'));
        }
    }

    // =================================================================================
    // ERROR Handling Tests
    // =================================================================================
    @isTest
    static void testNoActionSpecified_Fails() {
        System.runAs(crudUser()) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = '';

            List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});

            System.assert(!resList[0].success, 'Should fail when no action is specified');
            System.assert(resList[0].audienceDetails.message.contains('Action parameter is required'));
        }
    }

    @isTest
    static void testInvalidAction_Fails() {
        System.runAs(crudUser()) {
            FRAGENTAudienceHandler.Request req = new FRAGENTAudienceHandler.Request();
            req.action = 'InvalidAction';

            List<FRAGENTAudienceHandler.Response> resList = FRAGENTAudienceHandler.manageAudiences(new List<FRAGENTAudienceHandler.Request>{req});

            System.assert(!resList[0].success, 'Should fail for an invalid action');
            System.assert(resList[0].audienceDetails.message.contains('Invalid action'));
        }
    }
}




