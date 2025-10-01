// Test the handler class
System.debug('=== Testing ANAgentConversationLoggingHandler ===');

try {
    // Create a request
    ANAgentConversationLoggingHandler.Request req = new ANAgentConversationLoggingHandler.Request();
    req.userId = '0051234567890TEST';
    req.userName = 'Test User';
    req.utterance = 'Test utterance from handler';
    req.agentResponse = 'Test response from handler';
    
    // Call the handler
    List<ANAgentConversationLoggingHandler.Response> responses = 
        ANAgentConversationLoggingHandler.logConversation(new List<ANAgentConversationLoggingHandler.Request>{req});
    
    System.debug('Handler response: ' + responses[0].message);
    System.debug('✓ Handler test completed successfully');
    
} catch (Exception e) {
    System.debug('❌ Handler test failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
