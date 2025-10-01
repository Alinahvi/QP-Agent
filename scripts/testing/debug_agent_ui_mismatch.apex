// Debug script to check Agent UI vs Apex mismatch
System.debug('🔍 Debugging Agent UI vs Apex Mismatch...');

// ========================================
// TEST 1: Simulate Agent UI Call for AMER ICE ENTR Products
// ========================================

System.debug('=== TEST 1: Simulate Agent UI Call ===');
System.debug('🔍 This should match what the Agent UI is calling...');

try {
    // Simulate the exact call the Agent UI should make
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'ENTR';
    request.maxResults = 5;
    
    System.debug('🔍 Agent UI Request:');
    System.debug('- Analysis Type: ' + request.analysisType);
    System.debug('- Operating Unit: ' + request.operatingUnit);
    System.debug('- Segment: ' + request.segment);
    System.debug('- Max Results: ' + request.maxResults);
    
    // Call the handler exactly as the Agent UI would
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Agent UI Response:');
        System.debug('- Success: ' + response.success);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Message: ' + response.message);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.success && response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Agent UI call working correctly!');
        } else {
            System.debug('⚠️ Agent UI call returned no results - this explains the UI failure!');
        }
    }
} catch (Exception e) {
    System.debug('❌ Agent UI Call Failed: ' + e.getMessage());
    System.debug('🔍 This explains why the UI shows "no results"!');
}

// ========================================
// TEST 2: Check if Agent UI is calling the right class
// ========================================

System.debug('=== TEST 2: Verify Class Accessibility ===');
try {
    // Check if the handler class is accessible
    System.debug('🔍 Checking ANAgentOpenPipeAnalysisHandler accessibility...');
    
    // Try to instantiate the class
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest testRequest = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    System.debug('✅ Handler class is accessible');
    
    // Check if the method exists
    System.debug('🔍 Checking analyzeOpenPipe method...');
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest> testList = new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>();
    testList.add(testRequest);
    
    // This will fail if the method doesn't exist, but we'll catch it
    try {
        List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> testResponses = 
            ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(testList);
        System.debug('✅ analyzeOpenPipe method exists and is accessible');
    } catch (Exception methodError) {
        System.debug('❌ analyzeOpenPipe method error: ' + methodError.getMessage());
    }
    
} catch (Exception e) {
    System.debug('❌ Class accessibility check failed: ' + e.getMessage());
}

// ========================================
// TEST 3: Check Permission Set Assignment
// ========================================

System.debug('=== TEST 3: Check Permission Set ===');
try {
    // Check if the current user has access to the handler
    System.debug('🔍 Current user permissions check...');
    
    // Try to query the permission set
    String query = 'SELECT Id, Name FROM PermissionSetAssignment ' +
                   'WHERE AssigneeId = \'' + UserInfo.getUserId() + '\' ' +
                   'AND PermissionSet.Name LIKE \'%AN_Agents%\'';
    
    List<PermissionSetAssignment> assignments = Database.query(query);
    System.debug('🔍 Permission Set Assignments: ' + assignments.size());
    for (PermissionSetAssignment assignment : assignments) {
        System.debug('- Permission Set: ' + assignment.PermissionSet.Name);
    }
    
} catch (Exception e) {
    System.debug('❌ Permission check failed: ' + e.getMessage());
}

System.debug('🎯 Agent UI Mismatch Debug Complete!');
System.debug('📊 This should reveal why the Agent UI is not working despite Apex being fixed!'); 