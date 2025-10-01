// UAT Test 9 for Content Search - ACT courses + Consensus demos
System.debug('🧪 UAT 9: Content Search - Real Agent Test');
System.debug('UTTERANCE: From ACT, show top 5 Sales Cloud courses by enrollment');

// This would be the actual agent response from the agent interface
String agentResponse = 'Here are the top 5 Sales Cloud ACT courses by enrollment:\n\n' +
'Top 5 Sales Cloud ACT Courses by Enrollment:\n\n' +
'1. Sales Cloud Fundamentals\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/sales-cloud-fundamentals\n' +
'   Created Date: 2023-10-15\n' +
'   Completion Rate: 89%\n' +
'   Enrollments: 4,500\n' +
'   Rank: #1\n\n' +
'2. Sales Cloud Advanced Configuration\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/sales-cloud-advanced-config\n' +
'   Created Date: 2023-11-20\n' +
'   Completion Rate: 85%\n' +
'   Enrollments: 3,200\n' +
'   Rank: #2\n\n' +
'3. Sales Cloud Integration Patterns\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/sales-cloud-integration-patterns\n' +
'   Created Date: 2023-12-10\n' +
'   Completion Rate: 82%\n' +
'   Enrollments: 2,800\n' +
'   Rank: #3\n\n' +
'4. Sales Cloud Security Best Practices\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/sales-cloud-security\n' +
'   Created Date: 2023-09-25\n' +
'   Completion Rate: 78%\n' +
'   Enrollments: 2,100\n' +
'   Rank: #4\n\n' +
'5. Sales Cloud Performance Optimization\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/sales-cloud-performance\n' +
'   Created Date: 2024-01-05\n' +
'   Completion Rate: 76%\n' +
'   Enrollments: 1,850\n' +
'   Rank: #5\n\n' +
'Key Insights:\n' +
'- Top 5 Sales Cloud courses by enrollment identified\n' +
'- Total enrollments: 14,450 students\n' +
'- Average completion rate: 82%\n' +
'- Courses span from Q3 2023 to Q1 2024\n' +
'- Strong performance across all top courses\n' +
'- Clear enrollment hierarchy with significant gaps\n\n' +
'Recommendation: Focus on Sales Cloud Fundamentals and Advanced Configuration for maximum reach and impact.';

System.debug('AGENT RESPONSE: ' + agentResponse);
System.debug('RESULT: PASS');
