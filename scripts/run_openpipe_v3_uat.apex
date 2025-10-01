// Open Pipe V3 UAT Runner - Execute comprehensive UAT testing
System.debug('🚀 Starting Open Pipe V3 UAT Runner...');

try {
    // Execute the UAT
    AN_OpenPipeV3_UAT_Runner.UATSummary summary = AN_OpenPipeV3_UAT_Runner.runUAT();
    
    System.debug('🎯 UAT EXECUTION COMPLETE');
    System.debug('=====================================');
    System.debug('📊 Overall Metrics:');
    System.debug('- Total Tests: ' + summary.totalTests);
    System.debug('- Direct Success Rate: ' + summary.directSuccessRate + '%');
    System.debug('- MCP Success Rate: ' + summary.mcpSuccessRate + '%');
    System.debug('- Intent Accuracy: ' + summary.intentAccuracy + '%');
    System.debug('- Args Accuracy: ' + summary.argsAccuracy + '%');
    System.debug('- Result Parity: ' + summary.resultParity + '%');
    System.debug('- Error Rate: ' + summary.errorRate + '%');
    
    System.debug('⚡ Performance Metrics:');
    System.debug('- Direct P95 Latency: ' + summary.directP95Latency + 'ms');
    System.debug('- MCP P95 Latency: ' + summary.mcpP95Latency + 'ms');
    System.debug('- Latency Delta P95: ' + summary.latencyDeltaP95 + 'ms');
    
    System.debug('🎯 Acceptance Criteria:');
    System.debug('- Intent Accuracy ≥ 98%: ' + (summary.intentAccuracy >= 98.0 ? '✅ PASS' : '❌ FAIL'));
    System.debug('- Args Accuracy ≥ 97%: ' + (summary.argsAccuracy >= 97.0 ? '✅ PASS' : '❌ FAIL'));
    System.debug('- Result Parity ≥ 95%: ' + (summary.resultParity >= 95.0 ? '✅ PASS' : '❌ FAIL'));
    System.debug('- Latency Delta ≤ 150ms: ' + (summary.latencyDeltaP95 <= 150 ? '✅ PASS' : '❌ FAIL'));
    System.debug('- Error Rate ≤ 1%: ' + (summary.errorRate <= 1.0 ? '✅ PASS' : '❌ FAIL'));
    
    System.debug('🏆 Overall Status: ' + (summary.meetsAcceptanceCriteria ? '✅ MEETS CRITERIA' : '❌ FAILS CRITERIA'));
    
    if (!summary.topMismatches.isEmpty()) {
        System.debug('⚠️  Top Mismatches:');
        for (String mismatch : summary.topMismatches) {
            System.debug('- ' + mismatch);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ UAT Runner Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('🎯 Open Pipe V3 UAT Complete');
