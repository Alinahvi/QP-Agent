/**
 * @description Direct query verification of Agent_Consensu__c content
 * Verifies what Data Cloud and Sales Cloud content actually exists
 */
System.debug('=== Verifying Agent_Consensu__c Content Data ===');

// Query 1: Search for Data Cloud content in titles
System.debug('\n--- Query 1: Data Cloud Content in Titles ---');
try {
    List<SObject> dataCloudRecords = [
        SELECT Id, title__c, internalTitle__c, isPublic__c, isPublished__c, 
               createdAt__c, previewLink__c, languagetitle__c, folderInfoname__c,
               creatorDatafirstName__c, creatorDatalastName__c, creatorDataemail__c
        FROM Agent_Consensu__c 
        WHERE title__c LIKE '%Data Cloud%' 
           OR internalTitle__c LIKE '%Data Cloud%'
           OR folderInfoname__c LIKE '%Data Cloud%'
        LIMIT 10
    ];
    
    System.debug('Data Cloud Records Found: ' + dataCloudRecords.size());
    if (!dataCloudRecords.isEmpty()) {
        for (Integer i = 0; i < dataCloudRecords.size(); i++) {
            SObject record = dataCloudRecords[i];
            System.debug('Record ' + (i+1) + ':');
            System.debug('  - Title: ' + record.get('title__c'));
            System.debug('  - Internal Title: ' + record.get('internalTitle__c'));
            System.debug('  - Folder: ' + record.get('folderInfoname__c'));
            System.debug('  - Published: ' + record.get('isPublished__c'));
            System.debug('  - Public: ' + record.get('isPublic__c'));
            System.debug('  - Preview Link: ' + record.get('previewLink__c'));
            System.debug('  - Created: ' + record.get('createdAt__c'));
        }
    } else {
        System.debug('❌ NO Data Cloud content found in the sandbox');
    }
} catch (Exception e) {
    System.debug('❌ Error querying Data Cloud content: ' + e.getMessage());
}

// Query 2: Search for Sales Cloud content in titles
System.debug('\n--- Query 2: Sales Cloud Content in Titles ---');
try {
    List<SObject> salesCloudRecords = [
        SELECT Id, title__c, internalTitle__c, isPublic__c, isPublished__c, 
               createdAt__c, previewLink__c, languagetitle__c, folderInfoname__c,
               creatorDatafirstName__c, creatorDatalastName__c, creatorDataemail__c
        FROM Agent_Consensu__c 
        WHERE title__c LIKE '%Sales Cloud%' 
           OR internalTitle__c LIKE '%Sales Cloud%'
           OR folderInfoname__c LIKE '%Sales Cloud%'
        LIMIT 10
    ];
    
    System.debug('Sales Cloud Records Found: ' + salesCloudRecords.size());
    if (!salesCloudRecords.isEmpty()) {
        for (Integer i = 0; i < salesCloudRecords.size(); i++) {
            SObject record = salesCloudRecords[i];
            System.debug('Record ' + (i+1) + ':');
            System.debug('  - Title: ' + record.get('title__c'));
            System.debug('  - Internal Title: ' + record.get('internalTitle__c'));
            System.debug('  - Folder: ' + record.get('folderInfoname__c'));
            System.debug('  - Published: ' + record.get('isPublished__c'));
            System.debug('  - Public: ' + record.get('isPublic__c'));
            System.debug('  - Preview Link: ' + record.get('previewLink__c'));
            System.debug('  - Created: ' + record.get('createdAt__c'));
        }
    } else {
        System.debug('❌ NO Sales Cloud content found in the sandbox');
    }
} catch (Exception e) {
    System.debug('❌ Error querying Sales Cloud content: ' + e.getMessage());
}

// Query 3: Check what content types actually exist
System.debug('\n--- Query 3: Available Content Types ---');
try {
            List<AggregateResult> folderTypes = [
            SELECT folderInfoname__c, COUNT(Id) recordCount
            FROM Agent_Consensu__c 
            WHERE folderInfoname__c != null
            GROUP BY folderInfoname__c
            ORDER BY COUNT(Id) DESC
            LIMIT 10
        ];
        
        System.debug('Available Folder Types:');
        for (AggregateResult ar : folderTypes) {
            System.debug('  - ' + ar.get('folderInfoname__c') + ': ' + ar.get('expr0') + ' records');
        }
} catch (Exception e) {
    System.debug('❌ Error querying folder types: ' + e.getMessage());
}

// Query 4: Check total record count and sample of what exists
System.debug('\n--- Query 4: Overall Content Summary ---');
try {
    Integer totalRecords = [SELECT COUNT() FROM Agent_Consensu__c];
    System.debug('Total Agent_Consensu__c records: ' + totalRecords);
    
    if (totalRecords > 0) {
        List<SObject> sampleRecords = [
            SELECT Id, title__c, internalTitle__c, folderInfoname__c, isPublished__c, createdAt__c
            FROM Agent_Consensu__c 
            LIMIT 5
        ];
        
        System.debug('Sample Records:');
        for (Integer i = 0; i < sampleRecords.size(); i++) {
            SObject record = sampleRecords[i];
            System.debug('  Sample ' + (i+1) + ':');
            System.debug('    - Title: ' + record.get('title__c'));
            System.debug('    - Folder: ' + record.get('folderInfoname__c'));
            System.debug('    - Published: ' + record.get('isPublished__c'));
        }
    }
} catch (Exception e) {
    System.debug('❌ Error getting content summary: ' + e.getMessage());
}

// Query 5: Check for any content with "Cloud" in the title
System.debug('\n--- Query 5: Any Cloud-Related Content ---');
try {
    List<SObject> cloudRecords = [
        SELECT Id, title__c, internalTitle__c, folderInfoname__c
        FROM Agent_Consensu__c 
        WHERE title__c LIKE '%Cloud%' 
           OR internalTitle__c LIKE '%Cloud%'
           OR folderInfoname__c LIKE '%Cloud%'
        LIMIT 10
    ];
    
    System.debug('Cloud-Related Records Found: ' + cloudRecords.size());
    if (!cloudRecords.isEmpty()) {
        for (Integer i = 0; i < cloudRecords.size(); i++) {
            SObject record = cloudRecords[i];
            System.debug('  Cloud Record ' + (i+1) + ':');
            System.debug('    - Title: ' + record.get('title__c'));
            System.debug('    - Internal Title: ' + record.get('internalTitle__c'));
            System.debug('    - Folder: ' + record.get('folderInfoname__c'));
        }
    } else {
        System.debug('❌ NO Cloud-related content found');
    }
} catch (Exception e) {
    System.debug('❌ Error querying Cloud content: ' + e.getMessage());
}

System.debug('\n=== Content Verification Complete ===');
System.debug('This will confirm whether the UAT test failures are due to missing content or system issues.');
