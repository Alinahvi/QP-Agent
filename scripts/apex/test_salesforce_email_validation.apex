// Test script for Salesforce email validation in ANAgentCallScheduler classes
System.debug('=== Testing Salesforce Email Validation ===');

try {
    // Test 1: Valid Salesforce email (should succeed)
    System.debug('--- Test 1: Valid Salesforce Email ---');
    ANAgentCallSchedulerService.CallScheduleRequest validRequest = new ANAgentCallSchedulerService.CallScheduleRequest();
    validRequest.subject = 'Test Call with Valid Email';
    validRequest.startDate = '2025-01-22';
    validRequest.startTime = '10:00 AM';
    validRequest.durationMinutes = 60;
    validRequest.description = 'Testing valid Salesforce email';
    validRequest.organizerEmail = 'agent@salesforce.com';
    validRequest.participantEmails = 'manager@salesforce.com,team@salesforce.com';
    validRequest.requestId = 'TEST-VALID-001';
    
    ANAgentCallSchedulerService.CallScheduleResponse validResponse = ANAgentCallSchedulerService.scheduleCall(validRequest);
    System.debug('Valid email test result: ' + validResponse.success + ' - ' + validResponse.message);
    
    // Test 2: Invalid organizer email (should fail)
    System.debug('--- Test 2: Invalid Organizer Email ---');
    ANAgentCallSchedulerService.CallScheduleRequest invalidOrgRequest = new ANAgentCallSchedulerService.CallScheduleRequest();
    invalidOrgRequest.subject = 'Test Call with Invalid Organizer';
    invalidOrgRequest.startDate = '2025-01-22';
    invalidOrgRequest.startTime = '10:00 AM';
    invalidOrgRequest.durationMinutes = 60;
    invalidOrgRequest.description = 'Testing invalid organizer email';
    invalidOrgRequest.organizerEmail = 'agent@external.com';
    invalidOrgRequest.requestId = 'TEST-INVALID-ORG-001';
    
    ANAgentCallSchedulerService.CallScheduleResponse invalidOrgResponse = ANAgentCallSchedulerService.scheduleCall(invalidOrgRequest);
    System.debug('Invalid organizer email test result: ' + invalidOrgResponse.success + ' - ' + invalidOrgResponse.message);
    
    // Test 3: Invalid participant email (should fail)
    System.debug('--- Test 3: Invalid Participant Email ---');
    ANAgentCallSchedulerService.CallScheduleRequest invalidPartRequest = new ANAgentCallSchedulerService.CallScheduleRequest();
    invalidPartRequest.subject = 'Test Call with Invalid Participant';
    invalidPartRequest.startDate = '2025-01-22';
    invalidPartRequest.startTime = '10:00 AM';
    invalidPartRequest.durationMinutes = 60;
    invalidPartRequest.description = 'Testing invalid participant email';
    invalidPartRequest.organizerEmail = 'agent@salesforce.com';
    invalidPartRequest.participantEmails = 'manager@salesforce.com,external@company.com';
    invalidPartRequest.requestId = 'TEST-INVALID-PART-001';
    
    ANAgentCallSchedulerService.CallScheduleResponse invalidPartResponse = ANAgentCallSchedulerService.scheduleCall(invalidPartRequest);
    System.debug('Invalid participant email test result: ' + invalidPartResponse.success + ' - ' + invalidPartResponse.message);
    
    System.debug('=== All validation tests completed! ===');
    
} catch (Exception e) {
    System.debug('❌ Test failed with error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 