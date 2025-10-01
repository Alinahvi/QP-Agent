// Test script to verify the sorting logic
System.debug('🧪 Testing Sorting Logic...');

// Test the ProductAmountComparator directly
System.debug('=== TEST: ProductAmountComparator Logic ===');

// Create test data
Map<String, Decimal> testAmounts = new Map<String, Decimal>();
testAmounts.put('Product A', 1000000.00);
testAmounts.put('Product B', 500000.00);
testAmounts.put('Product C', 2000000.00);
testAmounts.put('Product D', 750000.00);

System.debug('Original amounts: ' + testAmounts);

// Create comparator
ANAgentOpenPipeAnalysisService.ProductAmountComparator comparator = 
    new ANAgentOpenPipeAnalysisService.ProductAmountComparator(testAmounts);

// Test individual comparisons
System.debug('=== Individual Comparisons ===');
System.debug('Product C ($2M) vs Product A ($1M): ' + comparator.compare('Product C', 'Product A'));
System.debug('Product A ($1M) vs Product C ($2M): ' + comparator.compare('Product A', 'Product C'));
System.debug('Product A ($1M) vs Product B ($500K): ' + comparator.compare('Product A', 'Product B'));
System.debug('Product B ($500K) vs Product A ($1M): ' + comparator.compare('Product B', 'Product A'));

// Test sorting
System.debug('=== Test Sorting ===');
List<String> testProducts = new List<String>(testAmounts.keySet());
System.debug('Before sorting: ' + testProducts);

testProducts.sort(comparator);
System.debug('After sorting: ' + testProducts);

// Show the sorted results with amounts
System.debug('=== Sorted Results with Amounts ===');
for (Integer i = 0; i < testProducts.size(); i++) {
    String product = testProducts[i];
    Decimal amount = testAmounts.get(product);
    System.debug((i+1) + '. ' + product + ' - $' + amount);
}

System.debug('🎯 Sorting Logic Test Complete!'); 