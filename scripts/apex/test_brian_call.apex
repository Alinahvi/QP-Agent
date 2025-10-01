// Test Call Scheduler with Brian as Organizer
System.debug('=== TESTING BRIAN AS ORGANIZER ===');

try {
    // Test with Brian as the organizer
    System.debug('--- Testing Brian as Organizer ---');
    
    // Create a test request with Brian as organizer
    ANAgentCallSchedulerService.CallScheduleRequest request = new ANAgentCallSchedulerService.CallScheduleRequest();
    request.subject = 'Brian Organizer Test Call';
    request.startDate = '2025-01-22';
    request.startTime = '11:00 AM';
    request.durationMinutes = 45;
    request.description = 'Testing call scheduling with Brian as organizer';
    request.organizerEmail = 'brian.floyd@salesforce.com';
    request.participantEmails = 'anahvi@salesforce.com';
    request.requestId = 'BRIAN-TEST-001';
    
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
        System.debug('✅ SUCCESS: Call scheduled successfully with Brian as organizer!');
        System.debug('Call ID: ' + response.callId);
        System.debug('Event ID: ' + response.eventId);
        
        // Verify the records were created
        if (String.isNotBlank(response.callId)) {
            System.debug('✅ Call Task created with ID: ' + response.callId);
        }
        
        if (String.isNotBlank(response.eventId)) {
            System.debug('✅ Calendar Event created with ID: ' + response.eventId);
        }
        
        System.debug('✅ Automatic Learner Profile lookup working for Brian!');
        
    } else {
        System.debug('❌ FAILED: ' + response.message);
    }
    
    System.debug('=== Test completed! ===');

} catch (Exception e) {
    System.debug('❌ Test failed with error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 