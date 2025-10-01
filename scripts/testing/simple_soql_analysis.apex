// Simple analysis of current SOQL usage
System.debug('=== SIMPLE SOQL ANALYSIS ===');

try {
    // Get the service class and analyze SOQL patterns
    List<ApexClass> serviceClasses = [SELECT Id, Name, Body FROM ApexClass WHERE Name = 'ANAgentKPIAnalysisService' LIMIT 1];
    
    if (!serviceClasses.isEmpty()) {
        String classBody = serviceClasses[0].Body;
        
        // Check for specific problematic fields
        System.debug('=== CHECKING FOR PROBLEMATIC FIELDS ===');
        if (classBody.contains('ACTIONABLE__c')) {
            System.debug('✅ ACTIONABLE__c referenced in code');
        } else {
            System.debug('❌ ACTIONABLE__c NOT referenced in code');
        }
        
        if (classBody.contains('CQ_CUSTOMER_MEETING__c')) {
            System.debug('✅ CQ_CUSTOMER_MEETING__c referenced in code');
        } else {
            System.debug('❌ CQ_CUSTOMER_MEETING__c NOT referenced in code');
        }
        
        if (classBody.contains('DEFINITION__c')) {
            System.debug('✅ DEFINITION__c referenced in code');
        } else {
            System.debug('❌ DEFINITION__c NOT referenced in code');
        }
        
        // Check for analyzeGrowthFactors method
        if (classBody.contains('analyzeGrowthFactors')) {
            System.debug('✅ analyzeGrowthFactors method found');
        } else {
            System.debug('❌ analyzeGrowthFactors method NOT found');
        }
        
        // Check for GROWTH_FACTORS handling
        if (classBody.contains('GROWTH_FACTORS')) {
            System.debug('✅ GROWTH_FACTORS handling found');
        } else {
            System.debug('❌ GROWTH_FACTORS handling NOT found');
        }
        
        // Count SOQL queries
        Integer soqlCount = 0;
        String[] lines = classBody.split('\n');
        for (String line : lines) {
            if (line.contains('SELECT') && line.contains('FROM AGENT_OU_PIPELINE_V2__c')) {
                soqlCount++;
            }
        }
        System.debug('SOQL queries found: ' + soqlCount);
        
    }
} catch (Exception e) {
    System.debug('Error analyzing SOQL: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
