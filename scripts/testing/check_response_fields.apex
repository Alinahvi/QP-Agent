// Check what fields are available in the response
System.debug('=== CHECKING RESPONSE FIELDS ===');

try {
    // Get the service class and check response structure
    List<ApexClass> serviceClasses = [SELECT Id, Name, Body FROM ApexClass WHERE Name = 'ANAgentKPIAnalysisService' LIMIT 1];
    
    if (!serviceClasses.isEmpty()) {
        String classBody = serviceClasses[0].Body;
        
        // Look for KPIAnalysisResponse class
        if (classBody.contains('class KPIAnalysisResponse')) {
            System.debug('✅ KPIAnalysisResponse class found');
            
            // Extract the response class content
            Pattern responsePattern = Pattern.compile('class KPIAnalysisResponse[^{]*\\{([^}]+(?:\\{[^}]*\\}[^}]*)*)\\}');
            Matcher responseMatcher = responsePattern.matcher(classBody);
            if (responseMatcher.find()) {
                String responseBody = responseMatcher.group(1);
                System.debug('Response class fields:');
                
                // Look for field declarations
                Pattern fieldPattern = Pattern.compile('public\\s+(String|Integer|Boolean|Decimal|List<.*>)\\s+(\\w+);');
                Matcher fieldMatcher = fieldPattern.matcher(responseBody);
                while (fieldMatcher.find()) {
                    System.debug('  - ' + fieldMatcher.group(2) + ' (' + fieldMatcher.group(1) + ')');
                }
            }
        } else {
            System.debug('❌ KPIAnalysisResponse class not found');
        }
        
        // Look for KPIAnalysisRequest class
        if (classBody.contains('class KPIAnalysisRequest')) {
            System.debug('✅ KPIAnalysisRequest class found');
        } else {
            System.debug('❌ KPIAnalysisRequest class not found');
        }
        
    } else {
        System.debug('❌ ANAgentKPIAnalysisService not found');
    }
} catch (Exception e) {
    System.debug('Error checking response fields: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
