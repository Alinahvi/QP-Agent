// Single Call Scheduler Test - No Email Limits
System.debug('=== SINGLE CALL SCHEDULER TEST (NO EMAIL LIMITS) ===');

try {
    // Test the automatic Learner Profile lookup with a single call
    System.debug('--- Testing Single Call with Auto Learner Profile ---');
    
    // Create a simple test request
    ANAgentCallSchedulerService.CallScheduleRequest request = new ANAgentCallSchedulerService.CallScheduleRequest();
    request.subject = 'Single Test Call - Auto Learner Profile';
    request.startDate = '2025-01-22';
    request.startTime = '10:00 AM';
    request.durationMinutes = 30;
    request.description = 'Testing automatic Learner Profile lookup functionality';
    request.organizerEmail = 'anahvi@salesforce.com';
    request.participantEmails = 'brian.floyd@salesforce.com';
    request.requestId = 'SINGLE-TEST-001';
    
    System.debug('Request created: ' + request);
    System.debug('Organizer Email: ' + request.organizerEmail);
    System.debug('Participant Emails: ' + request.participantEmails);
    
    // Test the service method
    ANAgentCallSchedulerService.CallScheduleResponse response = ANAgentCallSchedulerService.scheduleCall(request);
    
    System.debug('=== TEST RESULTS ===');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Request ID: ' + response.requestId);
    
    if (response.success) {
        System.debug('✅ SUCCESS: Call scheduled successfully!');
        System.debug('Call ID: ' + response.callId);
        System.debug('Event ID: ' + response.eventId);
        
        // Verify the records were created
        if (String.isNotBlank(response.callId)) {
            System.debug('✅ Call Task created with ID: ' + response.callId);
        }
        
        if (String.isNotBlank(response.eventId)) {
            System.debug('✅ Calendar Event created with ID: ' + response.eventId);
        }
        
        System.debug('✅ Automatic Learner Profile lookup working!');
        
    } else {
        System.debug('❌ FAILED: ' + response.message);
    }
    
    System.debug('=== Test completed! ===');

} catch (Exception e) {
    System.debug('❌ Test failed with error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 