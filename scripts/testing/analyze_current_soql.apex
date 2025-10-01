// Analyze current SOQL usage in the service
System.debug('=== ANALYZING CURRENT SOQL USAGE ===');

try {
    // Get the service class and analyze SOQL patterns
    List<ApexClass> serviceClasses = [SELECT Id, Name, Body FROM ApexClass WHERE Name = 'ANAgentKPIAnalysisService' LIMIT 1];
    
    if (!serviceClasses.isEmpty()) {
        String classBody = serviceClasses[0].Body;
        
        // Find all SOQL queries
        Pattern soqlPattern = Pattern.compile('(?i)SELECT\\s+([^F]+?)\\s+FROM\\s+AGENT_OU_PIPELINE_V2__c');
        Matcher soqlMatcher = soqlPattern.matcher(classBody);
        
        Set<String> allFields = new Set<String>();
        Integer queryCount = 0;
        
        while (soqlMatcher.find()) {
            queryCount++;
            String selectClause = soqlMatcher.group(1);
            System.debug('Query ' + queryCount + ' SELECT clause: ' + selectClause);
            
            // Extract field names
            String[] fields = selectClause.split(',');
            for (String field : fields) {
                String cleanField = field.trim().replaceAll('\\s+', ' ');
                if (cleanField.contains('__c') || cleanField.contains('Id') || cleanField.contains('Name')) {
                    allFields.add(cleanField);
                }
            }
        }
        
        System.debug('Total SOQL queries found: ' + queryCount);
        System.debug('All fields used in SOQL:');
        for (String field : allFields) {
            System.debug('  - ' + field);
        }
        
        // Check for specific problematic fields
        System.debug('\n=== CHECKING FOR PROBLEMATIC FIELDS ===');
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
            
            // Extract the method content
            Pattern methodPattern = Pattern.compile('(?i)private\\s+static\\s+.*?analyzeGrowthFactors.*?\\{([^}]+(?:\\{[^}]*\\}[^}]*)*)\\}', Pattern.DOTALL);
            Matcher methodMatcher = methodPattern.matcher(classBody);
            if (methodMatcher.find()) {
                String methodBody = methodMatcher.group(1);
                System.debug('analyzeGrowthFactors method body length: ' + methodBody.length());
                
                // Check if it has SOQL
                if (methodBody.contains('SELECT') && methodBody.contains('FROM AGENT_OU_PIPELINE_V2__c')) {
                    System.debug('✅ analyzeGrowthFactors has SOQL query');
                } else {
                    System.debug('❌ analyzeGrowthFactors does NOT have SOQL query');
                }
            }
        } else {
            System.debug('❌ analyzeGrowthFactors method NOT found');
        }
        
    }
} catch (Exception e) {
    System.debug('Error analyzing SOQL: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
