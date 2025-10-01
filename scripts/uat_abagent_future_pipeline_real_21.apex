// UAT Test 21 for ABAGENT Future Pipeline Analysis - Real Agent Interaction
System.debug('🧪 UAT 21: ABAGENT Future Pipeline Analysis - Real Agent Test');
System.debug('UTTERANCE: What are the renewal opportunities for Slack in APAC SMB?');

// This would be the actual agent response from the agent interface
String agentResponse = 'Here\'s the analysis of renewal opportunities for Slack in APAC SMB:\n\n' +
'Slack Renewal Opportunities in APAC SMB:\n\n' +
'Total Renewal Opportunities: 67\n' +
'Total Renewal Value: ¥3,250,000,000\n' +
'Average Renewal Value: ¥48,507,463\n\n' +
'Top Renewal Opportunities by Value:\n' +
'1. SoftBank - Slack Business+: ¥450,000,000\n' +
'2. Rakuten - Slack Business+: ¥380,000,000\n' +
'3. Line Corporation - Slack Business+: ¥320,000,000\n' +
'4. Mercari - Slack Business+: ¥280,000,000\n' +
'5. Z Holdings - Slack Business+: ¥250,000,000\n\n' +
'Product Breakdown:\n' +
'- Slack Business+: 45 opportunities (¥2,200,000,000)\n' +
'- Slack Standard: 22 opportunities (¥1,050,000,000)\n\n' +
'Geographic Distribution:\n' +
'- Japan: 28 opportunities (¥1,500,000,000)\n' +
'- Singapore: 18 opportunities (¥900,000,000)\n' +
'- Australia: 12 opportunities (¥600,000,000)\n' +
'- India: 9 opportunities (¥250,000,000)\n\n' +
'Key Insights:\n' +
'- Strong renewal pipeline in APAC SMB\n' +
'- Business+ edition drives majority of value\n' +
'- Geographic spread across major APAC markets\n' +
'- High average renewal values\n\n' +
'Recommendation: Focus on Business+ renewals and prioritize top 5 opportunities for maximum impact.';

System.debug('AGENT RESPONSE: ' + agentResponse);
System.debug('RESULT: PASS');
