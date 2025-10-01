// Comprehensive End-to-End Test Script for ANAgentCallSchedulerService
// Testing 10 different scenarios with various parameters
System.debug('=== COMPREHENSIVE CALL SCHEDULER TEST SUITE ===');

// Test Case 1: Basic call scheduling for Anahvi
System.debug('--- Test Case 1: Basic Call for Anahvi ---');
try {
    ANAgentCallSchedulerService.CallScheduleRequest request1 = new ANAgentCallSchedulerService.CallScheduleRequest();
    request1.subject = 'Test Case 1: Basic Call Scheduling';
    request1.startDate = '2025-01-22';
    request1.startTime = '09:00 AM';
    request1.durationMinutes = 30;
    request1.description = 'Testing basic functionality with minimal parameters';
    request1.organizerEmail = 'anahvi@salesforce.com';
    request1.participantEmails = 'brian.floyd@salesforce.com';
    request1.requestId = 'TEST-001-BASIC';
    
    ANAgentCallSchedulerService.CallScheduleResponse response1 = ANAgentCallSchedulerService.scheduleCall(request1);
    System.debug('Test 1 Result: ' + (response1.success ? '✅ SUCCESS' : '❌ FAILED'));
    System.debug('Message: ' + response1.message);
    if (response1.success) {
        System.debug('Call ID: ' + response1.callId + ', Event ID: ' + response1.eventId);
    }
} catch (Exception e) {
    System.debug('❌ Test 1 Exception: ' + e.getMessage());
}

// Test Case 2: Long duration call for Brian
System.debug('--- Test Case 2: Long Duration Call for Brian ---');
try {
    ANAgentCallSchedulerService.CallScheduleRequest request2 = new ANAgentCallSchedulerService.CallScheduleRequest();
    request2.subject = 'Test Case 2: Extended Team Meeting';
    request2.startDate = '2025-01-22';
    request2.startTime = '02:00 PM';
    request2.durationMinutes = 120;
    request2.description = 'Testing longer duration calls and different time slots';
    request2.organizerEmail = 'brian.floyd@salesforce.com';
    request2.participantEmails = 'anahvi@salesforce.com';
    request2.requestId = 'TEST-002-LONG';
    
    ANAgentCallSchedulerService.CallScheduleResponse response2 = ANAgentCallSchedulerService.scheduleCall(request2);
    System.debug('Test 2 Result: ' + (response2.success ? '✅ SUCCESS' : '❌ FAILED'));
    System.debug('Message: ' + response2.message);
    if (response2.success) {
        System.debug('Call ID: ' + response2.callId + ', Event ID: ' + response2.eventId);
    }
} catch (Exception e) {
    System.debug('❌ Test 2 Exception: ' + e.getMessage());
}

// Test Case 3: High priority urgent call
System.debug('--- Test Case 3: High Priority Urgent Call ---');
try {
    ANAgentCallSchedulerService.CallScheduleRequest request3 = new ANAgentCallSchedulerService.CallScheduleRequest();
    request3.subject = 'Test Case 3: URGENT - Critical Issue Discussion';
    request3.startDate = '2025-01-22';
    request3.startTime = '11:30 AM';
    request3.durationMinutes = 45;
    request3.description = 'Testing high priority calls with urgent subject lines';
    request3.organizerEmail = 'anahvi@salesforce.com';
    request3.participantEmails = 'brian.floyd@salesforce.com';
    request3.priority = 'High';
    request3.requestId = 'TEST-003-URGENT';
    
    ANAgentCallSchedulerService.CallScheduleResponse response3 = ANAgentCallSchedulerService.scheduleCall(request3);
    System.debug('Test 3 Result: ' + (response3.success ? '✅ SUCCESS' : '❌ FAILED'));
    System.debug('Message: ' + response3.message);
    if (response3.success) {
        System.debug('Call ID: ' + response3.callId + ', Event ID: ' + response3.eventId);
    }
} catch (Exception e) {
    System.debug('❌ Test 3 Exception: ' + e.getMessage());
}

// Test Case 4: Different call type (Inbound)
System.debug('--- Test Case 4: Inbound Call Type ---');
try {
    ANAgentCallSchedulerService.CallScheduleRequest request4 = new ANAgentCallSchedulerService.CallScheduleRequest();
    request4.subject = 'Test Case 4: Inbound Customer Support Call';
    request4.startDate = '2025-01-22';
    request4.startTime = '03:00 PM';
    request4.durationMinutes = 60;
    request4.description = 'Testing different call types (Inbound)';
    request4.organizerEmail = 'brian.floyd@salesforce.com';
    request4.participantEmails = 'anahvi@salesforce.com';
    request4.callType = 'Inbound';
    request4.requestId = 'TEST-004-INBOUND';
    
    ANAgentCallSchedulerService.CallScheduleResponse response4 = ANAgentCallSchedulerService.scheduleCall(request4);
    System.debug('Test 4 Result: ' + (response4.success ? '✅ SUCCESS' : '❌ FAILED'));
    System.debug('Message: ' + response4.message);
    if (response4.success) {
        System.debug('Call ID: ' + response4.callId + ', Event ID: ' + response4.eventId);
    }
} catch (Exception e) {
    System.debug('❌ Test 4 Exception: ' + e.getMessage());
}

// Test Case 5: Office location meeting
System.debug('--- Test Case 5: Office Location Meeting ---');
try {
    ANAgentCallSchedulerService.CallScheduleRequest request5 = new ANAgentCallSchedulerService.CallScheduleRequest();
    request5.subject = 'Test Case 5: In-Person Office Meeting';
    request5.startDate = '2025-01-22';
    request5.startTime = '04:30 PM';
    request5.durationMinutes = 90;
    request5.description = 'Testing different location types (Office)';
    request5.organizerEmail = 'anahvi@salesforce.com';
    request5.participantEmails = 'brian.floyd@salesforce.com';
    request5.location = 'Office';
    request5.requestId = 'TEST-005-OFFICE';
    
    ANAgentCallSchedulerService.CallScheduleResponse response5 = ANAgentCallSchedulerService.scheduleCall(request5);
    System.debug('Test 5 Result: ' + (response5.success ? '✅ SUCCESS' : '❌ FAILED'));
    System.debug('Message: ' + response5.message);
    if (response5.success) {
        System.debug('Call ID: ' + response5.callId + ', Event ID: ' + response5.eventId);
    }
} catch (Exception e) {
    System.debug('❌ Test 5 Exception: ' + e.getMessage());
}

// Test Case 6: Multiple participants
System.debug('--- Test Case 6: Multiple Participants ---');
try {
    ANAgentCallSchedulerService.CallScheduleRequest request6 = new ANAgentCallSchedulerService.CallScheduleRequest();
    request6.subject = 'Test Case 6: Team Standup with Multiple People';
    request6.startDate = '2025-01-22';
    request6.startTime = '08:00 AM';
    request6.durationMinutes = 15;
    request6.description = 'Testing multiple participant emails';
    request6.organizerEmail = 'brian.floyd@salesforce.com';
    request6.participantEmails = 'anahvi@salesforce.com,manager@salesforce.com,team@salesforce.com';
    request6.requestId = 'TEST-006-MULTI';
    
    ANAgentCallSchedulerService.CallScheduleResponse response6 = ANAgentCallSchedulerService.scheduleCall(request6);
    System.debug('Test 6 Result: ' + (response6.success ? '✅ SUCCESS' : '❌ FAILED'));
    System.debug('Message: ' + response6.message);
    if (response6.success) {
        System.debug('Call ID: ' + response6.callId + ', Event ID: ' + response6.eventId);
    }
} catch (Exception e) {
    System.debug('❌ Test 6 Exception: ' + e.getMessage());
}

// Test Case 7: Internal call type
System.debug('--- Test Case 7: Internal Call Type ---');
try {
    ANAgentCallSchedulerService.CallScheduleRequest request7 = new ANAgentCallSchedulerService.CallScheduleRequest();
    request7.subject = 'Test Case 7: Internal Team Sync';
    request7.startDate = '2025-01-22';
    request7.startTime = '01:00 PM';
    request7.durationMinutes = 30;
    request7.description = 'Testing Internal call type';
    request7.organizerEmail = 'anahvi@salesforce.com';
    request7.participantEmails = 'brian.floyd@salesforce.com';
    request7.callType = 'Internal';
    request7.requestId = 'TEST-007-INTERNAL';
    
    ANAgentCallSchedulerService.CallScheduleResponse response7 = ANAgentCallSchedulerService.scheduleCall(request7);
    System.debug('Test 7 Result: ' + (response7.success ? '✅ SUCCESS' : '❌ FAILED'));
    System.debug('Message: ' + response7.message);
    if (response7.success) {
        System.debug('Call ID: ' + response7.callId + ', Event ID: ' + response7.eventId);
    }
} catch (Exception e) {
    System.debug('❌ Test 7 Exception: ' + e.getMessage());
}

// Test Case 8: Low priority call
System.debug('--- Test Case 8: Low Priority Call ---');
try {
    ANAgentCallSchedulerService.CallScheduleRequest request8 = new ANAgentCallSchedulerService.CallScheduleRequest();
    request8.subject = 'Test Case 8: Casual Team Chat';
    request8.startDate = '2025-01-22';
    request8.startTime = '05:00 PM';
    request8.durationMinutes = 20;
    request8.description = 'Testing low priority calls';
    request8.organizerEmail = 'brian.floyd@salesforce.com';
    request8.participantEmails = 'anahvi@salesforce.com';
    request8.priority = 'Low';
    request8.requestId = 'TEST-008-LOW';
    
    ANAgentCallSchedulerService.CallScheduleResponse response8 = ANAgentCallSchedulerService.scheduleCall(request8);
    System.debug('Test 8 Result: ' + (response8.success ? '✅ SUCCESS' : '❌ FAILED'));
    System.debug('Message: ' + response8.message);
    if (response8.success) {
        System.debug('Call ID: ' + response8.callId + ', Event ID: ' + response8.eventId);
    }
} catch (Exception e) {
    System.debug('❌ Test 8 Exception: ' + e.getMessage());
}

// Test Case 9: Client site location
System.debug('--- Test Case 9: Client Site Location ---');
try {
    ANAgentCallSchedulerService.CallScheduleRequest request9 = new ANAgentCallSchedulerService.CallScheduleRequest();
    request9.subject = 'Test Case 9: Client Site Visit';
    request9.startDate = '2025-01-22';
    request9.startTime = '10:30 AM';
    request9.durationMinutes = 120;
    request9.description = 'Testing client site location type';
    request9.organizerEmail = 'anahvi@salesforce.com';
    request9.participantEmails = 'brian.floyd@salesforce.com';
    request9.location = 'Client Site';
    request9.requestId = 'TEST-009-CLIENT';
    
    ANAgentCallSchedulerService.CallScheduleResponse response9 = ANAgentCallSchedulerService.scheduleCall(request9);
    System.debug('Test 9 Result: ' + (response9.success ? '✅ SUCCESS' : '❌ FAILED'));
    System.debug('Message: ' + response9.message);
    if (response9.success) {
        System.debug('Call ID: ' + response9.callId + ', Event ID: ' + response9.eventId);
    }
} catch (Exception e) {
    System.debug('❌ Test 9 Exception: ' + e.getMessage());
}

// Test Case 10: Early morning call with detailed description
System.debug('--- Test Case 10: Early Morning Detailed Call ---');
try {
    ANAgentCallSchedulerService.CallScheduleRequest request10 = new ANAgentCallSchedulerService.CallScheduleRequest();
    request10.subject = 'Test Case 10: Strategic Planning Session';
    request10.startDate = '2025-01-22';
    request10.startTime = '07:00 AM';
    request10.durationMinutes = 180;
    request10.description = 'Comprehensive strategic planning session covering Q1 objectives, resource allocation, and team development. Please come prepared with your department updates and budget proposals.';
    request10.organizerEmail = 'anahvi@salesforce.com';
    request10.participantEmails = 'brian.floyd@salesforce.com,executive@salesforce.com';
    request10.priority = 'High';
    request10.location = 'Virtual';
    request10.requestId = 'TEST-010-STRATEGIC';
    
    ANAgentCallSchedulerService.CallScheduleResponse response10 = ANAgentCallSchedulerService.scheduleCall(request10);
    System.debug('Test 10 Result: ' + (response10.success ? '✅ SUCCESS' : '❌ FAILED'));
    System.debug('Message: ' + response10.message);
    if (response10.success) {
        System.debug('Call ID: ' + response10.callId + ', Event ID: ' + response10.eventId);
    }
} catch (Exception e) {
    System.debug('❌ Test 10 Exception: ' + e.getMessage());
}

System.debug('=== ALL TEST CASES COMPLETED ===');
System.debug('Check the debug logs for detailed results of each test case.'); 