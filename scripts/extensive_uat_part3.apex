// Extensive UAT Part 3: SME Search (50+ utterances)
System.debug('🧪 Extensive UAT Part 3: SME Search');
System.debug('==================================');

List<String> smeUtterances = new List<String>{
    // Basic SME Search
    'Find SMEs for Data Cloud in AMER ACC',
    'Who are the experts in Sales Cloud in EMEA ENTR?',
    'Show me SMEs for Service Cloud in APAC region',
    'Find experts for Marketing Cloud in UKI',
    'Who can help with Commerce Cloud in AMER ACC?',
    'Show me SMEs for Platform in EMEA ENTR',
    'Find experts for Analytics Cloud in APAC',
    
    // Product Variations
    'Find SMEs for Sales Cloud in AMER ACC',
    'Who are the experts in Service Cloud in EMEA ENTR?',
    'Show me SMEs for Marketing Cloud in APAC',
    'Find experts for Commerce Cloud in UKI',
    'Who can help with Data Cloud in AMER ACC?',
    'Show me SMEs for Platform in EMEA ENTR',
    'Find experts for Analytics Cloud in APAC',
    'Who are the experts in Integration Cloud in UKI?',
    'Show me SMEs for Sales Cloud in AMER ACC',
    'Find experts for Service Cloud in EMEA ENTR',
    'Who can help with Marketing Cloud in APAC?',
    'Show me SMEs for Commerce Cloud in UKI',
    'Find experts for Data Cloud in AMER ACC',
    'Who are the experts in Platform in EMEA ENTR?',
    'Show me SMEs for Analytics Cloud in APAC',
    'Find experts for Integration Cloud in UKI',
    
    // Regional Variations
    'Find SMEs for Data Cloud in AMER ACC',
    'Who are the experts in Sales Cloud in EMEA ENTR?',
    'Show me SMEs for Service Cloud in APAC',
    'Find experts for Marketing Cloud in UKI',
    'Who can help with Commerce Cloud in AMER ACC?',
    'Show me SMEs for Platform in EMEA ENTR',
    'Find experts for Analytics Cloud in APAC',
    'Who are the experts in Integration Cloud in UKI?',
    'Show me SMEs for Data Cloud in AMER ACC',
    'Find experts for Sales Cloud in EMEA ENTR',
    'Who can help with Service Cloud in APAC?',
    'Show me SMEs for Marketing Cloud in UKI',
    'Find experts for Commerce Cloud in AMER ACC',
    'Who are the experts in Platform in EMEA ENTR?',
    'Show me SMEs for Analytics Cloud in APAC',
    'Find experts for Integration Cloud in UKI',
    
    // Skill Level Variations
    'Find senior SMEs for Data Cloud in AMER ACC',
    'Who are the expert level professionals in Sales Cloud in EMEA ENTR?',
    'Show me advanced SMEs for Service Cloud in APAC',
    'Find lead experts for Marketing Cloud in UKI',
    'Who can help with Commerce Cloud in AMER ACC at expert level?',
    'Show me senior SMEs for Platform in EMEA ENTR',
    'Find advanced experts for Analytics Cloud in APAC',
    'Who are the lead experts in Integration Cloud in UKI?',
    'Show me senior SMEs for Data Cloud in AMER ACC',
    'Find expert level professionals for Sales Cloud in EMEA ENTR',
    'Who can help with Service Cloud in APAC at senior level?',
    'Show me advanced SMEs for Marketing Cloud in UKI',
    'Find lead experts for Commerce Cloud in AMER ACC',
    'Who are the senior experts in Platform in EMEA ENTR?',
    'Show me expert level SMEs for Analytics Cloud in APAC',
    'Find advanced experts for Integration Cloud in UKI',
    
    // Availability Variations
    'Find available SMEs for Data Cloud in AMER ACC',
    'Who are the available experts in Sales Cloud in EMEA ENTR?',
    'Show me available SMEs for Service Cloud in APAC',
    'Find available experts for Marketing Cloud in UKI',
    'Who can help with Commerce Cloud in AMER ACC and is available?',
    'Show me available SMEs for Platform in EMEA ENTR',
    'Find available experts for Analytics Cloud in APAC',
    'Who are the available experts in Integration Cloud in UKI?',
    'Show me available SMEs for Data Cloud in AMER ACC',
    'Find available experts for Sales Cloud in EMEA ENTR',
    'Who can help with Service Cloud in APAC and is available?',
    'Show me available SMEs for Marketing Cloud in UKI',
    'Find available experts for Commerce Cloud in AMER ACC',
    'Who are the available experts in Platform in EMEA ENTR?',
    'Show me available SMEs for Analytics Cloud in APAC',
    'Find available experts for Integration Cloud in UKI',
    
    // Language Variations
    'Find English speaking SMEs for Data Cloud in AMER ACC',
    'Who are the Spanish speaking experts in Sales Cloud in EMEA ENTR?',
    'Show me French speaking SMEs for Service Cloud in APAC',
    'Find German speaking experts for Marketing Cloud in UKI',
    'Who can help with Commerce Cloud in AMER ACC in English?',
    'Show me Italian speaking SMEs for Platform in EMEA ENTR',
    'Find Japanese speaking experts for Analytics Cloud in APAC',
    'Who are the Chinese speaking experts in Integration Cloud in UKI?',
    'Show me Portuguese speaking SMEs for Data Cloud in AMER ACC',
    'Find Dutch speaking experts for Sales Cloud in EMEA ENTR',
    'Who can help with Service Cloud in APAC in Korean?',
    'Show me Arabic speaking SMEs for Marketing Cloud in UKI',
    'Find Hindi speaking experts for Commerce Cloud in AMER ACC',
    'Who are the Russian speaking experts in Platform in EMEA ENTR?',
    'Show me Thai speaking SMEs for Analytics Cloud in APAC',
    'Find Vietnamese speaking experts for Integration Cloud in UKI'
};

System.debug('✅ SME Search Utterances: ' + smeUtterances.size() + ' test cases');
for (Integer i = 0; i < smeUtterances.size(); i++) {
    System.debug('   Test ' + (i+1) + ': "' + smeUtterances[i] + '"');
}
