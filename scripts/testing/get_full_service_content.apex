// Get the full ANAgentKPIAnalysisService class content
System.debug('=== RETRIEVING FULL ANAgentKPIAnalysisService CLASS ===');

try {
    List<ApexClass> serviceClasses = [SELECT Id, Name, Body FROM ApexClass WHERE Name = 'ANAgentKPIAnalysisService' LIMIT 1];
    
    if (!serviceClasses.isEmpty()) {
        ApexClass serviceClass = serviceClasses[0];
        String classBody = serviceClass.Body;
        
        // Write the full class to a file
        System.debug('Writing full class content to file...');
        
        // Create a file with the class content
        ContentVersion cv = new ContentVersion();
        cv.Title = 'ANAgentKPIAnalysisService.cls';
        cv.PathOnClient = 'ANAgentKPIAnalysisService.cls';
        cv.VersionData = Blob.valueOf(classBody);
        insert cv;
        
        System.debug('✅ Class content written to ContentVersion: ' + cv.Id);
        System.debug('Class size: ' + classBody.length() + ' characters');
        
        // Also get the handler
        List<ApexClass> handlerClasses = [SELECT Id, Name, Body FROM ApexClass WHERE Name = 'ANAgentKPIAnalysisHandler' LIMIT 1];
        if (!handlerClasses.isEmpty()) {
            ApexClass handlerClass = handlerClasses[0];
            String handlerBody = handlerClass.Body;
            
            ContentVersion cv2 = new ContentVersion();
            cv2.Title = 'ANAgentKPIAnalysisHandler.cls';
            cv2.PathOnClient = 'ANAgentKPIAnalysisHandler.cls';
            cv2.VersionData = Blob.valueOf(handlerBody);
            insert cv2;
            
            System.debug('✅ Handler content written to ContentVersion: ' + cv2.Id);
            System.debug('Handler size: ' + handlerBody.length() + ' characters');
        }
        
    } else {
        System.debug('❌ ANAgentKPIAnalysisService not found');
    }
} catch (Exception e) {
    System.debug('Error retrieving service: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
