// Test Open Pipe Analysis Handler Integration
// This script tests the handler class which acts as the entry point for the GenAI Planner

System.debug('=== OPEN PIPE ANALYSIS HANDLER INTEGRATION TEST ===');

// Test 1: Handler with TOP_PRODUCTS analysis type
System.debug('=== TEST 1: HANDLER TOP_PRODUCTS ANALYSIS ===');
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest handlerRequest1 = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
handlerRequest1.analysisType = 'TOP_PRODUCTS';
handlerRequest1.operatingUnit = 'AMER ICE';
handlerRequest1.generateCSV = false;

System.debug('Handler Request: ' + handlerRequest1);
List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> handlerResponses1 = 
    ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{handlerRequest1});

if (!handlerResponses1.isEmpty()) {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse handlerResponse1 = handlerResponses1[0];
    System.debug('Handler Response Success: ' + handlerResponse1.success);
    System.debug('Handler Response Message: ' + handlerResponse1.message);
    System.debug('Handler Total Records: ' + handlerResponse1.totalRecords);
    System.debug('Handler Detailed Results: ' + handlerResponse1.detailedResults);
} else {
    System.debug('❌ No handler response received');
}

// Test 2: Handler with TOP_CUSTOMERS analysis type
System.debug('=== TEST 2: HANDLER TOP_CUSTOMERS ANALYSIS ===');
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest handlerRequest2 = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
handlerRequest2.analysisType = 'TOP_CUSTOMERS';
handlerRequest2.operatingUnit = 'AMER ICE';
handlerRequest2.generateCSV = true;

System.debug('Handler Request: ' + handlerRequest2);
List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> handlerResponses2 = 
    ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{handlerRequest2});

if (!handlerResponses2.isEmpty()) {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse handlerResponse2 = handlerResponses2[0];
    System.debug('Handler Response Success: ' + handlerResponse2.success);
    System.debug('Handler Response Message: ' + handlerResponse2.message);
    System.debug('Handler Total Records: ' + handlerResponse2.totalRecords);
    System.debug('Handler Detailed Results: ' + handlerResponse2.detailedResults);
    System.debug('Handler CSV Data Length: ' + (handlerResponse2.csvData != null ? String.valueOf(handlerResponse2.csvData.length()) : 'NULL'));
} else {
    System.debug('❌ No handler response received');
}

// Test 3: Handler with STAGNATION_ANALYSIS
System.debug('=== TEST 3: HANDLER STAGNATION_ANALYSIS ===');
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest handlerRequest3 = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
handlerRequest3.analysisType = 'STAGNATION_ANALYSIS';
handlerRequest3.operatingUnit = 'AMER ICE';
handlerRequest3.stageFilter = 'Stage 1';

System.debug('Handler Request: ' + handlerRequest3);
List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> handlerResponses3 = 
    ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{handlerRequest3});

if (!handlerResponses3.isEmpty()) {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse handlerResponse3 = handlerResponses3[0];
    System.debug('Handler Response Success: ' + handlerResponse3.success);
    System.debug('Handler Response Message: ' + handlerResponse3.message);
    System.debug('Handler Total Records: ' + handlerResponse3.totalRecords);
    System.debug('Handler Detailed Results: ' + handlerResponse3.detailedResults);
} else {
    System.debug('❌ No handler response received');
}

// Test 4: Handler with SKILL_RECOMMENDATIONS
System.debug('=== TEST 4: HANDLER SKILL_RECOMMENDATIONS ===');
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest handlerRequest4 = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
handlerRequest4.analysisType = 'SKILL_RECOMMENDATIONS';
handlerRequest4.operatingUnit = 'AMER ICE';
handlerRequest4.industry = 'Technology';

System.debug('Handler Request: ' + handlerRequest4);
List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> handlerResponses4 = 
    ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{handlerRequest4});

if (!handlerResponses4.isEmpty()) {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse handlerResponse4 = handlerResponses4[0];
    System.debug('Handler Response Success: ' + handlerResponse4.success);
    System.debug('Handler Response Message: ' + handlerResponse4.message);
    System.debug('Handler Total Records: ' + handlerResponse4.totalRecords);
    System.debug('Handler Detailed Results: ' + handlerResponse4.detailedResults);
} else {
    System.debug('❌ No handler response received');
}

// Test 5: Error handling - Invalid analysis type
System.debug('=== TEST 5: HANDLER ERROR HANDLING ===');
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest handlerRequest5 = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
handlerRequest5.analysisType = 'INVALID_TYPE';
handlerRequest5.operatingUnit = 'AMER ICE';

System.debug('Handler Request: ' + handlerRequest5);
List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> handlerResponses5 = 
    ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{handlerRequest5});

if (!handlerResponses5.isEmpty()) {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse handlerResponse5 = handlerResponses5[0];
    System.debug('Handler Response Success: ' + handlerResponse5.success);
    System.debug('Handler Response Message: ' + handlerResponse5.message);
    System.debug('Handler Total Records: ' + handlerResponse5.totalRecords);
} else {
    System.debug('❌ No handler response received');
}

System.debug('=== HANDLER INTEGRATION TEST COMPLETE ==='); 