// Find the service layer that ANAgentKPIAnalysisHandler uses
System.debug('=== FINDING SERVICE LAYER FOR ANAgentKPIAnalysisHandler ===');

// Check what classes are available
try {
    // Try to find the service by looking at the handler's dependencies
    System.debug('Checking ANAgentKPIAnalysisHandler class...');
    
    // Get the class metadata
    List<ApexClass> classes = [SELECT Id, Name, Body FROM ApexClass WHERE Name = 'ANAgentKPIAnalysisHandler' LIMIT 1];
    
    if (!classes.isEmpty()) {
        System.debug('Found ANAgentKPIAnalysisHandler class');
        String classBody = classes[0].Body;
        
        // Look for service class references
        if (classBody.contains('ANAgentKPIAnalysisService')) {
            System.debug('✅ ANAgentKPIAnalysisHandler uses ANAgentKPIAnalysisService');
        } else {
            System.debug('❌ ANAgentKPIAnalysisHandler does not reference ANAgentKPIAnalysisService');
        }
        
        // Look for other service references
        if (classBody.contains('Service')) {
            System.debug('Found service references in handler');
            // Extract service class names
            Pattern servicePattern = Pattern.compile('(\\w+Service)');
            Matcher matcher = servicePattern.matcher(classBody);
            while (matcher.find()) {
                System.debug('  - Service reference: ' + matcher.group(1));
            }
        }
        
        // Look for method calls that might indicate the service
        if (classBody.contains('analyzeKPIs')) {
            System.debug('Found analyzeKPIs method calls');
        }
        
        // Look for SOQL queries
        if (classBody.contains('SELECT')) {
            System.debug('Found SOQL queries in handler');
        }
        
    } else {
        System.debug('❌ ANAgentKPIAnalysisHandler class not found');
    }
    
} catch (Exception e) {
    System.debug('Error checking handler: ' + e.getMessage());
}

// Also check what service classes exist
System.debug('\n=== CHECKING AVAILABLE SERVICE CLASSES ===');
try {
    List<ApexClass> serviceClasses = [SELECT Name FROM ApexClass WHERE Name LIKE '%KPIAnalysis%Service%' ORDER BY Name];
    System.debug('Available KPI Analysis Service classes:');
    for (ApexClass cls : serviceClasses) {
        System.debug('  - ' + cls.Name);
    }
} catch (Exception e) {
    System.debug('Error checking service classes: ' + e.getMessage());
}

// Check for any service classes that might be used
System.debug('\n=== CHECKING ALL SERVICE CLASSES ===');
try {
    List<ApexClass> allServiceClasses = [SELECT Name FROM ApexClass WHERE Name LIKE '%Service%' AND Name LIKE '%Agent%' ORDER BY Name];
    System.debug('Available Agent Service classes:');
    for (ApexClass cls : allServiceClasses) {
        System.debug('  - ' + cls.Name);
    }
} catch (Exception e) {
    System.debug('Error checking all service classes: ' + e.getMessage());
}
