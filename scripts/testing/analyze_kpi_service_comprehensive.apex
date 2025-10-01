// Comprehensive Analysis of ANAgentKPIAnalysisService and Handler
System.debug('=== COMPREHENSIVE ANALYSIS OF ANAgentKPIAnalysisService ===');

// 1. Get the service class details
try {
    List<ApexClass> serviceClasses = [SELECT Id, Name, Body, CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name 
                                     FROM ApexClass WHERE Name = 'ANAgentKPIAnalysisService' LIMIT 1];
    
    if (!serviceClasses.isEmpty()) {
        ApexClass serviceClass = serviceClasses[0];
        System.debug('✅ ANAgentKPIAnalysisService found');
        System.debug('Created: ' + serviceClass.CreatedDate);
        System.debug('Last Modified: ' + serviceClass.LastModifiedDate);
        System.debug('Created By: ' + serviceClass.CreatedBy.Name);
        System.debug('Last Modified By: ' + serviceClass.LastModifiedBy.Name);
        
        String classBody = serviceClass.Body;
        System.debug('Class Size: ' + classBody.length() + ' characters');
        
        // Analyze method count
        Pattern methodPattern = Pattern.compile('(public|private|global)\\s+(static\\s+)?(void|String|Integer|Boolean|List<.*>|.*Response|.*Request)\\s+\\w+\\s*\\(');
        Matcher methodMatcher = methodPattern.matcher(classBody);
        Integer methodCount = 0;
        while (methodMatcher.find()) {
            methodCount++;
        }
        System.debug('Method Count: ' + methodCount);
        
        // Check for GROWTH_FACTORS handling
        if (classBody.contains('GROWTH_FACTORS')) {
            System.debug('✅ GROWTH_FACTORS handling found');
        } else {
            System.debug('❌ GROWTH_FACTORS handling NOT found');
        }
        
        // Check for ACTIONABLE__c field usage
        if (classBody.contains('ACTIONABLE__c')) {
            System.debug('✅ ACTIONABLE__c field usage found');
        } else {
            System.debug('❌ ACTIONABLE__c field usage NOT found');
        }
        
        // Check for SOQL queries
        Pattern soqlPattern = Pattern.compile('(?i)SELECT\\s+.*?FROM\\s+AGENT_OU_PIPELINE_V2__c');
        Matcher soqlMatcher = soqlPattern.matcher(classBody);
        Integer soqlCount = 0;
        while (soqlMatcher.find()) {
            soqlCount++;
        }
        System.debug('SOQL Query Count: ' + soqlCount);
        
        // Check for error handling
        if (classBody.contains('try') && classBody.contains('catch')) {
            System.debug('✅ Error handling found');
        } else {
            System.debug('❌ No error handling found');
        }
        
        // Check for test coverage
        List<ApexClass> testClasses = [SELECT Name FROM ApexClass WHERE Name LIKE '%ANAgentKPIAnalysisService%Test%'];
        System.debug('Test Classes: ' + testClasses.size());
        for (ApexClass testClass : testClasses) {
            System.debug('  - ' + testClass.Name);
        }
        
    } else {
        System.debug('❌ ANAgentKPIAnalysisService not found');
    }
} catch (Exception e) {
    System.debug('Error analyzing service: ' + e.getMessage());
}

// 2. Get the handler class details
System.debug('\n=== ANALYZING ANAgentKPIAnalysisHandler ===');
try {
    List<ApexClass> handlerClasses = [SELECT Id, Name, Body, CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name 
                                     FROM ApexClass WHERE Name = 'ANAgentKPIAnalysisHandler' LIMIT 1];
    
    if (!handlerClasses.isEmpty()) {
        ApexClass handlerClass = handlerClasses[0];
        System.debug('✅ ANAgentKPIAnalysisHandler found');
        System.debug('Created: ' + handlerClass.CreatedDate);
        System.debug('Last Modified: ' + handlerClass.LastModifiedDate);
        System.debug('Created By: ' + handlerClass.CreatedBy.Name);
        System.debug('Last Modified By: ' + handlerClass.LastModifiedBy.Name);
        
        String classBody = handlerClass.Body;
        System.debug('Class Size: ' + classBody.length() + ' characters');
        
        // Check for invocable methods
        if (classBody.contains('@InvocableMethod')) {
            System.debug('✅ Invocable methods found');
        } else {
            System.debug('❌ No invocable methods found');
        }
        
        // Check for GROWTH_FACTORS support
        if (classBody.contains('GROWTH_FACTORS')) {
            System.debug('✅ GROWTH_FACTORS support found');
        } else {
            System.debug('❌ GROWTH_FACTORS support NOT found');
        }
        
        // Check for test coverage
        List<ApexClass> testClasses = [SELECT Name FROM ApexClass WHERE Name LIKE '%ANAgentKPIAnalysisHandler%Test%'];
        System.debug('Test Classes: ' + testClasses.size());
        for (ApexClass testClass : testClasses) {
            System.debug('  - ' + testClass.Name);
        }
        
    } else {
        System.debug('❌ ANAgentKPIAnalysisHandler not found');
    }
} catch (Exception e) {
    System.debug('Error analyzing handler: ' + e.getMessage());
}

// 3. Analyze data model usage
System.debug('\n=== ANALYZING DATA MODEL USAGE ===');
try {
    // Check what fields are being used in SOQL queries
    List<AGENT_OU_PIPELINE_V2__c> sampleRecords = [
        SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, DEFINITION__c, DESCRIPTION__c, ACTIONABLE__c, 
               RECOMMENDED_ACTION__c, ACTION_LINK__c, CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c, 
               CQ_ACV__c, CQ_PG__c, COVERAGE__c, RAMP_STATUS__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c = 'AMER ACC' 
        LIMIT 1
    ];
    
    if (!sampleRecords.isEmpty()) {
        System.debug('✅ Data model accessible');
        AGENT_OU_PIPELINE_V2__c sample = sampleRecords[0];
        System.debug('Sample record fields:');
        System.debug('  - EMP_ID__c: ' + sample.EMP_ID__c);
        System.debug('  - FULL_NAME__c: ' + sample.FULL_NAME__c);
        System.debug('  - OU_NAME__c: ' + sample.OU_NAME__c);
        System.debug('  - DEFINITION__c: ' + sample.DEFINITION__c);
        System.debug('  - ACTIONABLE__c: ' + sample.ACTIONABLE__c);
        System.debug('  - CQ_CUSTOMER_MEETING__c: ' + sample.CQ_CUSTOMER_MEETING__c);
    } else {
        System.debug('❌ No sample records found');
    }
} catch (Exception e) {
    System.debug('Error analyzing data model: ' + e.getMessage());
}

// 4. Check for related classes and dependencies
System.debug('\n=== ANALYZING DEPENDENCIES ===');
try {
    // Check for related service classes
    List<ApexClass> relatedClasses = [SELECT Name FROM ApexClass WHERE Name LIKE '%KPIAnalysis%' ORDER BY Name];
    System.debug('Related KPI Analysis Classes:');
    for (ApexClass cls : relatedClasses) {
        System.debug('  - ' + cls.Name);
    }
    
    // Check for utility classes
    List<ApexClass> utilityClasses = [SELECT Name FROM ApexClass WHERE Name LIKE '%KPI%' AND Name LIKE '%Util%'];
    System.debug('KPI Utility Classes: ' + utilityClasses.size());
    for (ApexClass cls : utilityClasses) {
        System.debug('  - ' + cls.Name);
    }
    
} catch (Exception e) {
    System.debug('Error analyzing dependencies: ' + e.getMessage());
}
