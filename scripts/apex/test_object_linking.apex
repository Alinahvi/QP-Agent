// Test script to verify object linking between Course__c and apm_outcome_v2__c
// Run this in Developer Console or via SFDX

System.debug('=== TESTING OBJECT LINKING ===');

// Test 1: Check if we can find courses that match offering labels
System.debug('\n--- Test 1: Course to Offering Label Mapping ---');

try {
    // Get some sample offering labels from apm_outcome_v2__c
    List<apm_outcome_v2__c> sampleOutcomes = [
        SELECT OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c 
        FROM apm_outcome_v2__c 
        WHERE OFFERING_LABEL__c != null 
        LIMIT 5
    ];
    
    System.debug('Sample Offering Labels:');
    for (apm_outcome_v2__c outcome : sampleOutcomes) {
        System.debug('Offering Label: ' + outcome.OFFERING_LABEL__c);
        System.debug('  Program Type: ' + outcome.PROGRAM_TYPE__c);
        System.debug('  Region: ' + outcome.REGION__c);
    }
    
    // Try to find matching courses
    if (!sampleOutcomes.isEmpty()) {
        String sampleOfferingLabel = sampleOutcomes[0].OFFERING_LABEL__c;
        System.debug('\nSearching for courses matching: ' + sampleOfferingLabel);
        
        // Extract course name from offering label (assuming format like "FY25 Fast Start - RKO - Einstein 1")
        String[] parts = sampleOfferingLabel.split(' - ');
        String potentialCourseName = '';
        if (parts.length >= 3) {
            potentialCourseName = parts[2]; // "Einstein 1"
        } else if (parts.length >= 2) {
            potentialCourseName = parts[1]; // "RKO"
        }
        
        System.debug('Potential Course Name: ' + potentialCourseName);
        
        // Search for courses with similar names
        List<Course__c> matchingCourses = [
            SELECT Id, Name, Description__c, Status__c 
            FROM Course__c 
            WHERE Name LIKE '%' + potentialCourseName + '%'
            LIMIT 5
        ];
        
        System.debug('Matching Courses Found: ' + matchingCourses.size());
        for (Course__c course : matchingCourses) {
            System.debug('Course: ' + course.Name + ' (ID: ' + course.Id + ')');
        }
        
        // Also try a broader search
        List<Course__c> broaderMatches = [
            SELECT Id, Name, Description__c, Status__c 
            FROM Course__c 
            WHERE Name LIKE '%Einstein%' OR Name LIKE '%Fast%' OR Name LIKE '%Start%'
            LIMIT 10
        ];
        
        System.debug('\nBroader Course Matches: ' + broaderMatches.size());
        for (Course__c course : broaderMatches) {
            System.debug('Course: ' + course.Name + ' (ID: ' + course.Id + ')');
        }
    }
    
} catch (Exception e) {
    System.debug('Error in Test 1: ' + e.getMessage());
}

// Test 2: Check if we can find offering outcomes for specific courses
System.debug('\n--- Test 2: Course to Outcome Mapping ---');

try {
    // Get some sample courses
    List<Course__c> sampleCourses = [
        SELECT Id, Name, Description__c, Status__c 
        FROM Course__c 
        WHERE Status__c = 'Active'
        LIMIT 5
    ];
    
    System.debug('Sample Courses:');
    for (Course__c course : sampleCourses) {
        System.debug('Course: ' + course.Name + ' (ID: ' + course.Id + ')');
        
        // Try to find offering outcomes for this course
        List<apm_outcome_v2__c> courseOutcomes = [
            SELECT OFFERING_LABEL__c, MEAN_EFFECTIVENESS__c, CALCULATED_LIFT__c, TOTAL_INFLUENCED_ACV__c
            FROM apm_outcome_v2__c 
            WHERE OFFERING_LABEL__c LIKE '%' + course.Name + '%'
            LIMIT 5
        ];
        
        System.debug('  Outcomes found: ' + courseOutcomes.size());
        for (apm_outcome_v2__c outcome : courseOutcomes) {
            System.debug('    Offering: ' + outcome.OFFERING_LABEL__c);
            System.debug('    Effectiveness: ' + outcome.MEAN_EFFECTIVENESS__c);
            System.debug('    Lift: ' + outcome.CALCULATED_LIFT__c);
        }
    }
    
} catch (Exception e) {
    System.debug('Error in Test 2: ' + e.getMessage());
}

// Test 3: Check the data structure and suggest linking strategy
System.debug('\n--- Test 3: Data Structure Analysis ---');

try {
    // Get sample data from both objects
    List<Course__c> courses = [
        SELECT Id, Name, Description__c, Status__c, CreatedDate
        FROM Course__c 
        WHERE Status__c = 'Active'
        ORDER BY CreatedDate DESC
        LIMIT 3
    ];
    
    List<apm_outcome_v2__c> outcomes = [
        SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MEAN_EFFECTIVENESS__c
        FROM apm_outcome_v2__c 
        WHERE OFFERING_LABEL__c != null
        ORDER BY CreatedDate DESC
        LIMIT 3
    ];
    
    System.debug('Course Structure:');
    for (Course__c course : courses) {
        System.debug('  ID: ' + course.Id);
        System.debug('  Name: ' + course.Name);
        System.debug('  Status: ' + course.Status__c);
        System.debug('  Created: ' + course.CreatedDate);
    }
    
    System.debug('\nOutcome Structure:');
    for (apm_outcome_v2__c outcome : outcomes) {
        System.debug('  ID: ' + outcome.Id);
        System.debug('  Offering Label: ' + outcome.OFFERING_LABEL__c);
        System.debug('  Program Type: ' + outcome.PROGRAM_TYPE__c);
        System.debug('  Region: ' + outcome.REGION__c);
        System.debug('  Effectiveness: ' + outcome.MEAN_EFFECTIVENESS__c);
    }
    
    // Suggest linking strategy
    System.debug('\n=== LINKING STRATEGY RECOMMENDATION ===');
    System.debug('Based on the data structure, here are the linking options:');
    System.debug('1. EXACT MATCH: Course__c.Name = apm_outcome_v2__c.OFFERING_LABEL__c');
    System.debug('2. PARTIAL MATCH: Course__c.Name LIKE %keyword% where keyword is extracted from OFFERING_LABEL__c');
    System.debug('3. FUZZY MATCH: Use similarity algorithms to find closest matches');
    System.debug('4. MANUAL MAPPING: Create a custom object to store the relationships');
    
} catch (Exception e) {
    System.debug('Error in Test 3: ' + e.getMessage());
}

System.debug('\n=== OBJECT LINKING TEST COMPLETED ==='); 