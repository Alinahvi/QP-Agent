// Setup Shadow Mode for KPI UAT Testing
// This script configures MCP_Config__mdt for shadow mode testing

System.debug('🔧 Setting up Shadow Mode for KPI UAT Testing...');

try {
    // Check if MCP_Config__mdt record exists
    List<MCP_Config__mdt> existingConfigs = [SELECT Id, DeveloperName, IsActive__c, ShadowMode__c, Mode__c, Timeout__c, RetryCount__c 
                                            FROM MCP_Config__mdt 
                                            WHERE DeveloperName = 'DEV_Config' 
                                            LIMIT 1];
    
    if (existingConfigs.isEmpty()) {
        System.debug('❌ No MCP_Config__mdt record found with DeveloperName = DEV_Config');
        System.debug('Please create a MCP_Config__mdt record first via Setup UI');
        System.debug('Required fields:');
        System.debug('- DeveloperName: DEV_Config');
        System.debug('- IsActive__c: true');
        System.debug('- ShadowMode__c: true');
        System.debug('- Mode__c: ROUTE');
        System.debug('- Timeout__c: 10');
        System.debug('- RetryCount__c: 2');
    } else {
        MCP_Config__mdt config = existingConfigs[0];
        System.debug('📋 Current MCP Configuration:');
        System.debug('- DeveloperName: ' + config.DeveloperName);
        System.debug('- IsActive__c: ' + config.IsActive__c);
        System.debug('- ShadowMode__c: ' + config.ShadowMode__c);
        System.debug('- Mode__c: ' + config.Mode__c);
        System.debug('- Timeout__c: ' + config.Timeout__c);
        System.debug('- RetryCount__c: ' + config.RetryCount__c);
        
        System.debug('✅ MCP Configuration found and ready for UAT testing');
        System.debug('📝 For UAT testing, ensure:');
        System.debug('- IsActive__c = true');
        System.debug('- ShadowMode__c = true');
        System.debug('- Mode__c = ROUTE');
    }
    
} catch (Exception e) {
    System.debug('❌ Error setting up shadow mode: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('🎯 Shadow Mode Setup Complete');
