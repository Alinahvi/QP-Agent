/**
 * @isTest
 * @description Test class for FRAGENTAssignedSessionHandler.
 * Verifies the assignment of sessions to learners and related error handling.
 */
@isTest
private class FRAGENTAssignedSessionHandler_Test {

    @TestSetup
    static void setupData() {
        // Create Personas
        PermissionSet crudPs = FRAGENTTestDataFactory.createPermissionSet('Assigned_Session_CRUD');
        PermissionSet cruPs = FRAGENTTestDataFactory.createPermissionSet('Assigned_Session_CRU');
        PermissionSet rPs = FRAGENTTestDataFactory.createPermissionSet('Assigned_Session_R');

        List<User> users = FRAGENTTestDataFactory.createUsers(4, 'Standard User', false);
        users[0].Alias = 'crud';
        users[1].Alias = 'cru';
        users[2].Alias = 'r';
        users[3].Alias = 'noaccess';
        insert users;

        insert new PermissionSetAssignment(AssigneeId = users[0].Id, PermissionSetId = crudPs.Id);
        insert new PermissionSetAssignment(AssigneeId = users[1].Id, PermissionSetId = cruPs.Id);
        insert new PermissionSetAssignment(AssigneeId = users[2].Id, PermissionSetId = rPs.Id);

        // Assign permission set to allow read access to Recommended_Learning__c for trigger execution
        PermissionSet recLearningReadPs = new PermissionSet(Name = 'TestRecLearningRead', Label = 'Test Rec Learning Read');
        insert recLearningReadPs;
        insert new ObjectPermissions(ParentId = recLearningReadPs.Id, SobjectType = 'Recommended_Learning__c', PermissionsRead = true);
        insert new FieldPermissions(ParentId = recLearningReadPs.Id, SobjectType = 'Recommended_Learning__c', Field = 'Recommended_Learning__c.Key__c', PermissionsRead = true);
        
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        assignments.add(new PermissionSetAssignment(AssigneeId = users[0].Id, PermissionSetId = recLearningReadPs.Id));
        assignments.add(new PermissionSetAssignment(AssigneeId = users[2].Id, PermissionSetId = recLearningReadPs.Id));
        insert assignments;

        // Assign permission set to satisfy validation rule
        PermissionSet actLearningAdminPs = [SELECT Id FROM PermissionSet WHERE Name = 'ACT_Learning_Admin'];
        insert new PermissionSetAssignment(AssigneeId = users[0].Id, PermissionSetId = actLearningAdminPs.Id);

        // Create Test Data
        System.runAs(users[0]) {
            Learner_Profile__c learner = new Learner_Profile__c(
                Name = 'Test Learner',
                User__c = users[0].Id
            );
            insert learner;

            Asset__c asset = new Asset__c(Name = 'Test Asset');
            insert asset;
            
            Session__c session = new Session__c(
                Name = 'Test Session', 
                Asset__c = asset.Id,
                Start_Date__c = Date.today(),
                Start_Time__c = Time.newInstance(9, 0, 0, 0),
                End_Time__c = Time.newInstance(10, 0, 0, 0),
                Time_Zone__c = UserInfo.getTimeZone().getID()
            );
            insert session;
        }
    }

    private static FRAGENTAssignedSessionHandler.Request createRequest(String action, String learnerProfileId, String sessionId) {
        FRAGENTAssignedSessionHandler.Request req = new FRAGENTAssignedSessionHandler.Request();
        req.actionType = action;
        req.learnerProfileId = learnerProfileId;
        req.sessionId = sessionId;
        return req;
    }
    
    @isTest
    static void testCreateAssignedSession() {
        User crudUser = [SELECT Id FROM User WHERE Alias = 'crud' LIMIT 1];
        Learner_Profile__c learner = [SELECT Id FROM Learner_Profile__c LIMIT 1];
        Session__c session = [SELECT Id FROM Session__c LIMIT 1];
        
        FRAGENTAssignedSessionHandler.Request req = createRequest('Create', learner.Id, session.Id);
        
        Test.startTest();
        System.runAs(crudUser){
            List<FRAGENTAssignedSessionHandler.Response> responses = FRAGENTAssignedSessionHandler.processAssignedSession(new List<FRAGENTAssignedSessionHandler.Request>{req});
            Test.stopTest();

            System.assertEquals(1, responses.size());
            System.assertEquals(true, responses[0].success);
            System.assertEquals(1, responses[0].assignedSessionRecords.size());
            System.assertEquals(learner.Id, responses[0].assignedSessionRecords[0].Learner_Profile__c);
            System.assertEquals(session.Id, responses[0].assignedSessionRecords[0].Session__c);
        }
    }

    @isTest
    static void testSearchAssignedSession() {
        User rUser = [SELECT Id FROM User WHERE Alias = 'r' LIMIT 1];
        Learner_Profile__c learner = [SELECT Id FROM Learner_Profile__c LIMIT 1];
        Session__c session = [SELECT Id FROM Session__c LIMIT 1];
        
        System.runAs(rUser){
            insert new Assigned_Session__c(Learner_Profile__c = learner.Id, Session__c = session.Id);
        }
        
        FRAGENTAssignedSessionHandler.Request req = createRequest('Search', learner.Id, null);
        
        Test.startTest();
        System.runAs(rUser){
            List<FRAGENTAssignedSessionHandler.Response> responses = FRAGENTAssignedSessionHandler.processAssignedSession(new List<FRAGENTAssignedSessionHandler.Request>{req});
            Test.stopTest();

            System.assertEquals(1, responses.size());
            System.assertEquals(true, responses[0].success);
            System.assertEquals(1, responses[0].assignedSessionRecords.size());
        }
    }

    @isTest
    static void testCreate_NoLearnerId_Fails() {
        User crudUser = [SELECT Id FROM User WHERE Alias = 'crud' LIMIT 1];
        Session__c session = [SELECT Id FROM Session__c LIMIT 1];
        
        FRAGENTAssignedSessionHandler.Request req = createRequest('Create', null, session.Id);

        Test.startTest();
        System.runAs(crudUser){
            List<FRAGENTAssignedSessionHandler.Response> responses = FRAGENTAssignedSessionHandler.processAssignedSession(new List<FRAGENTAssignedSessionHandler.Request>{req});
            Test.stopTest();
            
            System.assertEquals(1, responses.size());
            System.assertEquals(false, responses[0].success);
            System.assert(responses[0].message.contains('Learner Profile ID is required'));
        }
    }

    @isTest
    static void testCreate_NoSessionId_Fails() {
        User crudUser = [SELECT Id FROM User WHERE Alias = 'crud' LIMIT 1];
        Learner_Profile__c learner = [SELECT Id FROM Learner_Profile__c LIMIT 1];
        
        FRAGENTAssignedSessionHandler.Request req = createRequest('Create', learner.Id, null);
        
        Test.startTest();
        System.runAs(crudUser){
            List<FRAGENTAssignedSessionHandler.Response> responses = FRAGENTAssignedSessionHandler.processAssignedSession(new List<FRAGENTAssignedSessionHandler.Request>{req});
            Test.stopTest();

            System.assertEquals(1, responses.size());
            System.assertEquals(false, responses[0].success);
            System.assert(responses[0].message.contains('Session ID is required'));
        }
    }
}