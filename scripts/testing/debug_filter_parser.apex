System.debug('=== Debugging Filter Parser ===');

try {
    // Test the failing filters
    String[] testFilters = new String[]{
        'country="US"',
        'tenure_months >= 60',
        'acv < 5000 AND tenure_months >= 6'
    };
    
    for (String filter : testFilters) {
        System.debug('Testing filter: ' + filter);
        
        ANAgentFilterParser.ParsedFilter result = ANAgentFilterParser.parse(filter);
        
        System.debug('Result valid: ' + result.isValid);
        System.debug('Result SOQL: ' + result.soqlWhere);
        System.debug('Result error: ' + result.errorMessage);
        System.debug('Result fragments: ' + result.fragments);
        
        if (result.fragments != null) {
            for (Integer i = 0; i < result.fragments.size(); i++) {
                ANAgentFilterParser.FilterFragment frag = result.fragments[i];
                System.debug('Fragment ' + i + ': ' + frag.fieldName + ' ' + frag.operator + ' ' + frag.value);
            }
        }
        System.debug('---');
    }
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
} 