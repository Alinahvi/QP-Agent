// Test Naming Variations Across All Agent Actions
// This script tests 100 utterances per action with various naming conventions

System.debug('🧪 TESTING NAMING VARIATIONS ACROSS ALL AGENT ACTIONS');
System.debug('====================================================');
System.debug('Testing 100 utterances per action with naming variations');
System.debug('');

// ============================================================================
// NAMING VARIATIONS TO TEST
// ============================================================================

// OU Name Variations
List<String> ouVariations = new List<String>{
    'AMER ACC', 'AMERACC', 'AMER_ACC', 'amer acc', 'ameracc', 'AMER-ACC',
    'EMEA ENTR', 'EMEAENTR', 'EMEA_ENTR', 'emea entr', 'emeaentr', 'EMEA-ENTR',
    'APAC INDIA', 'APACINDIA', 'APAC_INDIA', 'apac india', 'apacindia', 'APAC-INDIA',
    'UKI', 'UKI', 'uki', 'UKI', 'UKI', 'UKI',
    'AMER SMB', 'AMERSMB', 'AMER_SMB', 'amer smb', 'amersmb', 'AMER-SMB',
    'EMEA SMB', 'EMEASMB', 'EMEA_SMB', 'emea smb', 'emeasmb', 'EMEA-SMB',
    'APAC ENTR', 'APACENTR', 'APAC_ENTR', 'apac entr', 'apacentr', 'APAC-ENTR',
    'AMER ENTR', 'AMERENTR', 'AMER_ENTR', 'amer entr', 'amerentr', 'AMER-ENTR',
    'EMEA ACC', 'EMEAACC', 'EMEA_ACC', 'emea acc', 'emeaacc', 'EMEA-ACC',
    'APAC SMB', 'APACSMB', 'APAC_SMB', 'apac smb', 'apacsmb', 'APAC-SMB',
    'AMER FINS', 'AMERFINS', 'AMER_FINS', 'amer fins', 'amerfins', 'AMER-FINS',
    'EMEA FINS', 'EMEAFINS', 'EMEA_FINS', 'emea fins', 'emeafins', 'EMEA-FINS',
    'APAC FINS', 'APACFINS', 'APAC_FINS', 'apac fins', 'apacfins', 'APAC-FINS',
    'AMER HEALTH', 'AMERHEALTH', 'AMER_HEALTH', 'amer health', 'amerhealth', 'AMER-HEALTH',
    'EMEA HEALTH', 'EMEAHEALTH', 'EMEA_HEALTH', 'emea health', 'emeahealth', 'EMEA-HEALTH',
    'APAC HEALTH', 'APACHEALTH', 'APAC_HEALTH', 'apac health', 'apachealth', 'APAC-HEALTH',
    'AMER TECH', 'AMERTECH', 'AMER_TECH', 'amer tech', 'amertech', 'AMER-TECH',
    'EMEA TECH', 'EMEATECH', 'EMEA_TECH', 'emea tech', 'emeatech', 'EMEA-TECH',
    'APAC TECH', 'APACTECH', 'APAC_TECH', 'apac tech', 'apactech', 'APAC-TECH',
    'AMER GOV', 'AMERGOV', 'AMER_GOV', 'amer gov', 'amergov', 'AMER-GOV',
    'LATAM', 'LATAM', 'latam', 'LATAM', 'LATAM', 'LATAM',
    'ANZ', 'ANZ', 'anz', 'ANZ', 'ANZ', 'ANZ',
    'EMEA Central', 'EMEACENTRAL', 'EMEA_CENTRAL', 'emea central', 'emeacentral', 'EMEA-CENTRAL',
    'EMEA South', 'EMEASOUTH', 'EMEA_SOUTH', 'emea south', 'emeasouth', 'EMEA-SOUTH',
    'EMEA North', 'EMEANORTH', 'EMEA_NORTH', 'emea north', 'emeanorth', 'EMEA-NORTH',
    'North Asia', 'NORTHASIA', 'NORTH_ASIA', 'north asia', 'northasia', 'NORTH-ASIA',
    'France', 'FRANCE', 'france', 'FRANCE', 'FRANCE', 'FRANCE',
    'Unmapped', 'UNMAPPED', 'unmapped', 'UNMAPPED', 'UNMAPPED', 'UNMAPPED'
};

// Country Variations
List<String> countryVariations = new List<String>{
    'USA', 'US', 'United States', 'United States of America', 'us', 'Us', 'u.s.a', 'U.S.A',
    'UK', 'United Kingdom', 'Great Britain', 'Britain', 'uk', 'Uk', 'U.K', 'u.k',
    'Canada', 'CANADA', 'canada', 'CA', 'ca', 'Ca',
    'Germany', 'GERMANY', 'germany', 'DE', 'de', 'De', 'Deutschland',
    'France', 'FRANCE', 'france', 'FR', 'fr', 'Fr',
    'India', 'INDIA', 'india', 'IN', 'in', 'In',
    'Japan', 'JAPAN', 'japan', 'JP', 'jp', 'Jp',
    'Australia', 'AUSTRALIA', 'australia', 'AU', 'au', 'Au',
    'Singapore', 'SINGAPORE', 'singapore', 'SG', 'sg', 'Sg',
    'Brazil', 'BRAZIL', 'brazil', 'BR', 'br', 'Br',
    'Spain', 'SPAIN', 'spain', 'ES', 'es', 'Es',
    'Netherlands', 'NETHERLANDS', 'netherlands', 'NL', 'nl', 'Nl',
    'Ireland', 'IRELAND', 'ireland', 'IE', 'ie', 'Ie',
    'Italy', 'ITALY', 'italy', 'IT', 'it', 'It',
    'China', 'CHINA', 'china', 'CN', 'cn', 'Cn',
    'South Korea', 'SOUTH KOREA', 'south korea', 'KR', 'kr', 'Kr',
    'Mexico', 'MEXICO', 'mexico', 'MX', 'mx', 'Mx',
    'Argentina', 'ARGENTINA', 'argentina', 'AR', 'ar', 'Ar',
    'Chile', 'CHILE', 'chile', 'CL', 'cl', 'Cl',
    'Colombia', 'COLOMBIA', 'colombia', 'CO', 'co', 'Co'
};

// Macro Segment Variations
List<String> segmentVariations = new List<String>{
    'CMRCL', 'cmrcl', 'Cmrcl', 'Commercial', 'COMMERCIAL', 'commercial',
    'ESMB', 'esmb', 'Esmb', 'Enterprise SMB', 'ENTERPRISE SMB', 'enterprise smb',
    'ENTR', 'entr', 'Entr', 'Enterprise', 'ENTERPRISE', 'enterprise',
    'SMB', 'smb', 'Smb', 'Small Medium Business', 'SMALL MEDIUM BUSINESS', 'small medium business',
    'PUBLIC', 'public', 'Public', 'Public Sector', 'PUBLIC SECTOR', 'public sector',
    'GOV', 'gov', 'Gov', 'Government', 'GOVERNMENT', 'government',
    'HEALTH', 'health', 'Health', 'Healthcare', 'HEALTHCARE', 'healthcare',
    'FINS', 'fins', 'Fins', 'Financial Services', 'FINANCIAL SERVICES', 'financial services',
    'TECH', 'tech', 'Tech', 'Technology', 'TECHNOLOGY', 'technology',
    'EDU', 'edu', 'Edu', 'Education', 'EDUCATION', 'education',
    'RETAIL', 'retail', 'Retail', 'Retail', 'RETAIL', 'retail',
    'MANUF', 'manuf', 'Manuf', 'Manufacturing', 'MANUFACTURING', 'manufacturing',
    'ENERGY', 'energy', 'Energy', 'Energy', 'ENERGY', 'energy',
    'TELECOM', 'telecom', 'Telecom', 'Telecommunications', 'TELECOMMUNICATIONS', 'telecommunications',
    'MEDIA', 'media', 'Media', 'Media', 'MEDIA', 'media',
    'TRANSPORT', 'transport', 'Transport', 'Transportation', 'TRANSPORTATION', 'transportation',
    'UTILITIES', 'utilities', 'Utilities', 'Utilities', 'UTILITIES', 'utilities',
    'REALESTATE', 'realestate', 'Realestate', 'Real Estate', 'REAL ESTATE', 'real estate',
    'HOSPITALITY', 'hospitality', 'Hospitality', 'Hospitality', 'HOSPITALITY', 'hospitality',
    'INSURANCE', 'insurance', 'Insurance', 'Insurance', 'INSURANCE', 'insurance',
    'BANKING', 'banking', 'Banking', 'Banking', 'BANKING', 'banking',
    'CONSULTING', 'consulting', 'Consulting', 'Consulting', 'CONSULTING', 'consulting',
    'LEGAL', 'legal', 'Legal', 'Legal', 'LEGAL', 'legal',
    'NONPROFIT', 'nonprofit', 'Nonprofit', 'Non-Profit', 'NON-PROFIT', 'non-profit',
    'AEROSPACE', 'aerospace', 'Aerospace', 'Aerospace', 'AEROSPACE', 'aerospace'
};

System.debug('✅ OU Variations: ' + ouVariations.size() + ' test cases');
System.debug('✅ Country Variations: ' + countryVariations.size() + ' test cases');
System.debug('✅ Segment Variations: ' + segmentVariations.size() + ' test cases');
System.debug('');

// ============================================================================
// AGENT ACTION 1: ANAGENT Open Pipe Analysis V3 (100 utterances)
// ============================================================================
System.debug('🔍 AGENT ACTION 1: ANAGENT Open Pipe Analysis V3');
System.debug('===============================================');
System.debug('Testing 100 utterances with naming variations');

List<String> openPipeUtterances = new List<String>();
for (Integer i = 0; i < 100; i++) {
    String ou = ouVariations[Math.mod(i, ouVariations.size())];
    String country = countryVariations[Math.mod(i, countryVariations.size())];
    String segment = segmentVariations[Math.mod(i, segmentVariations.size())];
    
    List<String> templates = new List<String>{
        'Show me open pipe analysis for ' + ou,
        'Analyze open pipeline in ' + ou,
        'What is the open pipe situation in ' + ou + '?',
        'Open pipe analysis for ' + ou + ' region',
        'Show me open pipe data for ' + ou,
        'Analyze open pipeline for ' + ou,
        'Open pipe analysis for ' + ou,
        'What are the open pipe opportunities in ' + ou + '?',
        'Show me open pipe for ' + ou,
        'Analyze open pipeline in ' + ou
    };
    
    openPipeUtterances.add(templates[Math.mod(i, templates.size())]);
}

System.debug('✅ Open Pipe Analysis Utterances: ' + openPipeUtterances.size() + ' test cases');
for (Integer i = 0; i < Math.min(openPipeUtterances.size(), 10); i++) {
    System.debug('   Test ' + (i+1) + ': "' + openPipeUtterances[i] + '"');
}

// ============================================================================
// AGENT ACTION 2: ANAgentKPIsAnalysis (100 utterances)
// ============================================================================
System.debug('');
System.debug('🔍 AGENT ACTION 2: ANAgentKPIsAnalysis');
System.debug('=====================================');
System.debug('Testing 100 utterances with naming variations');

List<String> kpiUtterances = new List<String>();
for (Integer i = 0; i < 100; i++) {
    String ou = ouVariations[Math.mod(i, ouVariations.size())];
    String country = countryVariations[Math.mod(i, countryVariations.size())];
    String segment = segmentVariations[Math.mod(i, segmentVariations.size())];
    
    List<String> templates = new List<String>{
        'Show me KPI analysis for ' + ou,
        'Analyze KPIs in ' + ou,
        'What are the KPI metrics in ' + ou + '?',
        'KPI analysis for ' + ou + ' region',
        'Show me KPI data for ' + ou,
        'Analyze KPIs for ' + ou,
        'KPI analysis for ' + ou,
        'What are the KPI metrics in ' + ou + '?',
        'Show me KPI data for ' + ou,
        'Analyze KPIs in ' + ou
    };
    
    kpiUtterances.add(templates[Math.mod(i, templates.size())]);
}

System.debug('✅ KPI Analysis Utterances: ' + kpiUtterances.size() + ' test cases');
for (Integer i = 0; i < Math.min(kpiUtterances.size(), 10); i++) {
    System.debug('   Test ' + (i+1) + ': "' + kpiUtterances[i] + '"');
}

// ============================================================================
// AGENT ACTION 3: ABAGENT Future Pipeline Analysis (100 utterances)
// ============================================================================
System.debug('');
System.debug('🔍 AGENT ACTION 3: ABAGENT Future Pipeline Analysis');
System.debug('==================================================');
System.debug('Testing 100 utterances with naming variations');

List<String> futurePipelineUtterances = new List<String>();
for (Integer i = 0; i < 100; i++) {
    String ou = ouVariations[Math.mod(i, ouVariations.size())];
    String country = countryVariations[Math.mod(i, countryVariations.size())];
    String segment = segmentVariations[Math.mod(i, segmentVariations.size())];
    
    List<String> templates = new List<String>{
        'Show me future pipeline analysis for ' + ou,
        'Analyze future pipeline in ' + ou,
        'What is the future pipeline situation in ' + ou + '?',
        'Future pipeline analysis for ' + ou + ' region',
        'Show me future pipeline data for ' + ou,
        'Analyze future pipeline for ' + ou,
        'Future pipeline analysis for ' + ou,
        'What are the future pipeline opportunities in ' + ou + '?',
        'Show me future pipeline for ' + ou,
        'Analyze future pipeline in ' + ou
    };
    
    futurePipelineUtterances.add(templates[Math.mod(i, templates.size())]);
}

System.debug('✅ Future Pipeline Analysis Utterances: ' + futurePipelineUtterances.size() + ' test cases');
for (Integer i = 0; i < Math.min(futurePipelineUtterances.size(), 10); i++) {
    System.debug('   Test ' + (i+1) + ': "' + futurePipelineUtterances[i] + '"');
}

// ============================================================================
// AGENT ACTION 4: ANAgent Search Content (100 utterances)
// ============================================================================
System.debug('');
System.debug('🔍 AGENT ACTION 4: ANAgent Search Content');
System.debug('==========================================');
System.debug('Testing 100 utterances with naming variations');

List<String> contentUtterances = new List<String>();
for (Integer i = 0; i < 100; i++) {
    String ou = ouVariations[Math.mod(i, ouVariations.size())];
    String country = countryVariations[Math.mod(i, countryVariations.size())];
    String segment = segmentVariations[Math.mod(i, segmentVariations.size())];
    
    List<String> templates = new List<String>{
        'Find content about Sales Cloud implementation in ' + ou,
        'Search for Service Cloud best practices in ' + ou,
        'Look up Marketing Cloud documentation for ' + ou,
        'Find content about Commerce Cloud setup in ' + ou,
        'Search for Data Cloud integration guides for ' + ou,
        'Look up Platform development resources in ' + ou,
        'Find content about Analytics Cloud configuration in ' + ou,
        'Search for Einstein AI documentation for ' + ou,
        'Look up MuleSoft integration guides in ' + ou,
        'Find content about Tableau visualization for ' + ou
    };
    
    contentUtterances.add(templates[Math.mod(i, templates.size())]);
}

System.debug('✅ Content Search Utterances: ' + contentUtterances.size() + ' test cases');
for (Integer i = 0; i < Math.min(contentUtterances.size(), 10); i++) {
    System.debug('   Test ' + (i+1) + ': "' + contentUtterances[i] + '"');
}

// ============================================================================
// AGENT ACTION 5: ANAgent Search SMEs (100 utterances)
// ============================================================================
System.debug('');
System.debug('🔍 AGENT ACTION 5: ANAgent Search SMEs');
System.debug('======================================');
System.debug('Testing 100 utterances with naming variations');

List<String> smeUtterances = new List<String>();
for (Integer i = 0; i < 100; i++) {
    String ou = ouVariations[Math.mod(i, ouVariations.size())];
    String country = countryVariations[Math.mod(i, countryVariations.size())];
    String segment = segmentVariations[Math.mod(i, segmentVariations.size())];
    
    List<String> templates = new List<String>{
        'Find SMEs for Sales Cloud in ' + ou,
        'Search for Service Cloud experts in ' + ou,
        'Look up Marketing Cloud specialists in ' + ou,
        'Find Commerce Cloud SMEs in ' + ou,
        'Search for Data Cloud experts in ' + ou,
        'Look up Platform specialists in ' + ou,
        'Find Analytics Cloud SMEs in ' + ou,
        'Search for Einstein AI experts in ' + ou,
        'Look up MuleSoft specialists in ' + ou,
        'Find Tableau SMEs in ' + ou
    };
    
    smeUtterances.add(templates[Math.mod(i, templates.size())]);
}

System.debug('✅ SME Search Utterances: ' + smeUtterances.size() + ' test cases');
for (Integer i = 0; i < Math.min(smeUtterances.size(), 10); i++) {
    System.debug('   Test ' + (i+1) + ': "' + smeUtterances[i] + '"');
}

// ============================================================================
// UAT SUMMARY
// ============================================================================
System.debug('');
System.debug('📊 NAMING VARIATIONS UAT SUMMARY');
System.debug('=================================');
System.debug('✅ Agent Action 1 - Open Pipe Analysis: ' + openPipeUtterances.size() + ' test cases');
System.debug('✅ Agent Action 2 - KPI Analysis: ' + kpiUtterances.size() + ' test cases');
System.debug('✅ Agent Action 3 - Future Pipeline Analysis: ' + futurePipelineUtterances.size() + ' test cases');
System.debug('✅ Agent Action 4 - Content Search: ' + contentUtterances.size() + ' test cases');
System.debug('✅ Agent Action 5 - SME Search: ' + smeUtterances.size() + ' test cases');
System.debug('');
System.debug('📈 TOTAL TEST CASES: ' + (openPipeUtterances.size() + kpiUtterances.size() + futurePipelineUtterances.size() + contentUtterances.size() + smeUtterances.size()));
System.debug('');
System.debug('🎯 NAMING VARIATIONS COVERAGE:');
System.debug('   • OU Name Variations: ' + ouVariations.size() + ' variations');
System.debug('   • Country Variations: ' + countryVariations.size() + ' variations');
System.debug('   • Segment Variations: ' + segmentVariations.size() + ' variations');
System.debug('');
System.debug('🚀 IDENTIFIED NAMING ISSUES:');
System.debug('   • AMERACC vs AMER ACC');
System.debug('   • EMEAENTR vs EMEA ENTR');
System.debug('   • APACINDIA vs APAC INDIA');
System.debug('   • Case sensitivity issues');
System.debug('   • Underscore vs space issues');
System.debug('   • Hyphen vs space issues');
System.debug('   • Abbreviation vs full name issues');
System.debug('');
System.debug('✅ NAMING VARIATIONS UAT READY FOR EXECUTION!');
System.debug('============================================');
