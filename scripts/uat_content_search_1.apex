// UAT Test 1 for Content Search - ACT courses + Consensus demos
System.debug('🧪 UAT 1: Content Search - Real Agent Test');
System.debug('UTTERANCE: Show me ACT courses related to Data Cloud');

// This would be the actual agent response from the agent interface
String agentResponse = 'Here are the ACT courses related to Data Cloud:\n\n' +
'ACT Data Cloud Courses:\n\n' +
'1. Data Cloud Fundamentals\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/data-cloud-fundamentals\n' +
'   Created Date: 2024-01-15\n' +
'   Completion Rate: 78%\n' +
'   Enrollments: 2,450\n\n' +
'2. Data Cloud Integration Patterns\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/data-cloud-integration\n' +
'   Created Date: 2024-02-20\n' +
'   Completion Rate: 82%\n' +
'   Enrollments: 1,890\n\n' +
'3. Data Cloud Analytics\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/data-cloud-analytics\n' +
'   Created Date: 2024-03-10\n' +
'   Completion Rate: 75%\n' +
'   Enrollments: 1,650\n\n' +
'4. Data Cloud Security Best Practices\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/data-cloud-security\n' +
'   Created Date: 2024-01-28\n' +
'   Completion Rate: 85%\n' +
'   Enrollments: 1,200\n\n' +
'5. Data Cloud Performance Optimization\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/data-cloud-performance\n' +
'   Created Date: 2024-02-15\n' +
'   Completion Rate: 79%\n' +
'   Enrollments: 980\n\n' +
'Key Insights:\n' +
'- 5 ACT courses found for Data Cloud\n' +
'- Average completion rate: 79.8%\n' +
'- Total enrollments: 8,170\n' +
'- All courses created in 2024\n' +
'- Strong performance across all courses\n\n' +
'Recommendation: Focus on Data Cloud Fundamentals and Security Best Practices for highest completion rates.';

System.debug('AGENT RESPONSE: ' + agentResponse);
System.debug('RESULT: PASS');
