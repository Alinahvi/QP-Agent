// Extensive UAT Part 1: Open Pipe Analysis (50+ utterances)
System.debug('🧪 Extensive UAT Part 1: Open Pipe Analysis');
System.debug('==========================================');

List<String> openPipeUtterances = new List<String>{
    // Basic Open Pipe Analysis
    'Show me all the products that passed stage 4 within AMER ACC for open pipe',
    'Open pipe passed stage 4 in AMER ACC, country = US, top 20',
    'Compare last quarter open pipe post stage 4 for AMER ACC',
    'Show me open pipe for EMEA ENTR, stage 3 and above, current quarter',
    'What are the top 15 opportunities in APAC that passed stage 5?',
    'Show me open pipe for Data Cloud and Sales Cloud products in AMER ACC',
    'Open pipe analysis for UKI region, post stage 4, previous quarter',
    
    // Stage Variations
    'Open pipe for AMER ACC that passed stage 3',
    'Show me opportunities in EMEA ENTR beyond stage 4',
    'Open pipe analysis for APAC opportunities at stage 5 or higher',
    'Find open pipe in UKI that passed stage 6',
    'Show me AMER ACC open pipe beyond stage 2',
    'Open pipe for EMEA ENTR at stage 4 and above',
    'APAC open pipe opportunities past stage 3',
    'UKI open pipe that passed stage 5',
    'AMER ACC open pipe beyond stage 1',
    'EMEA ENTR open pipe at stage 6 or higher',
    'APAC open pipe opportunities past stage 4',
    'UKI open pipe that passed stage 7',
    
    // Time Frame Variations
    'Open pipe for AMER ACC this quarter',
    'Show me EMEA ENTR open pipe last quarter',
    'APAC open pipe current quarter',
    'UKI open pipe previous quarter',
    'AMER ACC open pipe this Q1',
    'EMEA ENTR open pipe last Q2',
    'APAC open pipe current Q3',
    'UKI open pipe previous Q4',
    'AMER ACC open pipe now',
    'EMEA ENTR open pipe present',
    'APAC open pipe today',
    'UKI open pipe earlier',
    'AMER ACC open pipe before',
    'EMEA ENTR open pipe past',
    
    // Country Variations
    'Open pipe for AMER ACC in United States',
    'Show me EMEA ENTR open pipe in United Kingdom',
    'APAC open pipe in Australia',
    'UKI open pipe in Ireland',
    'AMER ACC open pipe in Canada',
    'EMEA ENTR open pipe in Germany',
    'APAC open pipe in Japan',
    'UKI open pipe in UK',
    'AMER ACC open pipe in US',
    'EMEA ENTR open pipe in France',
    'APAC open pipe in China',
    'UKI open pipe in Ireland',
    'AMER ACC open pipe in Mexico',
    'EMEA ENTR open pipe in Spain',
    'APAC open pipe in India',
    'UKI open pipe in Netherlands',
    
    // Product Variations
    'Open pipe for Sales Cloud in AMER ACC',
    'Show me Service Cloud open pipe in EMEA ENTR',
    'Marketing Cloud open pipe in APAC',
    'Commerce Cloud open pipe in UKI',
    'Data Cloud open pipe in AMER ACC',
    'Platform open pipe in EMEA ENTR',
    'Analytics Cloud open pipe in APAC',
    'Integration Cloud open pipe in UKI',
    'Sales and Service Cloud open pipe in AMER ACC',
    'Marketing and Commerce Cloud open pipe in EMEA ENTR',
    'Data and Analytics Cloud open pipe in APAC',
    'Platform and Integration Cloud open pipe in UKI',
    
    // Limit Variations
    'Show me top 5 open pipe opportunities in AMER ACC',
    'Open pipe top 10 in EMEA ENTR',
    'APAC open pipe first 15',
    'UKI open pipe limit 20',
    'AMER ACC open pipe top 25',
    'EMEA ENTR open pipe first 30',
    'APAC open pipe limit 35',
    'UKI open pipe top 40',
    'AMER ACC open pipe first 45',
    'EMEA ENTR open pipe limit 50'
};

System.debug('✅ Open Pipe Analysis Utterances: ' + openPipeUtterances.size() + ' test cases');
for (Integer i = 0; i < openPipeUtterances.size(); i++) {
    System.debug('   Test ' + (i+1) + ': "' + openPipeUtterances[i] + '"');
}
