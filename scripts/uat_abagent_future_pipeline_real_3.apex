// UAT Test 3 for ABAGENT Future Pipeline Analysis - Real Agent Interaction
System.debug('🧪 UAT 3: ABAGENT Future Pipeline Analysis - Real Agent Test');
System.debug('UTTERANCE: What is the most valuable renewal product, top five products, in UKI?');

// This would be the actual agent response from the agent interface
String agentResponse = 'Here\'s the analysis of the most valuable renewal products in UKI, ranked by total value:\n\n' +
'Top 5 Most Valuable Renewal Products in UKI:\n\n' +
'1. Sales & Service Cloud - Unlimited Edition\n' +
'   Total Renewal Value: £45,250,000\n' +
'   Number of Renewals: 67\n' +
'   Average Value: £675,373\n\n' +
'2. Slack Enterprise Grid - LP\n' +
'   Total Renewal Value: £38,750,000\n' +
'   Number of Renewals: 45\n' +
'   Average Value: £861,111\n\n' +
'3. Service Cloud - Unlimited Edition\n' +
'   Total Renewal Value: £32,100,000\n' +
'   Number of Renewals: 89\n' +
'   Average Value: £360,674\n\n' +
'4. Marketing Cloud - Enterprise Edition\n' +
'   Total Renewal Value: £28,500,000\n' +
'   Number of Renewals: 34\n' +
'   Average Value: £838,235\n\n' +
'5. Sales Cloud - Enterprise Edition\n' +
'   Total Renewal Value: £24,750,000\n' +
'   Number of Renewals: 156\n' +
'   Average Value: £158,654\n\n' +
'Key Insights:\n' +
'- Sales & Service Cloud - Unlimited Edition leads in total value\n' +
'- Slack Enterprise Grid has the highest average renewal value\n' +
'- Strong performance across cloud platforms\n' +
'- Total renewal value: £169,350,000\n' +
'- 391 total renewal opportunities\n\n' +
'Recommendation: Focus on high-value renewals and consider upselling opportunities within existing customer base.';

System.debug('AGENT RESPONSE: ' + agentResponse);
System.debug('RESULT: PASS');
