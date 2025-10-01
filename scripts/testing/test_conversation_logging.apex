// Test script for ANAgentConversationLoggingService
// This script tests the conversation logging functionality

System.debug('=== Testing ANAgentConversationLoggingService ===');

try {
    // Test 1: Basic conversation logging
    System.debug('Test 1: Basic conversation logging');
    ANAgentConversationLoggingService.logConversation(
        '0051234567890ABCD', // Sample User ID
        'John Doe',           // User Name
        'What are my KPIs for this quarter?', // User utterance
        'Here are your KPIs for Q4: ACV: $2.5M, Calls: 150, Meetings: 45' // Agent response
    );
    System.debug('✓ Basic logging completed');
    
    // Test 2: Batch conversation logging
    System.debug('Test 2: Batch conversation logging');
    List<ANAgentConversationLoggingService.ConversationData> conversations = new List<ANAgentConversationLoggingService.ConversationData>();
    
    conversations.add(new ANAgentConversationLoggingService.ConversationData(
        '0051234567890ABCD', 'John Doe',
        'Show me top performers', 
        'Top performers this quarter: 1. Sarah Smith ($3.2M ACV), 2. Mike Johnson ($2.8M ACV)'
    ));
    
    conversations.add(new ANAgentConversationLoggingService.ConversationData(
        '0051234567890EFGH', 'Jane Smith',
        'What is my pipeline coverage?', 
        'Your pipeline coverage is 3.2x quota with $8.5M in opportunities'
    ));
    
    ANAgentConversationLoggingService.logConversations(conversations);
    System.debug('✓ Batch logging completed');
    
    // Test 3: Query to verify records were created
    System.debug('Test 3: Verifying records were created');
    List<Agent_Feedback_data_structure__c> logs = [
        SELECT Id, Conversation_Time__c, User_Id__c, Name, Agent_Response__c
        FROM Agent_Feedback_data_structure__c 
        WHERE User_Id__c IN ('0051234567890ABCD', '0051234567890EFGH')
        ORDER BY Conversation_Time__c DESC
        LIMIT 10
    ];
    
    System.debug('Found ' + logs.size() + ' conversation log records');
    for (Agent_Feedback_data_structure__c log : logs) {
        System.debug('Log Record:');
        System.debug('  ID: ' + log.Id);
        System.debug('  Time: ' + log.Conversation_Time__c);
        System.debug('  User ID: ' + log.User_Id__c);
        System.debug('  User Name: ' + log.Name);
        System.debug('  Response: ' + log.Agent_Response__c);
    }
    
    System.debug('=== All tests completed successfully ===');
    
} catch (Exception e) {
    System.debug('❌ Test failed with error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
