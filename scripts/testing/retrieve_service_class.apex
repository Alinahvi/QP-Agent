// Get the ANAgentKPIAnalysisService class content
System.debug('=== RETRIEVING ANAgentKPIAnalysisService CLASS ===');

try {
    List<ApexClass> serviceClasses = [SELECT Id, Name, Body FROM ApexClass WHERE Name = 'ANAgentKPIAnalysisService' LIMIT 1];
    
    if (!serviceClasses.isEmpty()) {
        ApexClass serviceClass = serviceClasses[0];
        System.debug('✅ ANAgentKPIAnalysisService found');
        System.debug('Class ID: ' + serviceClass.Id);
        System.debug('Class Body Length: ' + serviceClass.Body.length());
        
        // Write to a file for analysis
        String classBody = serviceClass.Body;
        
        // Show first 2000 characters to understand structure
        System.debug('First 2000 characters:');
        System.debug(classBody.substring(0, Math.min(2000, classBody.length())));
        
        // Show method signatures
        System.debug('\n=== METHOD SIGNATURES ===');
        Pattern methodPattern = Pattern.compile('(public|private|global)\\s+(static\\s+)?(void|String|Integer|Boolean|List<.*>|.*Response|.*Request)\\s+(\\w+)\\s*\\([^)]*\\)');
        Matcher methodMatcher = methodPattern.matcher(classBody);
        while (methodMatcher.find()) {
            System.debug('Method: ' + methodMatcher.group(4));
        }
        
    } else {
        System.debug('❌ ANAgentKPIAnalysisService not found');
    }
} catch (Exception e) {
    System.debug('Error retrieving service: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
