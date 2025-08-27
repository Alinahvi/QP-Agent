// Script to check user permissions for kloving@salesforce.com
System.debug('🔍 CHECKING USER PERMISSIONS FOR kloving@salesforce.com');
System.debug('==================================================');

try {
    // Query the user
    User klovingUser = [SELECT Id, Username, Profile.Name, IsActive 
                        FROM User 
                        WHERE Username = 'kloving@salesforce.com' 
                        LIMIT 1];
    
    System.debug('👤 User Found:');
    System.debug('  ID: ' + klovingUser.Id);
    System.debug('  Username: ' + klovingUser.Username);
    System.debug('  Profile: ' + klovingUser.Profile.Name);
    System.debug('  Is Active: ' + klovingUser.IsActive);
    
    // Check permission set assignments
    List<PermissionSetAssignment> psAssignments = [
        SELECT PermissionSet.Name, PermissionSet.Label, Assignee.Username
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :klovingUser.Id
        ORDER BY PermissionSet.Label
    ];
    
    System.debug('\n📋 Current Permission Set Assignments:');
    if (psAssignments.isEmpty()) {
        System.debug('  ❌ No permission sets assigned');
    } else {
        for (PermissionSetAssignment psa : psAssignments) {
            System.debug('  ✅ ' + psa.PermissionSet.Label + ' (' + psa.PermissionSet.Name + ')');
        }
    }
    
    // Check if they have access to key Apex classes
    System.debug('\n🔍 Testing Access to Key Apex Classes:');
    
    // Test 1: Content Search Handler
    try {
        ANAgentContentSearchHandlerV2 testHandler = new ANAgentContentSearchHandlerV2();
        System.debug('  ✅ ANAgentContentSearchHandlerV2: ACCESS GRANTED');
    } catch (Exception e) {
        System.debug('  ❌ ANAgentContentSearchHandlerV2: ACCESS DENIED - ' + e.getMessage());
    }
    
    // Test 2: APM Nomination Handler
    try {
        ANAgentAPMNominationHandlerV2 testHandler = new ANAgentAPMNominationHandlerV2();
        System.debug('  ✅ ANAgentAPMNominationHandlerV2: ACCESS GRANTED');
    } catch (Exception e) {
        System.debug('  ❌ ANAgentAPMNominationHandlerV2: ACCESS DENIED - ' + e.getMessage());
    }
    
    // Test 3: Offering Efficacy Handler
    try {
        ANAgentOfferingEfficacyHandlerBasic testHandler = new ANAgentOfferingEfficacyHandlerBasic();
        System.debug('  ✅ ANAgentOfferingEfficacyHandlerBasic: ACCESS GRANTED');
    } catch (Exception e) {
        System.debug('  ❌ ANAgentOfferingEfficacyHandlerBasic: ACCESS DENIED - ' + e.getMessage());
    }
    
    // Check object permissions
    System.debug('\n📊 Object Permission Check:');
    
    // Test Course object access
    try {
        List<Course__c> courses = [SELECT Id, Name FROM Course__c LIMIT 1];
        System.debug('  ✅ Course__c: READ ACCESS GRANTED');
    } catch (Exception e) {
        System.debug('  ❌ Course__c: READ ACCESS DENIED - ' + e.getMessage());
    }
    
    // Test apm_nomination object access
    try {
        List<apm_nomination__c> nominations = [SELECT Id, Name FROM apm_nomination__c LIMIT 1];
        System.debug('  ✅ apm_nomination__c: READ ACCESS GRANTED');
    } catch (Exception e) {
        System.debug('  ❌ apm_nomination__c: READ ACCESS DENIED - ' + e.getMessage());
    }
    
    // Test apm_outcome_v2 object access
    try {
        List<apm_outcome_v2__c> outcomes = [SELECT Id, OFFERING_LABEL__c FROM apm_outcome_v2__c LIMIT 1];
        System.debug('  ✅ apm_outcome_v2__c: READ ACCESS GRANTED');
    } catch (Exception e) {
        System.debug('  ❌ apm_outcome_v2__c: READ ACCESS DENIED - ' + e.getMessage());
    }
    
    System.debug('\n🎯 RECOMMENDATION:');
    if (psAssignments.isEmpty()) {
        System.debug('  📝 Assign the "AEAE AN Agents CRUD" permission set to kloving@salesforce.com');
        System.debug('  🔗 Go to: Setup → Users → Permission Set Assignments');
        System.debug('  📋 Select: AEAE AN Agents CRUD');
        System.debug('  👤 Add User: kloving@salesforce.com');
    } else {
        System.debug('  ✅ User already has permission sets assigned');
        System.debug('  🔍 Check if any of the assigned sets provide the required access');
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking user permissions: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 