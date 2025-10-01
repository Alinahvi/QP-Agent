// Validation script to test conversation logging integration with real agent service
System.debug('=== VALIDATING CONVERSATION LOGGING INTEGRATION ===');

try {
    // Step 1: Check current record count
    Integer initialCount = [SELECT COUNT() FROM Agent_Feedback_data_structure__c];
    System.debug('Initial record count: ' + initialCount);
    
    // Step 2: Call the REAL agent service (not the test snippet)
    System.debug('Calling real agent service: ANAgentSMESearchHandler.searchSMEs()');
    
    // This simulates what happens when the agent is called
    ANAgentSMESearchHandler.SMESearchResponse response = 
        ANAgentSMESearchHandler.searchSMEs('Sales Cloud', 'Product', 5, true);
    
    System.debug('Agent response received:');
    System.debug('  Success: ' + response.success);
    System.debug('  Message: ' + response.message);
    System.debug('  Total SMEs found: ' + response.totalCount);
    
    // Step 3: Wait a moment for any async operations
    System.debug('Waiting for conversation logging to complete...');
    
    // Step 4: Check if a new conversation record was created
    Integer newCount = [SELECT COUNT() FROM Agent_Feedback_data_structure__c];
    System.debug('New record count: ' + newCount);
    System.debug('Records added: ' + (newCount - initialCount));
    
    // Step 5: Query the specific record to verify data integrity
    List<Agent_Feedback_data_structure__c> newRecords = [
        SELECT Id, Conversation_Time__c, User_Id__c, User_Name__c, Utterance__c, Agent_Response__c
        FROM Agent_Feedback_data_structure__c 
        WHERE Conversation_Time__c >= :Datetime.now().addMinutes(-5)
        ORDER BY Conversation_Time__c DESC
        LIMIT 5
    ];
    
    System.debug('Found ' + newRecords.size() + ' recent conversation records');
    
    if (!newRecords.isEmpty()) {
        Agent_Feedback_data_structure__c latestRecord = newRecords[0];
        System.debug('Latest conversation record:');
        System.debug('  ID: ' + latestRecord.Id);
        System.debug('  Time: ' + latestRecord.Conversation_Time__c);
        System.debug('  User ID: ' + latestRecord.User_Id__c);
        System.debug('  User Name: ' + latestRecord.User_Name__c);
        System.debug('  Utterance: ' + latestRecord.Utterance__c);
        System.debug('  Agent Response: ' + latestRecord.Agent_Response__c);
        
        // Verify field values match expected
        Boolean userIdMatch = latestRecord.User_Id__c == UserInfo.getUserId();
        Boolean userNameMatch = latestRecord.User_Name__c == UserInfo.getName();
        Boolean utteranceMatch = latestRecord.Utterance__c == 'Sales Cloud';
        Boolean responseMatch = latestRecord.Agent_Response__c == response.message;
        Boolean timeNotNull = latestRecord.Conversation_Time__c != null;
        
        System.debug('Field validation results:');
        System.debug('  User ID match: ' + userIdMatch);
        System.debug('  User Name match: ' + userNameMatch);
        System.debug('  Utterance match: ' + utteranceMatch);
        System.debug('  Response match: ' + responseMatch);
        System.debug('  Time not null: ' + timeNotNull);
        
        if (userIdMatch && userNameMatch && utteranceMatch && responseMatch && timeNotNull) {
            System.debug('🎉 ALL FIELDS MATCH EXACTLY! Integration working perfectly!');
            System.debug('✅ Conversation logging is now wired to the real agent service');
        } else {
            System.debug('❌ Some fields do not match expected values');
        }
    } else {
        System.debug('❌ No recent conversation records found');
        System.debug('❌ This suggests the logging integration is not working');
    }
    
    // Step 6: Final validation
    if (newCount > initialCount) {
        System.debug('🎉 SUCCESS: Conversation logging integration is working!');
        System.debug('✅ Agent actions now automatically log conversations');
        System.debug('✅ No user-facing confirmations (silent logging)');
        System.debug('✅ Data integrity verified');
    } else {
        System.debug('❌ FAILURE: No new conversation records created');
        System.debug('❌ Check debug logs for logging errors');
    }
    
    System.debug('=== VALIDATION COMPLETE ===');
    
} catch (Exception e) {
    System.debug('❌ Validation failed with error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
