/**
 * Script to analyze OU name consistency between Agent_Open_Pipe__c and Learner_Profile__c objects
 * 
 * This script will:
 * 1. Query both objects using the LEARNER_PROFILE_ID__c as the primary key
 * 2. Compare OU_NAME__c (Agent_Open_Pipe__c) vs OU_Name__c (Learner_Profile__c)
 * 3. Identify mismatches, null values, and data quality issues
 * 4. Generate a comprehensive report
 */

System.debug('=== OU Name Consistency Analysis ===');
System.debug('Comparing Agent_Open_Pipe__c.OU_NAME__c vs Learner_Profile__c.OU_Name__c');
System.debug('Using LEARNER_PROFILE_ID__c as the primary key for joining');
System.debug('=====================================');

try {
    // Step 1: Get a sample of records from Agent_Open_Pipe__c that have a LEARNER_PROFILE_ID__c
    System.debug('--- Step 1: Querying Agent_Open_Pipe__c records with LEARNER_PROFILE_ID__c (LIMITED SAMPLE) ---');
    
    // First, get a count to understand the data size
    Integer totalAgentRecords = [SELECT COUNT() FROM Agent_Open_Pipe__c WHERE LEARNER_PROFILE_ID__c != null];
    System.debug('Total Agent_Open_Pipe__c records with LEARNER_PROFILE_ID__c: ' + totalAgentRecords);
    
    // Query a sample of records (limit to 1000 for analysis)
    List<Agent_Open_Pipe__c> agentRecords = [
        SELECT Id, LEARNER_PROFILE_ID__c, OU_NAME__c, FULL_NAME__c, EMP_ID__c
        FROM Agent_Open_Pipe__c 
        WHERE LEARNER_PROFILE_ID__c != null
        ORDER BY LEARNER_PROFILE_ID__c
        LIMIT 1000
    ];
    
    System.debug('Found ' + agentRecords.size() + ' Agent_Open_Pipe__c records with LEARNER_PROFILE_ID__c (sample of ' + totalAgentRecords + ' total)');
    
    if (agentRecords.isEmpty()) {
        System.debug('❌ No Agent_Open_Pipe__c records found with LEARNER_PROFILE_ID__c');
        return;
    }
    
    // Additional analysis: Get unique OU values from the sample
    System.debug('--- Sample OU Distribution in Agent_Open_Pipe__c ---');
    Set<String> agentOUs = new Set<String>();
    for (Agent_Open_Pipe__c record : agentRecords) {
        if (record.OU_NAME__c != null) {
            agentOUs.add(record.OU_NAME__c);
        }
    }
    System.debug('Unique OUs in sample: ' + agentOUs.size());
    for (String ou : agentOUs) {
        System.debug('  - "' + ou + '"');
    }
    
    // Step 2: Extract learner profile IDs and query Learner_Profile__c
    Set<Id> learnerProfileIds = new Set<Id>();
    for (Agent_Open_Pipe__c record : agentRecords) {
        learnerProfileIds.add(record.LEARNER_PROFILE_ID__c);
    }
    
    System.debug('--- Step 2: Querying Learner_Profile__c records ---');
    
    List<Learner_Profile__c> learnerRecords = [
        SELECT Id, OU_Name__c, Name, Primary_Email__c
        FROM Learner_Profile__c 
        WHERE Id IN :learnerProfileIds
        ORDER BY Id
    ];
    
    System.debug('Found ' + learnerRecords.size() + ' matching Learner_Profile__c records');
    
    // Step 3: Create maps for easy lookup
    Map<Id, Agent_Open_Pipe__c> agentMap = new Map<Id, Agent_Open_Pipe__c>();
    Map<Id, Learner_Profile__c> learnerMap = new Map<Id, Learner_Profile__c>();
    
    for (Agent_Open_Pipe__c record : agentRecords) {
        agentMap.put(record.LEARNER_PROFILE_ID__c, record);
    }
    
    for (Learner_Profile__c record : learnerRecords) {
        learnerMap.put(record.Id, record);
    }
    
    // Step 4: Analyze consistency
    System.debug('--- Step 3: Analyzing OU Name Consistency ---');
    
    Integer totalRecords = 0;
    Integer exactMatches = 0;
    Integer mismatches = 0;
    Integer agentNullOU = 0;
    Integer learnerNullOU = 0;
    Integer bothNullOU = 0;
    Integer missingLearnerProfile = 0;
    
    Map<String, Integer> mismatchDetails = new Map<String, Integer>();
    List<String> mismatchExamples = new List<String>();
    
    for (Agent_Open_Pipe__c agentRecord : agentRecords) {
        totalRecords++;
        
        Learner_Profile__c learnerRecord = learnerMap.get(agentRecord.LEARNER_PROFILE_ID__c);
        
        if (learnerRecord == null) {
            missingLearnerProfile++;
            System.debug('⚠️  Missing Learner Profile for Agent ID: ' + agentRecord.Id + 
                        ', LEARNER_PROFILE_ID__c: ' + agentRecord.LEARNER_PROFILE_ID__c);
            continue;
        }
        
        String agentOU = agentRecord.OU_NAME__c;
        String learnerOU = learnerRecord.OU_Name__c;
        
        // Handle null values
        if (agentOU == null && learnerOU == null) {
            bothNullOU++;
        } else if (agentOU == null) {
            agentNullOU++;
        } else if (learnerOU == null) {
            learnerNullOU++;
        } else {
            // Both have values - compare them
            if (agentOU.equals(learnerOU)) {
                exactMatches++;
            } else {
                mismatches++;
                
                // Track mismatch patterns
                String mismatchKey = agentOU + ' → ' + learnerOU;
                Integer count = mismatchDetails.get(mismatchKey);
                mismatchDetails.put(mismatchKey, count == null ? 1 : count + 1);
                
                // Store examples for detailed analysis
                if (mismatchExamples.size() < 10) {
                    mismatchExamples.add('Agent: "' + agentOU + '" vs Learner: "' + learnerOU + 
                                       '" (Agent ID: ' + agentRecord.Id + ', Learner ID: ' + learnerRecord.Id + ')');
                }
            }
        }
    }
    
    // Step 5: Generate comprehensive report
    System.debug('=== CONSISTENCY ANALYSIS RESULTS ===');
    System.debug('Total Agent_Open_Pipe__c records analyzed: ' + totalRecords);
    System.debug('Matching Learner_Profile__c records found: ' + learnerRecords.size());
    System.debug('Missing Learner_Profile__c records: ' + missingLearnerProfile);
    System.debug('');
    
    System.debug('=== OU NAME COMPARISON RESULTS ===');
    System.debug('Exact matches: ' + exactMatches + ' (' + 
                (totalRecords > 0 ? Math.round((exactMatches * 100.0) / totalRecords) : 0) + '%)');
    System.debug('Mismatches: ' + mismatches + ' (' + 
                (totalRecords > 0 ? Math.round((mismatches * 100.0) / totalRecords) : 0) + '%)');
    System.debug('Agent OU is null: ' + agentNullOU + ' (' + 
                (totalRecords > 0 ? Math.round((agentNullOU * 100.0) / totalRecords) : 0) + '%)');
    System.debug('Learner OU is null: ' + learnerNullOU + ' (' + 
                (totalRecords > 0 ? Math.round((learnerNullOU * 100.0) / totalRecords) : 0) + '%)');
    System.debug('Both OUs are null: ' + bothNullOU + ' (' + 
                (totalRecords > 0 ? Math.round((bothNullOU * 100.0) / totalRecords) : 0) + '%)');
    System.debug('');
    
    // Step 6: Detailed mismatch analysis
    if (!mismatchDetails.isEmpty()) {
        System.debug('=== TOP MISMATCH PATTERNS ===');
        List<String> sortedMismatches = new List<String>();
        for (String key : mismatchDetails.keySet()) {
            sortedMismatches.add(mismatchDetails.get(key) + ' occurrences: ' + key);
        }
        sortedMismatches.sort();
        
        for (Integer i = sortedMismatches.size() - 1; i >= 0 && i >= sortedMismatches.size() - 10; i--) {
            System.debug(sortedMismatches[i]);
        }
        System.debug('');
    }
    
    // Step 7: Example mismatches
    if (!mismatchExamples.isEmpty()) {
        System.debug('=== SAMPLE MISMATCH EXAMPLES ===');
        for (String example : mismatchExamples) {
            System.debug(example);
        }
        System.debug('');
    }
    
    // Step 8: Data quality recommendations
    System.debug('=== DATA QUALITY RECOMMENDATIONS ===');
    
    if (mismatches > 0) {
        System.debug('🔧 MISMATCHES FOUND:');
        System.debug('   - Review and standardize OU naming conventions');
        System.debug('   - Consider implementing data validation rules');
        System.debug('   - Investigate data source differences');
    }
    
    if (agentNullOU > 0 || learnerNullOU > 0) {
        System.debug('🔧 NULL VALUES FOUND:');
        System.debug('   - ' + agentNullOU + ' Agent_Open_Pipe__c records have null OU_NAME__c');
        System.debug('   - ' + learnerNullOU + ' Learner_Profile__c records have null OU_Name__c');
        System.debug('   - Consider making OU fields required or implementing default values');
    }
    
    if (missingLearnerProfile > 0) {
        System.debug('🔧 MISSING LEARNER PROFILES:');
        System.debug('   - ' + missingLearnerProfile + ' Agent_Open_Pipe__c records reference non-existent Learner_Profile__c records');
        System.debug('   - Review data integrity and foreign key relationships');
    }
    
    // Step 9: Summary
    System.debug('=== SUMMARY ===');
    if (exactMatches == totalRecords - missingLearnerProfile) {
        System.debug('✅ PERFECT CONSISTENCY: All matching records have identical OU names');
    } else if (mismatches == 0) {
        System.debug('✅ NO MISMATCHES: All non-null OU names match perfectly');
    } else {
        System.debug('⚠️  INCONSISTENCIES DETECTED: ' + mismatches + ' mismatches found');
        System.debug('   - Consistency rate: ' + 
                    Math.round((exactMatches * 100.0) / (totalRecords - missingLearnerProfile)) + '%');
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR during analysis: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
