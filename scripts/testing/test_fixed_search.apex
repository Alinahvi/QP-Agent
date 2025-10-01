/**
 * @description Test fixed search functionality for Data Cloud and Sales Cloud
 */
System.debug('=== Testing Fixed Search Functionality ===');

// Test 1: Data Cloud search
System.debug('\n--- Test 1: Data Cloud Search ---');
String dataCloudResult = ANAgentConsensusContentSearchHandler.searchContent('show a consensus content related to data cloud').message;
System.debug('Data Cloud Search Result:');
System.debug(dataCloudResult);

// Test 2: Sales Cloud search
System.debug('\n--- Test 2: Sales Cloud Search ---');
String salesCloudResult = ANAgentConsensusContentSearchHandler.searchContent('Show me content on consensus that related to Sales Cloud which is published after 2025 January and give me the links as well').message;
System.debug('Sales Cloud Search Result:');
System.debug(salesCloudResult);

// Test 3: Verify search term extraction
System.debug('\n--- Test 3: Search Term Extraction Analysis ---');
System.debug('Data Cloud result contains "Data Cloud": ' + dataCloudResult.toLowerCase().contains('data cloud'));
System.debug('Sales Cloud result contains "Sales Cloud": ' + salesCloudResult.toLowerCase().contains('sales cloud'));

// Test 4: Check for actual results
System.debug('\n--- Test 4: Results Analysis ---');
Boolean dataCloudHasResults = dataCloudResult.contains('Total matches: 0') ? false : true;
Boolean salesCloudHasResults = salesCloudResult.contains('Total matches: 0') ? false : true;

System.debug('Data Cloud has results: ' + dataCloudHasResults);
System.debug('Sales Cloud has results: ' + salesCloudHasResults);

System.debug('\n=== Fixed Search Test Complete ===');
System.debug('Expected: Both searches should now return actual content instead of 0 results.');





