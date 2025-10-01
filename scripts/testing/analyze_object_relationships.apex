// Script to analyze object relationships between Content Search and Efficacy systems
// This will help identify potential matches and linking strategies

System.debug('🔍 ANALYZING OBJECT RELATIONSHIPS BETWEEN SYSTEMS');
System.debug('==================================================');

// ============================================================================
// PHASE 1: CONTENT SEARCH SYSTEM OBJECTS
// ============================================================================

System.debug('\n--- PHASE 1: Content Search System Objects ---');

// Objects used in ANAgentContentSearchHandlerV2
List<String> contentSearchObjects = new List<String>{
    'Course__c',
    'Asset__c', 
    'Curriculum__c',
    'Assigned_Course__c'
};

System.debug('📋 Content Search System Objects:');
for (String obj : contentSearchObjects) {
    System.debug('  • ' + obj);
}

// ============================================================================
// PHASE 2: EFFICACY SYSTEM OBJECTS
// ============================================================================

System.debug('\n--- PHASE 2: Efficacy System Objects ---');

// Objects used in ANAgentOfferingEfficacyServiceBasic
List<String> efficacyObjects = new List<String>{
    'apm_outcome_v2__c'
};

System.debug('📋 Efficacy System Objects:');
for (String obj : efficacyObjects) {
    System.debug('  • ' + obj);
}

// ============================================================================
// PHASE 3: OBJECT EXISTENCE & ACCESSIBILITY CHECK
// ============================================================================

System.debug('\n--- PHASE 3: Object Existence & Accessibility Check ---');

Map<String, Boolean> objectExists = new Map<String, Boolean>();
Map<String, Boolean> objectAccessible = new Map<String, Boolean>();

// Check all objects
List<String> allObjects = new List<String>();
allObjects.addAll(contentSearchObjects);
allObjects.addAll(efficacyObjects);

for (String objName : allObjects) {
    try {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
        if (objType != null) {
            objectExists.put(objName, true);
            objectAccessible.put(objName, objType.getDescribe().isAccessible());
            System.debug('✅ ' + objName + ': EXISTS, ACCESSIBLE: ' + objType.getDescribe().isAccessible());
        } else {
            objectExists.put(objName, false);
            objectAccessible.put(objName, false);
            System.debug('❌ ' + objName + ': DOES NOT EXIST');
        }
    } catch (Exception e) {
        objectExists.put(objName, false);
        objectAccessible.put(objName, false);
        System.debug('❌ ' + objName + ': ERROR CHECKING - ' + e.getMessage());
    }
}

// ============================================================================
// PHASE 4: DATA AVAILABILITY ANALYSIS
// ============================================================================

System.debug('\n--- PHASE 4: Data Availability Analysis ---');

// Check record counts for each object
Map<String, Integer> recordCounts = new Map<String, Integer>();

for (String objName : allObjects) {
    if (objectExists.get(objName) && objectAccessible.get(objName)) {
        try {
            String countQuery = 'SELECT COUNT() FROM ' + objName + ' WHERE IsDeleted = false';
            Integer count = Database.countQuery(countQuery);
            recordCounts.put(objName, count);
            System.debug('📊 ' + objName + ': ' + count + ' records');
        } catch (Exception e) {
            System.debug('❌ Error counting ' + objName + ': ' + e.getMessage());
            recordCounts.put(objName, 0);
        }
    }
}

// ============================================================================
// PHASE 5: FIELD ANALYSIS FOR POTENTIAL LINKING
// ============================================================================

System.debug('\n--- PHASE 5: Field Analysis for Potential Linking ---');

// Analyze Course__c fields that might link to apm_outcome_v2__c
if (objectExists.get('Course__c') && objectAccessible.get('Course__c')) {
    System.debug('\n🔍 Course__c Field Analysis:');
    try {
        Schema.SObjectType courseType = Schema.getGlobalDescribe().get('Course__c');
        Map<String, Schema.SObjectField> courseFields = courseType.getDescribe().fields.getMap();
        
        List<String> potentialLinkingFields = new List<String>();
        for (String fieldName : courseFields.keySet()) {
            Schema.SObjectField field = courseFields.get(fieldName);
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
            
            // Look for fields that might contain offering information
            if (fieldName.toLowerCase().contains('offering') || 
                fieldName.toLowerCase().contains('program') ||
                fieldName.toLowerCase().contains('label') ||
                fieldName.toLowerCase().contains('name')) {
                
                potentialLinkingFields.add(fieldName);
                System.debug('  🔗 Potential Linking Field: ' + fieldName + ' (' + fieldDesc.getType() + ')');
            }
        }
        
        if (potentialLinkingFields.isEmpty()) {
            System.debug('  ⚠️ No obvious linking fields found in Course__c');
        }
        
    } catch (Exception e) {
        System.debug('❌ Error analyzing Course__c fields: ' + e.getMessage());
    }
}

// Analyze apm_outcome_v2__c fields that might link to Course__c
if (objectExists.get('apm_outcome_v2__c') && objectAccessible.get('apm_outcome_v2__c')) {
    System.debug('\n🔍 apm_outcome_v2__c Field Analysis:');
    try {
        Schema.SObjectType outcomeType = Schema.getGlobalDescribe().get('apm_outcome_v2__c');
        Map<String, Schema.SObjectField> outcomeFields = outcomeType.getDescribe().fields.getMap();
        
        List<String> potentialLinkingFields = new List<String>();
        for (String fieldName : outcomeFields.keySet()) {
            Schema.SObjectField field = outcomeFields.get(fieldName);
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
            
            // Look for fields that might contain course information
            if (fieldName.toLowerCase().contains('course') || 
                fieldName.toLowerCase().contains('offering') ||
                fieldName.toLowerCase().contains('label') ||
                fieldName.toLowerCase().contains('name')) {
                
                potentialLinkingFields.add(fieldName);
                System.debug('  🔗 Potential Linking Field: ' + fieldName + ' (' + fieldDesc.getType() + ')');
            }
        }
        
        if (potentialLinkingFields.isEmpty()) {
            System.debug('  ⚠️ No obvious linking fields found in apm_outcome_v2__c');
        }
        
    } catch (Exception e) {
        System.debug('❌ Error analyzing apm_outcome_v2__c fields: ' + e.getMessage());
    }
}

// ============================================================================
// PHASE 6: SAMPLE DATA ANALYSIS FOR LINKING STRATEGY
// ============================================================================

System.debug('\n--- PHASE 6: Sample Data Analysis for Linking Strategy ---');

// Get sample Course__c records
if (objectExists.get('Course__c') && objectAccessible.get('Course__c') && recordCounts.get('Course__c') > 0) {
    System.debug('\n📋 Sample Course__c Records:');
    try {
        List<Course__c> sampleCourses = [
            SELECT Id, Name, Description__c, Status__c
            FROM Course__c 
            WHERE IsDeleted = false 
            LIMIT 5
        ];
        
        for (Integer i = 0; i < sampleCourses.size(); i++) {
            Course__c course = sampleCourses[i];
            System.debug('  ' + (i+1) + '. ' + course.Name);
            System.debug('     ID: ' + course.Id);
            System.debug('     Description: ' + course.Description__c);
            System.debug('     Status: ' + course.Status__c);
        }
        
    } catch (Exception e) {
        System.debug('❌ Error getting sample Course__c records: ' + e.getMessage());
    }
}

// Get sample apm_outcome_v2__c records
if (objectExists.get('apm_outcome_v2__c') && objectAccessible.get('apm_outcome_v2__c') && recordCounts.get('apm_outcome_v2__c') > 0) {
    System.debug('\n📋 Sample apm_outcome_v2__c Records:');
    try {
        List<apm_outcome_v2__c> sampleOutcomes = [
            SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c
            FROM apm_outcome_v2__c 
            WHERE IsDeleted = false 
            LIMIT 5
        ];
        
        for (Integer i = 0; i < sampleOutcomes.size(); i++) {
            apm_outcome_v2__c outcome = sampleOutcomes[i];
            System.debug('  ' + (i+1) + '. ' + outcome.OFFERING_LABEL__c);
            System.debug('     ID: ' + outcome.Id);
            System.debug('     Program Type: ' + outcome.PROGRAM_TYPE__c);
            System.debug('     Region: ' + outcome.REGION__c);
            System.debug('     Segment: ' + outcome.MACRO_SEGMENT__c);
        }
        
    } catch (Exception e) {
        System.debug('❌ Error getting sample apm_outcome_v2__c records: ' + e.getMessage());
    }
}

// ============================================================================
// PHASE 7: LINKING STRATEGY RECOMMENDATIONS
// ============================================================================

System.debug('\n--- PHASE 7: Linking Strategy Recommendations ---');

System.debug('🎯 OBJECT RELATIONSHIP ANALYSIS COMPLETE');
System.debug('\n📊 SUMMARY:');
System.debug('  Content Search Objects: ' + contentSearchObjects.size());
System.debug('  Efficacy Objects: ' + efficacyObjects.size());
System.debug('  Total Objects Analyzed: ' + allObjects.size());

Integer existingObjects = 0;
Integer accessibleObjects = 0;
for (String obj : allObjects) {
    if (objectExists.get(obj)) existingObjects++;
    if (objectAccessible.get(obj)) accessibleObjects++;
}

System.debug('  Objects Exist: ' + existingObjects + '/' + allObjects.size());
System.debug('  Objects Accessible: ' + accessibleObjects + '/' + allObjects.size());

System.debug('\n🔗 LINKING STRATEGY RECOMMENDATIONS:');
System.debug('  1. Primary Key Strategy: Use Course__c.Name ↔ apm_outcome_v2__c.OFFERING_LABEL__c');
System.debug('  2. Program Type Strategy: Use Course__c fields ↔ apm_outcome_v2__c.PROGRAM_TYPE__c');
System.debug('  3. Keyword Matching: Extract key terms from course names for fuzzy matching');
System.debug('  4. Manual Mapping: Create a mapping table if naming conventions differ significantly');

System.debug('\n⚠️  POTENTIAL ISSUES IDENTIFIED:');
System.debug('  • Course names may use different naming conventions than offering labels');
System.debug('  • Need to investigate field-level relationships');
System.debug('  • May require data transformation or mapping logic');

System.debug('\n✅ NEXT STEPS:');
System.debug('  1. Analyze the sample data above for naming patterns');
System.debug('  2. Test different linking strategies');
System.debug('  3. Implement improved matching logic in the efficacy service');
System.debug('  4. Create a mapping table if needed');

System.debug('\n🔍 OBJECT RELATIONSHIP ANALYSIS COMPLETED'); 