// Create MCP_Config__mdt record for UAT testing
// This script creates the required MCP configuration record

System.debug('🔧 Creating MCP_Config__mdt record for UAT testing...');

try {
    // Check if record already exists
    List<MCP_Config__mdt> existingConfigs = [SELECT Id, DeveloperName FROM MCP_Config__mdt WHERE DeveloperName = 'DEV_Config' LIMIT 1];
    
    if (!existingConfigs.isEmpty()) {
        System.debug('✅ MCP_Config__mdt record already exists: ' + existingConfigs[0].Id);
        System.debug('📋 Current configuration:');
        MCP_Config__mdt config = [SELECT DeveloperName, IsActive__c, ShadowMode__c, Mode__c, Timeout__c, RetryCount__c 
                                  FROM MCP_Config__mdt 
                                  WHERE Id = :existingConfigs[0].Id];
        System.debug('- DeveloperName: ' + config.DeveloperName);
        System.debug('- IsActive__c: ' + config.IsActive__c);
        System.debug('- ShadowMode__c: ' + config.ShadowMode__c);
        System.debug('- Mode__c: ' + config.Mode__c);
        System.debug('- Timeout__c: ' + config.Timeout__c);
        System.debug('- RetryCount__c: ' + config.RetryCount__c);
    } else {
        System.debug('❌ MCP_Config__mdt record does not exist');
        System.debug('📝 Please create the record manually via Setup UI:');
        System.debug('1. Go to Setup → Custom Metadata Types → MCP Configuration');
        System.debug('2. Click "Manage Records"');
        System.debug('3. Click "New"');
        System.debug('4. Fill in the following values:');
        System.debug('   - DeveloperName: DEV_Config');
        System.debug('   - Master Label: DEV Config');
        System.debug('   - Is Active: ✓ (checked)');
        System.debug('   - Shadow Mode: ✓ (checked)');
        System.debug('   - Mode: ROUTE');
        System.debug('   - Timeout (seconds): 10');
        System.debug('   - Retry Count: 2');
        System.debug('5. Click "Save"');
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking MCP config: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('🎯 MCP Config Check Complete');
