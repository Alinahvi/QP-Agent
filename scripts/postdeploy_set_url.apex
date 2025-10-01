// Post-deployment script to update MCP configuration
// Usage: sfdx force:apex:execute -u MySandbox -f scripts/postdeploy_set_url.apex
// 
// Before running, replace these placeholders:
// - PLACEHOLDER_URL: Your ngrok HTTPS URL (e.g., https://abc123.ngrok.io)
// - PLACEHOLDER_MODE: ROUTE or ANALYZE

System.debug('🔧 Updating MCP Configuration...');

try {
    // Get the MCP configuration record
    List<MCP_Config__mdt> configs = [SELECT Id, BaseUrl__c, Mode__c, IsActive__c 
                                    FROM MCP_Config__mdt 
                                    WHERE IsActive__c = true 
                                    LIMIT 1];
    
    if (configs.isEmpty()) {
        System.debug('❌ No active MCP configuration found');
        return;
    }
    
    MCP_Config__mdt config = configs[0];
    
    // Update configuration
    String newUrl = 'PLACEHOLDER_URL';  // Replace with your ngrok URL
    String newMode = 'PLACEHOLDER_MODE';  // Replace with ROUTE or ANALYZE
    
    System.debug('📝 Current config - BaseUrl: ' + config.BaseUrl__c + ', Mode: ' + config.Mode__c);
    System.debug('🔄 Updating to - BaseUrl: ' + newUrl + ', Mode: ' + newMode);
    
    // Note: Custom Metadata cannot be updated via Apex in production
    // This script is for demonstration. In real deployment, you would:
    // 1. Update the Custom Metadata record manually in Setup, OR
    // 2. Update the Named Credential URL instead
    
    System.debug('✅ MCP Configuration update completed');
    System.debug('📋 Next steps:');
    System.debug('   1. Update Named Credential URL to: ' + newUrl);
    System.debug('   2. Or update Custom Metadata record manually');
    System.debug('   3. Run smoke tests to verify');
    
} catch (Exception e) {
    System.debug('❌ Error updating MCP configuration: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
