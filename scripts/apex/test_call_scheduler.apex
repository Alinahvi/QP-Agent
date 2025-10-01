// Test script for ANAgentCallScheduler classes
System.debug('=== Testing ANAgentCallScheduler Classes ===');

try {
    // Test the service class
    ANAgentCallSchedulerService service = new ANAgentCallSchedulerService();
    System.debug('✓ Service class instantiated successfully');
    
    // Test the handler class
    ANAgentCallSchedulerHandler handler = new ANAgentCallSchedulerHandler();
    System.debug('✓ Handler class instantiated successfully');
    
    // Test creating a request
    ANAgentCallSchedulerService.CallScheduleRequest request = new ANAgentCallSchedulerService.CallScheduleRequest();
    request.subject = 'Test Call with Customer';
    request.startDate = '2025-01-22';
    request.startTime = '10:00 AM';
    request.durationMinutes = 60;
    request.description = 'Test call scheduling functionality';
    request.callType = 'Meeting';
    request.priority = 'High';
    request.location = 'Virtual';
    request.organizerEmail = 'agent@example.com';
    request.participantEmails = 'customer@example.com';
    request.requestId = 'TEST-001';
    
    System.debug('✓ Request object created successfully');
    System.debug('Request details: ' + request);
    
    // Test the service method
    ANAgentCallSchedulerService.CallScheduleResponse response = ANAgentCallSchedulerService.scheduleCall(request);
    System.debug('✓ Service method called successfully');
    System.debug('Response: ' + response);
    
    System.debug('=== All tests passed! ===');
    
} catch (Exception e) {
    System.debug('❌ Test failed with error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 