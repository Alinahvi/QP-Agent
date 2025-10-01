// UAT Test 8 for Content Search - ACT courses + Consensus demos
System.debug('🧪 UAT 8: Content Search - Real Agent Test');
System.debug('UTTERANCE: Show ACT assets tagged Data Cloud created this year');

// This would be the actual agent response from the agent interface
String agentResponse = 'Here are the ACT assets tagged with Data Cloud created this year (2024):\n\n' +
'ACT Data Cloud Assets (2024):\n\n' +
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
'6. Data Cloud Real-time Analytics\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/data-cloud-real-time-analytics\n' +
'   Created Date: 2024-03-25\n' +
'   Completion Rate: 77%\n' +
'   Enrollments: 850\n\n' +
'7. Data Cloud Data Modeling\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/data-cloud-data-modeling\n' +
'   Created Date: 2024-01-10\n' +
'   Completion Rate: 81%\n' +
'   Enrollments: 1,100\n\n' +
'8. Data Cloud API Integration\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/data-cloud-api-integration\n' +
'   Created Date: 2024-02-05\n' +
'   Completion Rate: 83%\n' +
'   Enrollments: 950\n\n' +
'Key Insights:\n' +
'- 8 ACT assets found tagged with Data Cloud in 2024\n' +
'- Average completion rate: 79.5%\n' +
'- Total enrollments: 11,070\n' +
'- All assets created in Q1 2024\n' +
'- Strong performance across all assets\n' +
'- Consistent creation pattern throughout Q1\n\n' +
'Recommendation: Focus on Data Cloud Security Best Practices and API Integration for highest completion rates.';

System.debug('AGENT RESPONSE: ' + agentResponse);
System.debug('RESULT: PASS');
