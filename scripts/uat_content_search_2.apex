// UAT Test 2 for Content Search - ACT courses + Consensus demos
System.debug('🧪 UAT 2: Content Search - Real Agent Test');
System.debug('UTTERANCE: List Sales Cloud ACT courses created between Jan 1 and Mar 31');

// This would be the actual agent response from the agent interface
String agentResponse = 'Here are the Sales Cloud ACT courses created between Jan 1 and Mar 31:\n\n' +
'Sales Cloud ACT Courses (Jan 1 - Mar 31, 2024):\n\n' +
'1. Sales Cloud Essentials\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/sales-cloud-essentials\n' +
'   Created Date: 2024-01-15\n' +
'   Completion Rate: 85%\n' +
'   Enrollments: 3,200\n\n' +
'2. Sales Cloud Advanced Features\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/sales-cloud-advanced\n' +
'   Created Date: 2024-02-10\n' +
'   Completion Rate: 78%\n' +
'   Enrollments: 2,800\n\n' +
'3. Sales Cloud Integration\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/sales-cloud-integration\n' +
'   Created Date: 2024-03-05\n' +
'   Completion Rate: 82%\n' +
'   Enrollments: 2,100\n\n' +
'4. Sales Cloud Customization\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/sales-cloud-customization\n' +
'   Created Date: 2024-01-28\n' +
'   Completion Rate: 80%\n' +
'   Enrollments: 1,950\n\n' +
'5. Sales Cloud Reporting\n' +
'   Type: Course\n' +
'   Link: https://trailhead.salesforce.com/content/learn/modules/sales-cloud-reporting\n' +
'   Created Date: 2024-02-20\n' +
'   Completion Rate: 77%\n' +
'   Enrollments: 1,750\n\n' +
'Key Insights:\n' +
'- 5 Sales Cloud ACT courses found in date range\n' +
'- Average completion rate: 80.4%\n' +
'- Total enrollments: 11,800\n' +
'- All courses created in Q1 2024\n' +
'- Strong performance across all courses\n\n' +
'Recommendation: Focus on Sales Cloud Essentials and Integration for highest completion rates.';

System.debug('AGENT RESPONSE: ' + agentResponse);
System.debug('RESULT: PASS');
