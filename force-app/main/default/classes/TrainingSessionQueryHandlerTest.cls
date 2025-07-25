@isTest
private class TrainingSessionQueryHandlerTest {

    @TestSetup
    static void makeData() {
        // Create Learners
        Learner_Profile__c attendedUser = new Learner_Profile__c(Name = 'Attended User', Status__c = 'Active');
        Learner_Profile__c registeredUser = new Learner_Profile__c(Name = 'Registered User', Status__c = 'Active');
        insert new List<Learner_Profile__c>{attendedUser, registeredUser};

        // Create a parent Event (Asset)
        Asset__c parentEvent = new Asset__c(Name = 'Q3 Sales Summit', RecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId());
        insert parentEvent;
        
        // Create Sessions for the event
        Session__c attendedSession = new Session__c(Name = 'Q3 Sales Kickoff Session', Asset__c = parentEvent.Id, Start_Date__c = Date.today().addDays(-7));
        Session__c registeredSession = new Session__c(Name = 'Q3 Sales Planning Session', Asset__c = parentEvent.Id, Start_Date__c = Date.today().addDays(7));
        insert new List<Session__c>{attendedSession, registeredSession};
        
        // Create session assignments
        List<Assigned_Session__c> assignments = new List<Assigned_Session__c>{
            new Assigned_Session__c(Learner_Profile__c = attendedUser.Id, Session__c = attendedSession.Id, Status__c = 'Attended'),
            new Assigned_Session__c(Learner_Profile__c = registeredUser.Id, Session__c = registeredSession.Id, Status__c = 'Registered')
        };
        insert assignments;
    }

    @isTest
    static void testQueryForAttendees_BySessionName() {
        // Arrange
        TrainingSessionQueryHandler handler = new TrainingSessionQueryHandler();
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.FILTERS = new TrainingQueryRequest.Filters();
        request.FILTERS.Session_Name = 'Kickoff Session';
        request.FILTERS.Session_Participant_Status = 'Attended';
        request.RESPONSE_CRITERIA = new TrainingQueryRequest.ResponseCriteria();
        request.RESPONSE_CRITERIA.RETURN_FIELDS = new List<String>{'Learner_Profile__r.Name'};

        // Act
        String result = handler.process(request);

        // Assert
        System.assert(result.contains('Attended User'), 'Result should contain the user who attended.');
        System.assert(!result.contains('Registered User'), 'Result should NOT contain the user who is only registered.');
    }

    @isTest
    static void testQueryByRelativeDate() {
        // Arrange: Find sessions happening NEXT week
        TrainingSessionQueryHandler handler = new TrainingSessionQueryHandler();
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.FILTERS = new TrainingQueryRequest.Filters();
        request.FILTERS.RELATIVE_DATE_TERM = 'NEXT_WEEK';
        request.RESPONSE_CRITERIA = new TrainingQueryRequest.ResponseCriteria();
        request.RESPONSE_CRITERIA.RETURN_FIELDS = new List<String>{'Session__r.Name'};
        
        // Act
        String result = handler.process(request);

        // Assert
        System.assert(result.contains('Planning Session'), 'Result should contain the session scheduled for next week.');
        System.assert(!result.contains('Kickoff Session'), 'Result should NOT contain the session from last week.');
    }
}