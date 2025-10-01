// Verify Learner Profile Linking in Created Records
System.debug('=== VERIFYING LEARNER PROFILE LINKING ===');

try {
    // Query the recently created test records to verify Learner Profile linking
    System.debug('--- Checking Recent Test Records ---');
    
    // Get the most recent Task records from our tests
    List<Task> recentTasks = [
        SELECT Id, Subject, WhatId, OwnerId, Type, CallType, Priority, Status, Description, ActivityDate
        FROM Task 
        WHERE Subject LIKE '%Test%' 
        AND CreatedDate = TODAY 
        ORDER BY CreatedDate DESC 
        LIMIT 5
    ];
    
    System.debug('Found ' + recentTasks.size() + ' recent test tasks');
    
    for (Task task : recentTasks) {
        System.debug('--- Task: ' + task.Subject + ' ---');
        System.debug('Task ID: ' + task.Id);
        System.debug('WhatId (Learner Profile): ' + task.WhatId);
        System.debug('Type: ' + task.Type);
        System.debug('CallType: ' + task.CallType);
        System.debug('Priority: ' + task.Priority);
        System.debug('Status: ' + task.Status);
        
        // Verify Learner Profile linking
        if (String.isNotBlank(task.WhatId)) {
            System.debug('✅ SUCCESS: Task is linked to Learner Profile: ' + task.WhatId);
            
            // Get the Learner Profile details
            try {
                List<Learner_Profile__c> profiles = [
                    SELECT Id, Name, Primary_Email__c 
                    FROM Learner_Profile__c 
                    WHERE Id = :task.WhatId
                ];
                
                if (!profiles.isEmpty()) {
                    Learner_Profile__c profile = profiles[0];
                    System.debug('Learner Profile Details:');
                    System.debug('  - Name: ' + profile.Name);
                    System.debug('  - Email: ' + profile.Primary_Email__c);
                    System.debug('  - ID: ' + profile.Id);
                }
            } catch (Exception e) {
                System.debug('❌ Error querying Learner Profile: ' + e.getMessage());
            }
        } else {
            System.debug('❌ FAILED: Task is NOT linked to any Learner Profile');
        }
    }
    
    // Get the most recent Event records from our tests
    List<Event> recentEvents = [
        SELECT Id, Subject, WhatId, OwnerId, Type, Location, StartDateTime, EndDateTime, Description
        FROM Event 
        WHERE Subject LIKE '%Test%' 
        AND CreatedDate = TODAY 
        ORDER BY CreatedDate DESC 
        LIMIT 5
    ];
    
    System.debug('Found ' + recentEvents.size() + ' recent test events');
    
    for (Event event : recentEvents) {
        System.debug('--- Event: ' + event.Subject + ' ---');
        System.debug('Event ID: ' + event.Id);
        System.debug('WhatId (Learner Profile): ' + event.WhatId);
        System.debug('Type: ' + event.Type);
        System.debug('Location: ' + event.Location);
        System.debug('Start: ' + event.StartDateTime);
        System.debug('End: ' + event.EndDateTime);
        
        // Verify Learner Profile linking
        if (String.isNotBlank(event.WhatId)) {
            System.debug('✅ SUCCESS: Event is linked to Learner Profile: ' + event.WhatId);
        } else {
            System.debug('❌ FAILED: Event is NOT linked to any Learner Profile');
        }
    }
    
    System.debug('=== VERIFICATION COMPLETED ===');

} catch (Exception e) {
    System.debug('❌ Verification failed with error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 