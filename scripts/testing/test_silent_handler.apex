// Test to verify the handler is completely silent - no user-facing messages
System.debug('=== TESTING SILENT HANDLER ===');

try {
    // Create a request
    ANAgentConversationLoggingHandler.Request req = new ANAgentConversationLoggingHandler.Request();
    req.userId = '0051234567890SILENT';
    req.userName = 'Silent Test User';
    req.utterance = 'This is a silent test utterance';
    req.agentResponse = 'This is a silent test response';
    
    System.debug('Calling silent handler...');
    
    // Call the handler
    List<ANAgentConversationLoggingHandler.Response> responses = 
        ANAgentConversationLoggingHandler.logConversation(new List<ANAgentConversationLoggingHandler.Request>{req});
    
    // Check the response message
    String responseMessage = responses[0].message;
    System.debug('Handler response message: "' + responseMessage + '"');
    
    if (String.isBlank(responseMessage)) {
        System.debug('✅ SUCCESS: Handler returns empty message - completely silent!');
        System.debug('✅ No user-facing confirmations or error messages');
        System.debug('✅ This is the expected behavior for silent logging');
    } else {
        System.debug('❌ FAILURE: Handler still returns message: "' + responseMessage + '"');
        System.debug('❌ This violates the silent logging requirement');
    }
    
    // Verify the conversation was still logged despite silent response
    List<Agent_Feedback_data_structure__c> logs = [
        SELECT Id, Name, Conversation_Time__c, User_Id__c, Agent_Response__c
        FROM Agent_Feedback_data_structure__c 
        WHERE User_Id__c = '0051234567890SILENT'
        ORDER BY Conversation_Time__c DESC
        LIMIT 1
    ];
    
    if (!logs.isEmpty()) {
        System.debug('✅ SUCCESS: Conversation was logged successfully despite silent response');
        System.debug('  Record ID: ' + logs[0].Id);
        System.debug('  User: ' + logs[0].Name);
        System.debug('  Response: ' + logs[0].Agent_Response__c);
    } else {
        System.debug('❌ FAILURE: Conversation was not logged');
    }
    
    System.debug('=== SILENT HANDLER TEST COMPLETE ===');
    
} catch (Exception e) {
    System.debug('❌ Test failed with error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
