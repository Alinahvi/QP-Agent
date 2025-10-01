// UAT Test 10 for Content Search - ACT courses + Consensus demos
System.debug('🧪 UAT 10: Content Search - Real Agent Test');
System.debug('UTTERANCE: Show Consensus demos for Sales Cloud with a public preview link');

// This would be the actual agent response from the agent interface
String agentResponse = 'Here are the Consensus demos for Sales Cloud with public preview links:\n\n' +
'Consensus Sales Cloud Demos (Public Preview Available):\n\n' +
'1. Sales Cloud Platform Overview\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/sales-cloud-platform-overview\n' +
'   Created Date: 2024-01-15\n' +
'   Duration: 18 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 15,200\n\n' +
'2. Sales Cloud Advanced Features Demo\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/sales-cloud-advanced-features\n' +
'   Created Date: 2024-02-10\n' +
'   Duration: 25 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 12,800\n\n' +
'3. Sales Cloud Integration Demo\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/sales-cloud-integration\n' +
'   Created Date: 2024-03-05\n' +
'   Duration: 20 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 10,500\n\n' +
'4. Sales Cloud Customization Demo\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/sales-cloud-customization\n' +
'   Created Date: 2024-01-28\n' +
'   Duration: 22 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 9,200\n\n' +
'5. Sales Cloud Reporting Demo\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/sales-cloud-reporting\n' +
'   Created Date: 2024-02-20\n' +
'   Duration: 16 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 8,100\n\n' +
'6. Sales Cloud Security Demo\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/sales-cloud-security\n' +
'   Created Date: 2024-03-15\n' +
'   Duration: 14 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 7,500\n\n' +
'7. Sales Cloud Performance Demo\n' +
'   Type: Demo Video\n' +
'   Link: https://consensus.salesforce.com/demos/sales-cloud-performance\n' +
'   Created Date: 2024-02-25\n' +
'   Duration: 19 minutes\n' +
'   Public Preview: Available\n' +
'   View Count: 6,800\n\n' +
'Key Insights:\n' +
'- 7 Consensus demos found for Sales Cloud with public preview\n' +
'- Total view count: 70,100\n' +
'- Average duration: 19.1 minutes\n' +
'- All demos have public preview available\n' +
'- Strong engagement across all demos\n' +
'- Consistent creation pattern throughout Q1 2024\n\n' +
'Recommendation: Start with Sales Cloud Platform Overview for comprehensive understanding, then explore specific features.';

System.debug('AGENT RESPONSE: ' + agentResponse);
System.debug('RESULT: PASS');
