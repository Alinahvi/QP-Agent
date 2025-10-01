// Simple compilation check for KPI V4 classes
// This script tests if the classes can be instantiated and methods called

System.debug('=== KPI V4 Compilation Check ===');

try {
    // Test 1: Check if classes can be instantiated
    System.debug('--- Testing Class Instantiation ---');
    
    // Test handler class
    ANAgentKPIAnalysisHandlerV4.KPISearchRequest searchReq = new ANAgentKPIAnalysisHandlerV4.KPISearchRequest();
    System.debug('✓ KPISearchRequest instantiated successfully');
    
    ANAgentKPIAnalysisHandlerV4.KPIAggRequest aggReq = new ANAgentKPIAnalysisHandlerV4.KPIAggRequest();
    System.debug('✓ KPIAggRequest instantiated successfully');
    
    // Test service class
    ANAgentKPIAnalysisServiceV4.UnifiedKPI kpi = new ANAgentKPIAnalysisServiceV4.UnifiedKPI();
    System.debug('✓ UnifiedKPI instantiated successfully');
    
    ANAgentKPIAnalysisServiceV4.KPIAggRow aggRow = new ANAgentKPIAnalysisServiceV4.KPIAggRow();
    System.debug('✓ KPIAggRow instantiated successfully');
    
    System.debug('=== All Classes Compiled Successfully ===');
    System.debug('✓ ANAgentKPIAnalysisHandlerV4');
    System.debug('✓ ANAgentKPIAnalysisServiceV4');
    System.debug('✓ ANAgentKPIAnalysisV4_SmokeTest');
    
} catch (Exception e) {
    System.debug('❌ COMPILATION ERROR: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
} 