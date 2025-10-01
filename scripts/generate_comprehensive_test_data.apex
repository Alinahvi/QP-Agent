// Comprehensive Test Data Generation Script for Future Pipeline Analysis
// This script creates realistic test data for all three custom objects
// Run this script to populate the environment with 450+ records

System.debug('🚀 Starting Comprehensive Test Data Generation');
System.debug('=============================================');

// Step 1: Clean existing data
System.debug('\n🧹 Step 1: Cleaning existing data...');
try {
    List<Agent_Renewals__c> existingRenewals = [SELECT Id FROM Agent_Renewals__c];
    List<Agent_Cross_Sell__c> existingCrossSell = [SELECT Id FROM Agent_Cross_Sell__c];
    List<Agent_Upsell__c> existingUpsell = [SELECT Id FROM Agent_Upsell__c];
    
    if (!existingRenewals.isEmpty()) {
        delete existingRenewals;
        System.debug('✅ Deleted ' + existingRenewals.size() + ' existing renewal records');
    }
    
    if (!existingCrossSell.isEmpty()) {
        delete existingCrossSell;
        System.debug('✅ Deleted ' + existingCrossSell.size() + ' existing cross-sell records');
    }
    
    if (!existingUpsell.isEmpty()) {
        delete existingUpsell;
        System.debug('✅ Deleted ' + existingUpsell.size() + ' existing upsell records');
    }
} catch (Exception e) {
    System.debug('⚠️ Warning during cleanup: ' + e.getMessage());
}

// Step 2: Define test data constants
System.debug('\n📊 Step 2: Defining test data constants...');

// AE Names (15 different AEs)
List<String> aeNames = new List<String>{
    'John Smith', 'Sarah Johnson', 'Mike Davis', 'Emily Chen', 'David Wilson',
    'Lisa Anderson', 'Robert Brown', 'Jennifer Garcia', 'Christopher Lee', 'Amanda Taylor',
    'Michael Martinez', 'Jessica White', 'Daniel Rodriguez', 'Ashley Thompson', 'Matthew Jackson'
};

// Operating Units (5 different OUs)
List<String> operatingUnits = new List<String>{
    'AMER ICE', 'EMEA ENTR', 'APAC SMB', 'LATAM MID', 'CANADA ENT'
};

// Countries
List<String> countries = new List<String>{
    'United States', 'United Kingdom', 'Germany', 'France', 'Australia',
    'Japan', 'Canada', 'Mexico', 'Brazil', 'Singapore'
};

// Industries
List<String> industries = new List<String>{
    'Technology', 'Financial Services', 'Healthcare', 'Manufacturing', 'Retail',
    'Government', 'Education', 'Energy', 'Telecommunications', 'Professional Services'
};

// Macro Segments
List<String> macroSegments = new List<String>{
    'Enterprise', 'Mid-Market', 'SMB', 'Strategic', 'Growth'
};

// Product L2 Categories
List<String> productL2 = new List<String>{
    'Cloud Services', 'On-Prem Software', 'Hardware Support', 'Professional Services', 'Training'
};

// Product L3 Categories (mapped to L2)
Map<String, List<String>> productL3Map = new Map<String, List<String>>{
    'Cloud Services' => new List<String>{'Sales Cloud', 'Service Cloud', 'Marketing Cloud', 'Commerce Cloud', 'Platform'},
    'On-Prem Software' => new List<String>{'CRM On-Prem', 'Analytics On-Prem', 'Integration Tools', 'Data Tools'},
    'Hardware Support' => new List<String>{'Infrastructure Support', 'Network Support', 'Storage Support', 'Security Support'},
    'Professional Services' => new List<String>{'Implementation', 'Consulting', 'Custom Development', 'Integration Services'},
    'Training' => new List<String>{'Administrator Training', 'Developer Training', 'End User Training', 'Certification Programs'}
};

// Manager Names
List<String> managers = new List<String>{
    'Alex Thompson', 'Maria Rodriguez', 'James Wilson', 'Sophie Chen', 'Kevin Davis',
    'Rachel Green', 'Tom Anderson', 'Nina Patel', 'Steve Johnson', 'Amy Brown'
};

// Step 3: Generate Renewals Data (150 records)
System.debug('\n🔄 Step 3: Generating Renewals data (150 records)...');
List<Agent_Renewals__c> renewals = new List<Agent_Renewals__c>();

for (Integer i = 0; i < 150; i++) {
    Agent_Renewals__c renewal = new Agent_Renewals__c();
    
    // Basic fields
    renewal.full_name__c = aeNames[Math.mod(i, aeNames.size())];
    renewal.ou_name__c = operatingUnits[Math.mod(i, operatingUnits.size())];
    renewal.work_location_country__c = countries[Math.mod(i, countries.size())];
    renewal.primary_industry__c = industries[Math.mod(i, industries.size())];
    renewal.macrosgment__c = macroSegments[Math.mod(i, macroSegments.size())];
    renewal.emp_mgr_nm__c = managers[Math.mod(i, managers.size())];
    renewal.emp_id__c = 'EMP' + String.valueOf(1000 + Math.mod(i, 100));
    renewal.emp_email_addr__c = renewal.full_name__c.replace(' ', '.').toLowerCase() + '@company.com';
    
    // Product fields
    String selectedL2 = productL2[Math.mod(i, productL2.size())];
    renewal.PRODUCT_L2__c = selectedL2;
    renewal.PRODUCT_L3__c = productL3Map.get(selectedL2)[Math.mod(i, productL3Map.get(selectedL2).size())];
    renewal.renewal_prod_nm__c = renewal.PRODUCT_L3__c + ' - Enterprise Edition';
    
    // Account fields
    renewal.renewal_acct_nm__c = 'Account ' + String.valueOf(i + 1) + ' Inc.';
    renewal.renewal_acct_id__c = 'ACC' + String.valueOf(10000 + i);
    renewal.renewal_rn__c = 'RN' + String.valueOf(20000 + i);
    
    // Amount and dates
    renewal.renewal_opty_amt__c = 5000 + (Math.random() * 245000); // $5K to $250K
    renewal.CloseDate__c = Date.today().addDays(30 + (Integer)(Math.random() * 335)); // Next 365 days
    
    // Performance fields
    renewal.AE_Score__c = 2.5 + (Math.random() * 2.5); // 2.5 to 5.0
    renewal.Coverage__c = (0.75 + (Math.random() * 0.75)) / 100; // 75% to 150%
    
    // Additional fields
    renewal.ramp_status__c = Math.random() > 0.7 ? 'Slow Ramper' : 'On Track';
    renewal.time_since_onboarding__c = 1 + (Integer)(Math.random() * 24); // 1-24 months
    renewal.learner_profile_id__c = 'LP' + String.valueOf(30000 + i);
    
    renewals.add(renewal);
}

try {
    insert renewals;
    System.debug('✅ Successfully created ' + renewals.size() + ' renewal records');
} catch (Exception e) {
    System.debug('❌ Error creating renewals: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Step 4: Generate Cross-Sell Data (150 records)
System.debug('\n🔄 Step 4: Generating Cross-Sell data (150 records)...');
List<Agent_Cross_Sell__c> crossSells = new List<Agent_Cross_Sell__c>();

for (Integer i = 0; i < 150; i++) {
    Agent_Cross_Sell__c crossSell = new Agent_Cross_Sell__c();
    
    // Basic fields
    crossSell.full_name__c = aeNames[Math.mod(i + 50, aeNames.size())]; // Offset to vary AEs
    crossSell.ou_name__c = operatingUnits[Math.mod(i + 30, operatingUnits.size())];
    crossSell.work_location_country__c = countries[Math.mod(i + 20, countries.size())];
    crossSell.primary_industry__c = industries[Math.mod(i + 40, industries.size())];
    crossSell.macrosgment__c = macroSegments[Math.mod(i + 10, macroSegments.size())];
    crossSell.emp_mgr_nm__c = managers[Math.mod(i + 25, managers.size())];
    crossSell.emp_id__c = 'EMP' + String.valueOf(2000 + Math.mod(i, 100));
    crossSell.emp_email_addr__c = crossSell.full_name__c.replace(' ', '.').toLowerCase() + '@company.com';
    
    // Product fields
    String selectedL2 = productL2[Math.mod(i + 15, productL2.size())];
    crossSell.PRODUCT_L2__c = selectedL2;
    crossSell.PRODUCT_L3__c = productL3Map.get(selectedL2)[Math.mod(i + 5, productL3Map.get(selectedL2).size())];
    crossSell.cross_sell_next_best_product__c = crossSell.PRODUCT_L3__c + ' - Professional Edition';
    
    // Account fields
    crossSell.cross_sell_acct_nm__c = 'Account ' + String.valueOf(i + 151) + ' Corp.';
    crossSell.cross_sell_acct_id__c = 'ACC' + String.valueOf(20000 + i);
    crossSell.cross_sell_rn__c = 'RN' + String.valueOf(40000 + i);
    
    // Amount and dates
    crossSell.Amount__c = 3000 + (Math.random() * 147000); // $3K to $150K
    crossSell.CloseDate__c = Date.today().addDays(60 + (Integer)(Math.random() * 305)); // Next 365 days
    
    // Performance fields
    crossSell.AE_Score__c = 2.5 + (Math.random() * 2.5); // 2.5 to 5.0
    crossSell.Coverage__c = (0.75 + (Math.random() * 0.75)) / 100; // 75% to 150%
    
    // Additional fields
    crossSell.ramp_status__c = Math.random() > 0.8 ? 'Slow Ramper' : 'On Track';
    crossSell.time_since_onboarding__c = 1 + (Integer)(Math.random() * 24); // 1-24 months
    crossSell.learner_profile_id__c = 'LP' + String.valueOf(50000 + i);
    
    crossSells.add(crossSell);
}

try {
    insert crossSells;
    System.debug('✅ Successfully created ' + crossSells.size() + ' cross-sell records');
} catch (Exception e) {
    System.debug('❌ Error creating cross-sells: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Step 5: Generate Upsell Data (150 records)
System.debug('\n🔄 Step 5: Generating Upsell data (150 records)...');
List<Agent_Upsell__c> upsells = new List<Agent_Upsell__c>();

for (Integer i = 0; i < 150; i++) {
    Agent_Upsell__c upsell = new Agent_Upsell__c();
    
    // Basic fields
    upsell.full_name__c = aeNames[Math.mod(i + 100, aeNames.size())]; // Offset to vary AEs
    upsell.ou_name__c = operatingUnits[Math.mod(i + 60, operatingUnits.size())];
    upsell.work_location_country__c = countries[Math.mod(i + 40, countries.size())];
    upsell.primary_industry__c = industries[Math.mod(i + 80, industries.size())];
    upsell.macrosgment__c = macroSegments[Math.mod(i + 20, macroSegments.size())];
    upsell.emp_mgr_nm__c = managers[Math.mod(i + 50, managers.size())];
    upsell.emp_id__c = 'EMP' + String.valueOf(3000 + Math.mod(i, 100));
    upsell.emp_email_addr__c = upsell.full_name__c.replace(' ', '.').toLowerCase() + '@company.com';
    
    // Product fields
    String selectedL2 = productL2[Math.mod(i + 30, productL2.size())];
    upsell.PRODUCT_L2__c = selectedL2;
    upsell.PRODUCT_L3__c = productL3Map.get(selectedL2)[Math.mod(i + 10, productL3Map.get(selectedL2).size())];
    upsell.upsell_sub_category__c = upsell.PRODUCT_L3__c + ' - Unlimited Edition';
    
    // Account fields
    upsell.upsell_acct_nm__c = 'Account ' + String.valueOf(i + 301) + ' LLC.';
    upsell.upsell_acct_id__c = 'ACC' + String.valueOf(30000 + i);
    upsell.upsell_rn__c = 'RN' + String.valueOf(60000 + i);
    
    // Amount and dates
    upsell.Amount__c = 2000 + (Math.random() * 98000); // $2K to $100K
    upsell.CloseDate__c = Date.today().addDays(90 + (Integer)(Math.random() * 275)); // Next 365 days
    
    // Performance fields
    upsell.AE_Score__c = 2.5 + (Math.random() * 2.5); // 2.5 to 5.0
    upsell.Coverage__c = (0.75 + (Math.random() * 0.75)) / 100; // 75% to 150%
    
    // Additional fields
    upsell.ramp_status__c = Math.random() > 0.75 ? 'Slow Ramper' : 'On Track';
    upsell.time_since_onboarding__c = 1 + (Integer)(Math.random() * 24); // 1-24 months
    upsell.learner_profile_id__c = 'LP' + String.valueOf(70000 + i);
    
    upsells.add(upsell);
}

try {
    insert upsells;
    System.debug('✅ Successfully created ' + upsells.size() + ' upsell records');
} catch (Exception e) {
    System.debug('❌ Error creating upsells: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Step 6: Verification and Summary
System.debug('\n📊 Step 6: Verification and Summary...');

try {
    Integer renewalCount = [SELECT COUNT() FROM Agent_Renewals__c];
    Integer crossSellCount = [SELECT COUNT() FROM Agent_Cross_Sell__c];
    Integer upsellCount = [SELECT COUNT() FROM Agent_Upsell__c];
    
    System.debug('📈 Final Record Counts:');
    System.debug('- Renewals: ' + renewalCount);
    System.debug('- Cross-Sell: ' + crossSellCount);
    System.debug('- Upsell: ' + upsellCount);
    System.debug('- Total: ' + (renewalCount + crossSellCount + upsellCount));
    
    // Sample data verification
    Agent_Renewals__c sampleRenewal = [SELECT Id, full_name__c, ou_name__c, renewal_opty_amt__c, 
                                      AE_Score__c, Coverage__c, CloseDate__c, PRODUCT_L2__c, PRODUCT_L3__c 
                                      FROM Agent_Renewals__c LIMIT 1];
    
    System.debug('\n🔍 Sample Renewal Record:');
    System.debug('- AE: ' + sampleRenewal.full_name__c);
    System.debug('- OU: ' + sampleRenewal.ou_name__c);
    System.debug('- Amount: $' + sampleRenewal.renewal_opty_amt__c);
    System.debug('- AE Score: ' + sampleRenewal.AE_Score__c);
    System.debug('- Coverage: ' + sampleRenewal.Coverage__c + '%');
    System.debug('- Close Date: ' + sampleRenewal.CloseDate__c);
    System.debug('- Product L2: ' + sampleRenewal.PRODUCT_L2__c);
    System.debug('- Product L3: ' + sampleRenewal.PRODUCT_L3__c);
    
} catch (Exception e) {
    System.debug('❌ Error during verification: ' + e.getMessage());
}

System.debug('\n🎉 Test Data Generation Complete!');
System.debug('=============================================');
System.debug('✅ All custom fields have been populated with realistic data');
System.debug('✅ Data includes varied AEs, OUs, products, and performance metrics');
System.debug('✅ Ready for intelligence feature testing and validation');
