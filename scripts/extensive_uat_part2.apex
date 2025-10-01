// Extensive UAT Part 2: Pipeline Search (50+ utterances)
System.debug('🧪 Extensive UAT Part 2: Pipeline Search');
System.debug('========================================');

List<String> pipelineUtterances = new List<String>{
    // Basic Pipeline Search
    'Find opportunities in AMER ACC with amount greater than 1M',
    'Search for deals in EMEA ENTR that are closing this quarter',
    'Show me pipeline for Data Cloud products in APAC region',
    'Find opportunities with stage "Proposal/Price Quote" in UKI',
    'Search for deals with probability greater than 50% in AMER ACC',
    'Show me pipeline for Sales Cloud and Service Cloud products',
    'Find opportunities closing in the next 30 days in EMEA ENTR',
    
    // Amount Filter Variations
    'Find opportunities in AMER ACC with amount more than 2M',
    'Search for deals in EMEA ENTR with amount above 5M',
    'Show me pipeline in APAC with amount exceeds 10M',
    'Find opportunities in UKI with amount greater than 1B',
    'Search for deals in AMER ACC with amount over 500K',
    'Show me pipeline in EMEA ENTR with amount above 3M',
    'Find opportunities in APAC with amount more than 7M',
    'Search for deals in UKI with amount exceeds 15M',
    'Show me pipeline in AMER ACC with amount greater than 2.5M',
    'Find opportunities in EMEA ENTR with amount above 8M',
    'Search for deals in APAC with amount more than 12M',
    'Show me pipeline in UKI with amount exceeds 20M',
    'Find opportunities in AMER ACC with amount between 1M and 5M',
    'Search for deals in EMEA ENTR with amount from 2M to 10M',
    'Show me pipeline in APAC with amount range 3M to 15M',
    'Find opportunities in UKI with amount between 5M and 25M',
    
    // Stage Filter Variations
    'Find opportunities in AMER ACC with stage Prospecting',
    'Search for deals in EMEA ENTR with stage Qualification',
    'Show me pipeline in APAC with stage Needs Analysis',
    'Find opportunities in UKI with stage Proposal/Price Quote',
    'Search for deals in AMER ACC with stage Negotiation/Review',
    'Show me pipeline in EMEA ENTR with stage Closed Won',
    'Find opportunities in APAC with stage Closed Lost',
    'Search for deals in UKI with stage Cancelled',
    'Show me pipeline in AMER ACC with stage Lead',
    'Find opportunities in EMEA ENTR with stage Prospect',
    'Search for deals in APAC with stage Analysis',
    'Show me pipeline in UKI with stage Proposal',
    'Find opportunities in AMER ACC with stage Negotiation',
    'Search for deals in EMEA ENTR with stage Review',
    'Show me pipeline in APAC with stage Won',
    'Find opportunities in UKI with stage Lost',
    
    // Date Range Variations
    'Find opportunities in AMER ACC closing this quarter',
    'Search for deals in EMEA ENTR closing last quarter',
    'Show me pipeline in APAC closing this month',
    'Find opportunities in UKI closing last month',
    'Search for deals in AMER ACC closing this year',
    'Show me pipeline in EMEA ENTR closing last year',
    'Find opportunities in APAC closing in next 30 days',
    'Search for deals in UKI closing in next 60 days',
    'Show me pipeline in AMER ACC closing in next 90 days',
    'Find opportunities in EMEA ENTR closing within 30 days',
    'Search for deals in APAC closing within 60 days',
    'Show me pipeline in UKI closing within 90 days',
    'Find opportunities in AMER ACC closing Q1',
    'Search for deals in EMEA ENTR closing Q2',
    'Show me pipeline in APAC closing Q3',
    'Find opportunities in UKI closing Q4',
    
    // Probability Variations
    'Find opportunities in AMER ACC with probability greater than 25%',
    'Search for deals in EMEA ENTR with probability more than 50%',
    'Show me pipeline in APAC with probability above 75%',
    'Find opportunities in UKI with probability exceeds 90%',
    'Search for deals in AMER ACC with probability equal to 100%',
    'Show me pipeline in EMEA ENTR with probability less than 25%',
    'Find opportunities in APAC with probability below 50%',
    'Search for deals in UKI with probability under 75%',
    'Show me pipeline in AMER ACC with probability between 50% and 100%',
    'Find opportunities in EMEA ENTR with probability from 25% to 75%',
    'Search for deals in APAC with probability range 10% to 50%',
    'Show me pipeline in UKI with probability between 75% and 95%',
    
    // Product Filter Variations
    'Find opportunities in AMER ACC for Sales Cloud',
    'Search for deals in EMEA ENTR for Service Cloud',
    'Show me pipeline in APAC for Marketing Cloud',
    'Find opportunities in UKI for Commerce Cloud',
    'Search for deals in AMER ACC for Data Cloud',
    'Show me pipeline in EMEA ENTR for Platform',
    'Find opportunities in APAC for Analytics Cloud',
    'Search for deals in UKI for Integration Cloud',
    'Show me pipeline in AMER ACC for Sales and Service Cloud',
    'Find opportunities in EMEA ENTR for Marketing and Commerce Cloud',
    'Search for deals in APAC for Data and Analytics Cloud',
    'Show me pipeline in UKI for Platform and Integration Cloud',
    
    // Country Filter Variations
    'Find opportunities in AMER ACC for United States',
    'Search for deals in EMEA ENTR for United Kingdom',
    'Show me pipeline in APAC for Australia',
    'Find opportunities in UKI for Ireland',
    'Search for deals in AMER ACC for Canada',
    'Show me pipeline in EMEA ENTR for Germany',
    'Find opportunities in APAC for Japan',
    'Search for deals in UKI for Netherlands',
    'Show me pipeline in AMER ACC for Mexico',
    'Find opportunities in EMEA ENTR for France',
    'Search for deals in APAC for China',
    'Show me pipeline in UKI for Spain',
    'Find opportunities in AMER ACC for Brazil',
    'Search for deals in EMEA ENTR for Italy',
    'Show me pipeline in APAC for India',
    'Find opportunities in UKI for Singapore'
};

System.debug('✅ Pipeline Search Utterances: ' + pipelineUtterances.size() + ' test cases');
for (Integer i = 0; i < pipelineUtterances.size(); i++) {
    System.debug('   Test ' + (i+1) + ': "' + pipelineUtterances[i] + '"');
}
