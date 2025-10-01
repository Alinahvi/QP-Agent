// Check what methods are available in the existing service
System.debug('=== CHECKING EXISTING SERVICE METHODS ===');

try {
    // Get the service class and check its methods
    List<ApexClass> serviceClasses = [SELECT Id, Name, Body FROM ApexClass WHERE Name = 'ANAgentKPIAnalysisService' LIMIT 1];
    
    if (!serviceClasses.isEmpty()) {
        String classBody = serviceClasses[0].Body;
        
        // Look for public methods
        Pattern methodPattern = Pattern.compile('public\\s+(static\\s+)?(void|String|Integer|Boolean|List<.*>|.*Response|.*Request)\\s+(\\w+)\\s*\\([^)]*\\)');
        Matcher methodMatcher = methodPattern.matcher(classBody);
        
        System.debug('Public methods found:');
        while (methodMatcher.find()) {
            System.debug('  - ' + methodMatcher.group(3));
        }
        
        // Check for analyzeKPIs method specifically
        if (classBody.contains('analyzeKPIs')) {
            System.debug('✅ analyzeKPIs method found');
            
            // Look for the method signature
            Pattern analyzePattern = Pattern.compile('public\\s+(static\\s+)?.*?analyzeKPIs\\s*\\([^)]*\\)');
            Matcher analyzeMatcher = analyzePattern.matcher(classBody);
            while (analyzeMatcher.find()) {
                System.debug('analyzeKPIs signature: ' + analyzeMatcher.group(0));
            }
        } else {
            System.debug('❌ analyzeKPIs method not found');
        }
        
        // Check for invocable methods
        if (classBody.contains('@InvocableMethod')) {
            System.debug('✅ Invocable methods found');
        } else {
            System.debug('❌ No invocable methods found');
        }
        
    } else {
        System.debug('❌ ANAgentKPIAnalysisService not found');
    }
} catch (Exception e) {
    System.debug('Error checking service methods: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
