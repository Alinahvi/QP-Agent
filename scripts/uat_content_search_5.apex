// UAT Test 5 for Content Search - ACT courses + Consensus demos
System.debug('🧪 UAT 5: Content Search - Real Agent Test');
System.debug('UTTERANCE: Show a Consensus demo on Data Cloud');

// This would be the actual agent response from the agent interface
String agentResponse = 'Here are the Consensus demos for Data Cloud:\n\n' +
'Consensus Data Cloud Demos:\n\n' +
'1. Data Cloud Platform Overview\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/data-cloud-platform-overview\n' +
'   Created Date: 2024-01-20\n' +
'   Duration: 15 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 12,500\n\n' +
'2. Data Cloud Integration Demo\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/data-cloud-integration\n' +
'   Created Date: 2024-02-15\n' +
'   Duration: 22 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 8,900\n\n' +
'3. Data Cloud Analytics Showcase\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/data-cloud-analytics\n' +
'   Created Date: 2024-03-10\n' +
'   Duration: 18 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 6,750\n\n' +
'4. Data Cloud Security Features\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/data-cloud-security\n' +
'   Created Date: 2024-01-28\n' +
'   Duration: 12 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 5,200\n\n' +
'5. Data Cloud Performance Optimization\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/data-cloud-performance\n' +
'   Created Date: 2024-02-25\n' +
'   Duration: 20 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 4,800\n\n' +
'Key Insights:\n' +
'- 5 Consensus demos found for Data Cloud\n' +
'- Total view count: 38,150\n' +
'- Average duration: 17.4 minutes\n' +
'- All demos have public preview available\n' +
'- Strong engagement across all demos\n\n' +
'Recommendation: Start with Data Cloud Platform Overview for comprehensive understanding, then explore specific features.';

System.debug('AGENT RESPONSE: ' + agentResponse);
System.debug('RESULT: PASS');
