/**
 * @description Test script to verify Content Search field mappings work correctly
 * Tests real SOQL queries against Agent_Consensu__c, Course__c, Asset__c, Curriculum__c
 */
System.debug('=== Content Search Field Mapping Test ===');

// Test 1: Agent_Consensu__c Field Access
System.debug('\n--- Test 1: Agent_Consensu__c Field Access ---');
try {
    String consensusQuery = 'SELECT Id, title__c, internalTitle__c, description__c, isPublic__c, ' +
                          'isPublished__c, createdAt__c, previewLink__c, languageTitle__c, ' +
                          'folderInfoName__c, creatorDatafirstName__c, creatorDatalastName__c, ' +
                          'creatorDataemail__c FROM Agent_Consensu__c LIMIT 5';
    
    List<SObject> consensusRecords = Database.query(consensusQuery);
    System.debug('✅ Agent_Consensu__c query successful: ' + consensusRecords.size() + ' records found');
    
    if (!consensusRecords.isEmpty()) {
        SObject record = consensusRecords[0];
        System.debug('  - title__c: ' + record.get('title__c'));
        System.debug('  - languageTitle__c: ' + record.get('languageTitle__c'));
        System.debug('  - folderInfoName__c: ' + record.get('folderInfoName__c'));
        System.debug('  - previewLink__c: ' + record.get('previewLink__c'));
    }
} catch (Exception e) {
    System.debug('❌ Agent_Consensu__c query failed: ' + e.getMessage());
}

// Test 2: Course__c Field Access
System.debug('\n--- Test 2: Course__c Field Access ---');
try {
    String courseQuery = 'SELECT Id, Name, Description__c, Status__c, CreatedDate, LastModifiedDate, ' +
                        'Share_URL__c, Primary_Category__c FROM Course__c LIMIT 5';
    
    List<SObject> courseRecords = Database.query(courseQuery);
    System.debug('✅ Course__c query successful: ' + courseRecords.size() + ' records found');
    
    if (!courseRecords.isEmpty()) {
        SObject record = courseRecords[0];
        System.debug('  - Name: ' + record.get('Name'));
        System.debug('  - Share_URL__c: ' + record.get('Share_URL__c'));
        System.debug('  - Primary_Category__c: ' + record.get('Primary_Category__c'));
        System.debug('  - Status__c: ' + record.get('Status__c'));
    }
} catch (Exception e) {
    System.debug('❌ Course__c query failed: ' + e.getMessage());
}

// Test 3: Asset__c Field Access
System.debug('\n--- Test 3: Asset__c Field Access ---');
try {
    String assetQuery = 'SELECT Id, Name, Description__c, Status__c, CreatedDate, LastModifiedDate, ' +
                       'Share_URL__c, RecordType.DeveloperName FROM Asset__c LIMIT 5';
    
    List<SObject> assetRecords = Database.query(assetQuery);
    System.debug('✅ Asset__c query successful: ' + assetRecords.size() + ' records found');
    
    if (!assetRecords.isEmpty()) {
        SObject record = assetRecords[0];
        System.debug('  - Name: ' + record.get('Name'));
        System.debug('  - Share_URL__c: ' + record.get('Share_URL__c'));
        System.debug('  - RecordType: ' + record.getSObject('RecordType').get('DeveloperName'));
        System.debug('  - Status__c: ' + record.get('Status__c'));
    }
} catch (Exception e) {
    System.debug('❌ Asset__c query failed: ' + e.getMessage());
}

// Test 4: Curriculum__c Field Access
System.debug('\n--- Test 4: Curriculum__c Field Access ---');
try {
    String curriculumQuery = 'SELECT Id, Name, Description__c, Status__c, CreatedDate, LastModifiedDate, ' +
                            'Share_URL__c FROM Curriculum__c LIMIT 5';
    
    List<SObject> curriculumRecords = Database.query(curriculumQuery);
    System.debug('✅ Curriculum__c query successful: ' + curriculumRecords.size() + ' records found');
    
    if (!curriculumRecords.isEmpty()) {
        SObject record = curriculumRecords[0];
        System.debug('  - Name: ' + record.get('Name'));
        System.debug('  - Share_URL__c: ' + record.get('Share_URL__c'));
        System.debug('  - Status__c: ' + record.get('Status__c'));
    }
} catch (Exception e) {
    System.debug('❌ Curriculum__c query failed: ' + e.getMessage());
}

// Test 5: Content Search Handler Test
System.debug('\n--- Test 5: Content Search Handler Test ---');
try {
    // Test Consensus search
    ANAgentConsensusContentSearchHandler.ContentSearchRequest consensusRequest = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    consensusRequest.userUtterance = 'consensus data cloud';
    consensusRequest.limitN = 5;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> consensusResponses = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{consensusRequest});
    
    System.debug('✅ Consensus search successful: ' + consensusResponses.size() + ' responses');
    if (!consensusResponses.isEmpty()) {
        System.debug('  - Message length: ' + consensusResponses[0].message.length() + ' characters');
        System.debug('  - Results count: ' + (consensusResponses[0].results != null ? consensusResponses[0].results.size() : 0));
    }
    
    // Test ACT search
    ANAgentConsensusContentSearchHandler.ContentSearchRequest actRequest = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    actRequest.userUtterance = 'sales cloud training';
    actRequest.limitN = 5;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> actResponses = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{actRequest});
    
    System.debug('✅ ACT search successful: ' + actResponses.size() + ' responses');
    if (!actResponses.isEmpty()) {
        System.debug('  - Message length: ' + actResponses[0].message.length() + ' characters');
        System.debug('  - Results count: ' + (actResponses[0].results != null ? actResponses[0].results.size() : 0));
    }
    
} catch (Exception e) {
    System.debug('❌ Content Search Handler test failed: ' + e.getMessage());
    System.debug('  Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== Field Mapping Test Complete ===');
