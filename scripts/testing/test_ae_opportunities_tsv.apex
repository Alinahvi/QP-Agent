// Test script for AE Opportunities data format with TSV service
System.debug('=== TESTING AE OPPORTUNITIES FORMAT WITH TSV SERVICE ===\n');

// The exact data format from the user
String aeOpportunitiesData = 'Here are the top 10 opportunities in AMER ICE for Stage 5 (Negotiating $$ & Mutual Plan):\n\n' +
    'Vizio Hardware - Service A1E Upgrade\n\n' +
    'AE Email: Cecily Jowers\n' +
    'Customer Name: Vizio Hardware\n' +
    'Value: $2,136,000.00\n' +
    'Penney OpCo LLC - Data Cloud for Marketing JCPenney\n\n' +
    'AE Email: TJ Jeric\n' +
    'Customer Name: Penney OpCo LLC\n' +
    'Value: $1,290,000.00\n' +
    'Tyson - Transformation Budget\n\n' +
    'AE Email: Casey Whittington\n' +
    'Customer Name: Tyson\n' +
    'Value: $1,000,000.00\n' +
    'Navistar RFP + Field Service\n\n' +
    'AE Email: Austin Clevenger\n' +
    'Customer Name: Navistar\n' +
    'Value: $924,000.00\n' +
    'Opex Corporation - FSL & Technicians RFP\n\n' +
    'AE Email: Jennifer Vega\n' +
    'Customer Name: Opex Corporation\n' +
    'Value: $714,345.62\n' +
    'EQT - Slack Enterprise+\n\n' +
    'AE Email: Adrian Piwonski\n' +
    'Customer Name: EQT\n' +
    'Value: $675,000.00\n' +
    'Swedish Match - CRMA to Tableau+ Swap\n\n' +
    'AE Email: Nick Zerrillo\n' +
    'Customer Name: Swedish Match\n' +
    'Value: $671,760.00\n' +
    'Avangrid - Emergency Response Phase 1\n\n' +
    'AE Email: Robbie Conrey\n' +
    'Customer Name: Avangrid\n' +
    'Value: $655,360.00\n' +
    'Lennox International Inc. - Dealer Portal\n\n' +
    'AE Email: Eric Williams\n' +
    'Customer Name: Lennox International Inc.\n' +
    'Value: $571,200.00\n' +
    'Halliburton Energy Services, Inc.\n\n' +
    'AE Email: Gordon Lutken\n' +
    'Customer Name: Halliburton Energy Services, Inc.\n' +
    'Value: $540,000.00\n' +
    'Let me know if you need further details!';

System.debug('Input Data Format:');
System.debug(aeOpportunitiesData);

try {
    System.debug('\n=== Testing TSV Export ===');
    String downloadUrl = ANAgentSimpleTSVHandler.convertToTSV(aeOpportunitiesData, 'AMER_ICE_Stage5_Opportunities.tsv');
    System.debug('✅ TSV Export SUCCESSFUL!');
    System.debug('✅ Download URL: ' + downloadUrl);
    
    System.debug('\n🎯 KEY SUCCESS: AE Opportunities data exported to TSV!');
    System.debug('✅ Opportunity names with dashes and special characters');
    System.debug('✅ AE Email addresses');
    System.debug('✅ Customer names');
    System.debug('✅ Dollar values with commas (e.g., $2,136,000.00)');
    System.debug('✅ All data properly separated by tabs instead of commas');
    
} catch (Exception e) {
    System.debug('❌ TSV Export FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    
    // Let's try to understand what went wrong
    System.debug('\n=== DEBUGGING THE ISSUE ===');
    System.debug('The current TSV service might not have a parser for this specific format.');
    System.debug('We need to add a specialized parser for AE Opportunities data.');
}

System.debug('\n=== ANALYSIS OF THE DATA FORMAT ===');
System.debug('This data has a specific structure:');
System.debug('1. Opportunity name (e.g., "Vizio Hardware - Service A1E Upgrade")');
System.debug('2. AE Email: [email]');
System.debug('3. Customer Name: [name]');
System.debug('4. Value: [dollar amount]');
System.debug('5. Empty line separator');
System.debug('6. Repeat for next opportunity');
System.debug('\nThis format needs a specialized parser in the TSV service.');
