// Check which Apex classes actually exist in the org
// This will help us see what's available for the permission set

System.debug('=== CHECKING EXISTING APEX CLASSES ===');

// List of classes we're trying to add to the permission set
List<String> targetClasses = new List<String>{
    'ANAgentCrossSellHandler',
    'ANAgentUpsellHandler', 
    'ANAgentRenewalsHandler',
    'ANAgentFuturePipelineAnalysisHandler'
};

System.debug('=== CHECKING TARGET CLASSES ===');
for(String className : targetClasses) {
    try {
        // Try to get the class metadata
        Type t = Type.forName(className);
        if(t != null) {
            System.debug('✅ EXISTS: ' + className);
        } else {
            System.debug('❌ NOT FOUND: ' + className);
        }
    } catch(Exception e) {
        System.debug('❌ ERROR checking ' + className + ': ' + e.getMessage());
    }
}

// Also check some classes that we know exist
List<String> knownClasses = new List<String>{
    'ANAgentAPMNominationHandlerV2',
    'ANAgentContentSearchHandlerV2',
    'ANAgentOfferingEfficacyHandlerBasic'
};

System.debug('=== CHECKING KNOWN EXISTING CLASSES ===');
for(String className : knownClasses) {
    try {
        Type t = Type.forName(className);
        if(t != null) {
            System.debug('✅ EXISTS: ' + className);
        } else {
            System.debug('❌ NOT FOUND: ' + className);
        }
    } catch(Exception e) {
        System.debug('❌ ERROR checking ' + className + ': ' + e.getMessage());
    }
}

System.debug('=== CHECK COMPLETE ===');
