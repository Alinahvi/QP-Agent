// Test script for automatic Learner Profile lookup in ANAgentCallSchedulerService
System.debug('=== Testing Automatic Learner Profile Lookup ===');

try {
    // Test the automatic Learner Profile lookup
    System.debug('--- Testing Learner Profile Lookup ---');
    
    // Test with Anahvi's email (we know this exists)
    String anahviEmail = 'anahvi@salesforce.com';
    System.debug('Looking up Learner Profile for: ' + anahviEmail);
    
    // Test the service class
    ANAgentCallSchedulerService.CallScheduleRequest request = new ANAgentCallSchedulerService.CallScheduleRequest();
    request.subject = 'Test Auto Learner Profile';
    request.startDate = '2025-01-22';
    request.startTime = '10:00 AM';
    request.durationMinutes = 30;
    request.description = 'Testing automatic Learner Profile lookup';
    request.organizerEmail = anahviEmail;
    request.participantEmails = 'brian.floyd@salesforce.com';
    request.requestId = 'TEST-AUTO-LEARNER-001';
    
    System.debug('Request created: ' + request);
    
    // Test the service method
    ANAgentCallSchedulerService.CallScheduleResponse response = ANAgentCallSchedulerService.scheduleCall(request);
    System.debug('Response: ' + response);
    
    if (response.success) {
        System.debug('✅ SUCCESS: Call scheduled with automatic Learner Profile lookup!');
        System.debug('Call ID: ' + response.callId);
        System.debug('Event ID: ' + response.eventId);
    } else {
        System.debug('❌ FAILED: ' + response.message);
    }
    
    System.debug('=== Test completed! ===');

} catch (Exception e) {
    System.debug('❌ Test failed with error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 