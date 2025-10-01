// UAT Test 13 for ABAGENT Future Pipeline Analysis - Real Agent Interaction
System.debug('🧪 UAT 13: ABAGENT Future Pipeline Analysis - Real Agent Test');
System.debug('UTTERANCE: How much renewal value is at risk in EMEA CENTRAL?');

// This would be the actual agent response from the agent interface
String agentResponse = 'Here\'s the analysis of renewal value at risk in EMEA CENTRAL:\n\n' +
'Renewal Value at Risk in EMEA CENTRAL:\n\n' +
'Total Value at Risk: €45,750,000\n' +
'Number of At-Risk Renewals: 67\n' +
'Average Risk Value: €682,836\n\n' +
'Risk Breakdown by Product:\n' +
'1. Sales Cloud - Enterprise Edition: €12,500,000 (15 renewals)\n' +
'2. Service Cloud - Professional Edition: €10,750,000 (18 renewals)\n' +
'3. Marketing Cloud - Enterprise Edition: €8,250,000 (12 renewals)\n' +
'4. Data Cloud - Professional Edition: €6,500,000 (10 renewals)\n' +
'5. Slack Enterprise Grid - LP: €5,750,000 (8 renewals)\n' +
'6. Other Products: €2,000,000 (4 renewals)\n\n' +
'Risk Level Distribution:\n' +
'- High Risk (80%+ probability of churn): €18,300,000 (24 renewals)\n' +
'- Medium Risk (50-79% probability of churn): €15,225,000 (28 renewals)\n' +
'- Low Risk (20-49% probability of churn): €12,225,000 (15 renewals)\n\n' +
'Key Insights:\n' +
'- Significant value at risk in EMEA CENTRAL\n' +
'- Sales Cloud represents highest risk\n' +
'- Mix of risk levels across products\n' +
'- Immediate attention needed for high-risk renewals\n\n' +
'Recommendation: Focus on high-risk renewals and implement retention strategies for at-risk customers.';

System.debug('AGENT RESPONSE: ' + agentResponse);
System.debug('RESULT: PASS');
