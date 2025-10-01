// Test script for updated call scheduler with Google Calendar integration
// Run this in Developer Console or via SFDX

// Test the call scheduler with the same parameters from before
Map<String, Object> testRequest = new Map<String, Object>{
    'durationMinutes' => 30,
    'participantEmails' => 'brian.floyd@salesforce.com',
    'subject' => 'test agent updated',
    'description' => 'test agent updated',
    'location' => 'Virtual',
    'startTime' => '07:00 AM',
    'organizerEmail' => 'anahvi@salesforce.com',
    'priority' => 'Medium',
    'callType' => 'Outbound',
    'startDate' => '2025-08-11'
};

try {
    // Convert to the handler request format
    ANAgentCallSchedulerHandler.CallScheduleRequest request = new ANAgentCallSchedulerHandler.CallScheduleRequest();
    request.subject = (String)testRequest.get('subject');
    request.startDate = (String)testRequest.get('startDate');
    request.startTime = (String)testRequest.get('startTime');
    request.durationMinutes = (Integer)testRequest.get('durationMinutes');
    request.description = (String)testRequest.get('description');
    request.location = (String)testRequest.get('location');
    request.organizerEmail = (String)testRequest.get('organizerEmail');
    request.participantEmails = (String)testRequest.get('participantEmails');
    request.priority = (String)testRequest.get('priority');
    request.callType = (String)testRequest.get('callType');
    
    // Call the scheduler
    List<ANAgentCallSchedulerHandler.CallScheduleResponse> responses = 
        ANAgentCallSchedulerHandler.scheduleCall(new List<ANAgentCallSchedulerHandler.CallScheduleRequest>{request});
    
    // Display results
    if (!responses.isEmpty()) {
        ANAgentCallSchedulerHandler.CallScheduleResponse response = responses[0];
        System.debug('=== CALL SCHEDULER TEST RESULTS ===');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Call ID: ' + response.callId);
        System.debug('Call URL: ' + response.callUrl);
        System.debug('Event ID: ' + response.eventId);
        System.debug('Event URL: ' + response.eventUrl);
        System.debug('Google Calendar Event ID: ' + response.gcalEventId);
        System.debug('Request ID: ' + response.requestId);
        
        if (response.success) {
            System.debug('✅ Call scheduled successfully!');
            if (String.isNotBlank(response.gcalEventId)) {
                System.debug('✅ Google Calendar event created with ID: ' + response.gcalEventId);
            } else {
                System.debug('⚠️ Google Calendar event not created - check integration setup');
            }
        } else {
            System.debug('❌ Call scheduling failed: ' + response.message);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing call scheduler: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 